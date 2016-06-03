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
        guard !self.syncronizing else {
            return
        }
        
        guard let feeds = ModelManager.dataStack.fetchAll(From(Feed)) else {
            return
        }
        
        self.updateSyncronizing(true)
        IndicatorAdaptor.whistleLoading(withMessage: "正在同步")
        
        //TODO: retain parse operation
        
        for feed in feeds {
            guard let url = feed.url else {
                continue
            }
            
//            if let syncTime = feed.syncDate where NSDate().timeIntervalSinceDate(syncTime) < 12 * 3600 {
//                continue
//            }
            dispatch_group_async(feedParseGroup, feedParseQueue, {
                let parseOperation = FeedParseOperation(withUrl: url)
                let semaphore = dispatch_semaphore_create(0)
                parseOperation.parse(withHandler: { (channel, items, error) in
                    guard let items = items, let channel = channel else {
                        dispatch_semaphore_signal(semaphore)
                        return
                    }
                    
                    // update sync time & update time
                    ModelManager.dataStack.beginSynchronous({ (transaction) in
                        let feed = transaction.edit(feed)
                        feed?.updateDate = channel.channelDateOfLastChange
                        feed?.syncDate = NSDate()
                        transaction.commitAndWait()
                    })
                    
                    for item in items {
                        guard let feedLink = item.feedLink else {
                            continue
                        }
                        let semaphore = dispatch_semaphore_create(0)
                        let articleId = FileManagerAdaptor.generateWebarchiveId()
                        ModelManager.dataStack.beginSynchronous({ (transaction) in
//                            guard transaction.fetchOne(From(Article), Where("url", isEqualTo: feedLink)) == nil else {
//                                return
//                            }
                            
                            let existArticle = transaction.fetchOne(From(Article), Where("url", isEqualTo: feedLink))
                            
                            let article = existArticle ?? transaction.create(Into(Article))
                            article.artileId = articleId
                            article.title = item.feedTitle
                            article.author = item.feedAuthor
                            article.summary = item.feedContentSnippet?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                            article.publicDate = item.feedPubDate
                            article.url = feedLink
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
                        })
                        WebarchiveManager.sharedInstance.archive(url: NSURL(string: feedLink)!, fileName: FileManagerAdaptor.fileName(withWebarhiveId: articleId), finished: { (success, errorReason) in
                            dispatch_semaphore_signal(semaphore)
                        })
                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                    }
                    dispatch_semaphore_signal(semaphore)
                })
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            })
        }
            
        dispatch_group_notify(feedParseGroup, dispatch_get_main_queue(), {
            IndicatorAdaptor.whistleCalm()
            IndicatorAdaptor.toast(message: "同步完成")
            self.updateSyncronizing(false)
        })
    }
    
    // MARK: - Private
    private init() {}
    private let feedParseQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    private let feedParseGroup = dispatch_group_create()
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
