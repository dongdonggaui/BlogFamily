//
//  FeedParseManager.swift
//  BlogFamily
//
//  Created by huangluyang on 16/6/2.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import UIKit
import CoreStore

typealias FeedParseHandler = (channel: FeedChannel?, items: [FeedItem]?, error: NSError?) -> ()

class FeedParseManager {
    
    static let sharedInstance = FeedParseManager()
    
    static func syncIfNeeded() {
        self.sharedInstance.syncIfNeeded()
    }
    
    func syncIfNeeded() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            guard !self.syncronizing else {
                return
            }
            
            guard let feeds = ModelManager.dataStack.fetchAll(From(Feed)) else {
                return
            }
            
            self.updateSyncronizing(true)
            IndicatorAdaptor.whistleLoading(withMessage: "准备同步")
            print("开始同步")
            
            for feed in feeds {
                IndicatorAdaptor.updateWhistleLoading(withMessage: "正在同步 \(feed.title!)")
                guard let url = feed.url else {
                    IndicatorAdaptor.whistleCalm(withMessage: "同步错误 \(feed.title!)地址不合法")
                    continue
                }
                
//                if let syncTime = feed.syncDate where NSDate().timeIntervalSinceDate(syncTime) < 12 * 3600 {
//                    IndicatorAdaptor.whistleCalm(withMessage: "同步完成 \(feed.title!)")
//                    continue
//                }
                
                let parseSemaphore = dispatch_semaphore_create(0)
                let parseOperation = FeedParseOperation(withUrl: url)
                print("开始解析 feed : \(feed.url)")
                parseOperation.parse(withHandler: { (channel, items, error) in
                    guard let items = items, let channel = channel else {
                        print("解析失败 feed : \(feed.url)")
                        dispatch_semaphore_signal(parseSemaphore)
                        return
                    }
                    print("解析完成 feed : \(feed.url)")
                    
                    var needDownloadArticles: [Article] = []
                    
                    // update articles' meta data
                    print("更新 articles...")
                    for item in items {
                        guard let feedLink = item.feedLink else {
                            continue
                        }
                        ModelManager.dataStack.beginSynchronous({ (transaction) in
                            let existArticle = transaction.fetchOne(From(Article), Where("url", isEqualTo: feedLink))
                            
                            let article = existArticle ?? transaction.create(Into(Article))
                            article.artileId = article.artileId ?? FileManagerAdaptor.generateWebarchiveId()
                            article.title = item.feedTitle
                            article.author = item.feedAuthor
                            article.publicDate = item.feedPubDate
                            article.url = feedLink
                            article.summary = item.feedContent
                            article.feed = transaction.edit(feed)
                            article.addDate = NSDate()
                            article.domain = NSURL(string: feedLink)!.host
                            if let content = item.feedContent {
                                let imageUrls = item.getImageURLsFromContent(content)
                                if imageUrls.count > 0 {
                                    article.imageUrl = imageUrls[0]
                                }
                            }
                            
                            transaction.commitAndWait()
                            
                            if article.archivePath == nil {
                                needDownloadArticles += [article]
                            }
                        })
                    }
                    print("articles 更新完成")
                    print("需要下载 article : \(needDownloadArticles.count)")
                    
                    // download articles if needed
                    if needDownloadArticles.count > 0 {
                        let downloadSemaphore = dispatch_semaphore_create(0)
                        print("开始下载: \(feed.title)")
                        WebarchiveManager.sharedInstance.downloadArticles(needDownloadArticles, progress: { (completedTaskCount, totalTaskCount) in
                            IndicatorAdaptor.updateWhistleLoading(withMessage: "正在下载 \(feed.title!) \(completedTaskCount)/\(totalTaskCount)")
                            }, completion: {
                                print("完成下载: \(feed.title)")
                                dispatch_semaphore_signal(downloadSemaphore)
                        })
                        dispatch_semaphore_wait(downloadSemaphore, DISPATCH_TIME_FOREVER)
                    }
                    
                    // update sync time & update time
                    ModelManager.dataStack.beginSynchronous({ (transaction) in
                        let feed = transaction.edit(feed)
                        feed?.updateDate = channel.channelDateOfLastChange
                        feed?.syncDate = NSDate()
                        transaction.commitAndWait()
                    })
                    dispatch_semaphore_signal(parseSemaphore)
                })
                dispatch_semaphore_wait(parseSemaphore, DISPATCH_TIME_FOREVER)
            }
            
            IndicatorAdaptor.whistleCalm()
            IndicatorAdaptor.toast(message: "同步完成")
            self.updateSyncronizing(false)
        }
    }
    
    // MARK: - Private
    private init() {}
    private var syncronizing = false
    private let syncStateQueue = dispatch_queue_create("com.bf.syncStateQueue", DISPATCH_QUEUE_SERIAL)
    
    func updateSyncronizing(sync: Bool) {
        dispatch_sync(syncStateQueue) { 
            self.syncronizing = sync
        }
    }
}

class FeedParseOperation: FeedParserDelegate {
    
    init(withUrl url: String) {
        self.url = url
        self.parser = FeedParser(feedURL: url)
        self.parser.delegate = self
    }
    
    func parse(withHandler handler: FeedParseHandler) {
        self.parseHanlder = handler
        self.parser.parse()
    }
    
    // MARK: - FeedParserDelegate
    @objc func feedParser(parser: FeedParser, didParseChannel channel: FeedChannel) {
        print("did parse channel")
        self.channel = channel
    }
    
    @objc func feedParser(parser: FeedParser, didParseItem item: FeedItem) {
        print("did parse item : \(item.feedTitle)")
        self.items += [item]
    }
    
    @objc func feedParser(parser: FeedParser, successfullyParsedURL url: String) {
        print("successfully parsed url : \(url)")
        guard let handler = self.parseHanlder else {
            return
        }
        handler(channel: self.channel, items: self.items, error: nil)
    }
    
    @objc func feedParser(parser: FeedParser, parsingFailedReason reason: String) {
        print("parse failed with reason : \(reason)")
        guard let handler = self.parseHanlder else {
            return
        }
        handler(channel: self.channel, items: nil, error: ErrorAdaptor.appErrorWith(.FeedParseError, description: reason))
    }
    
    @objc func feedParserParsingAborted(parser: FeedParser) {
        print("parse aborted")
    }
    
    private var parseHanlder: FeedParseHandler?
    private let parser: FeedParser
    private let url: String
    private var items: [FeedItem] = []
    private var channel: FeedChannel?
}
