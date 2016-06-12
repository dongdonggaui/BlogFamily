//
//  WebarchiveManager.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/25.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import Foundation
import BiblioArchiver
import CoreStore

private typealias WebarchiveCompletionHandler = (archivedPath: String?, title: String?, error: NSError?) -> ()
typealias WebarchiveFinished = (success: Bool, errorReason: String?) -> ()
typealias ArticleDownloadProgress = (completedTaskCount: Int, totalTaskCount: Int) -> ()
typealias ArticleDwonloadCompletionHandler = () -> ()

let WebarchiveManagerError = "WebarchiveManagerError"

enum WebarchiveManagerErrorCode: Int {
    case NoData = 10001
    case CreateArchiveDirFailed = 10002
    case WriteToDiskError = 10003
}

class WebarchiveManager {
    static let sharedInstance = WebarchiveManager()
    
    private(set) var completedTaskCount = 0
    private(set) var totalTaskCount = 0
   
    // MARK: - Private
    private init() {}
    private let urlSession = NSURLSession.sharedSession()
    private let downloadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    private let totalTaskQueue = dispatch_queue_create("com.hly.webTotalTaskQueue", DISPATCH_QUEUE_SERIAL)
    private let completedTaskQueue = dispatch_queue_create("com.hly.webCompletedQueue", DISPATCH_QUEUE_SERIAL)
    private let archiveGroup = dispatch_group_create()
    private var currentTasks = Set<NSURL>()
    private let taskSyncQueue = dispatch_queue_create("com.hly.taskSyncQueue", DISPATCH_QUEUE_SERIAL)
}

extension WebarchiveManager {
    private func totalTaskCountIncrement() {
        dispatch_sync(totalTaskQueue) { 
            self.totalTaskCount += 1
        }
    }
    
    private func totalTaskCountDecrement() {
        dispatch_sync(totalTaskQueue) { 
            self.totalTaskCount -= 1
        }
    }
    
    private func clearTotalTaskCount() {
        dispatch_sync(totalTaskQueue) { 
            self.totalTaskCount = 0
        }
    }
    
    private func completedTaskCountIncrement() {
        dispatch_sync(completedTaskQueue) {
            self.completedTaskCount += 1
        }
    }
    
    private func completedTaskCountDecrement() {
        dispatch_sync(completedTaskQueue) {
            self.completedTaskCount -= 1
        }
    }
    
    private func clearCompletedTaskCount() {
        dispatch_sync(completedTaskQueue) { 
            self.completedTaskCount = 0
        }
    }
    
    private func taskEnqueue(withUrl url: NSURL) {
        dispatch_sync(self.taskSyncQueue) { 
            self.currentTasks.insert(url)
        }
    }
    
    private func taskDequeue(withUrl url: NSURL) {
        dispatch_sync(self.taskSyncQueue) { 
            self.currentTasks.remove(url)
        }
    }
}

extension WebarchiveManager {
    private func addArchiveTask(withUrl url: NSURL, fileName: String? = nil, completionHandler: WebarchiveCompletionHandler) {
        
        print("begin download task : \(url.absoluteString)")
        
        self.totalTaskCountIncrement()
        
        let semaphore = dispatch_semaphore_create(0)
        Archiver.logEnabled = true
        Archiver.archiveWebpageFormUrl(url) { (webarchiveData, metaData, error) in
            print("end download task : \(url.absoluteString), with error : \(error)")
            
            let fileName = fileName ?? FileManagerAdaptor.generateWebarchiveName()
            
            let completed: (success: Bool, error: NSError?) -> () = { success, error in
                
                self.completedTaskCountIncrement()
                if self.completedTaskCount == self.totalTaskCount {
                    self.clearTotalTaskCount()
                    self.clearCompletedTaskCount()
                }
                
                if success {
                    var htmlTitle: String?
                    if let title = metaData?[ArchivedWebpageMetaKeyTitle] {
                        htmlTitle = title
                    }
                    completionHandler(archivedPath: fileName, title: htmlTitle, error: nil)
                } else {
                    completionHandler(archivedPath: nil, title: nil, error: error)
                }
                
                dispatch_semaphore_signal(semaphore)
            }
            
            guard let data = webarchiveData else {
                completed(success: false, error: NSError(domain: WebarchiveManagerError, code: WebarchiveManagerErrorCode.NoData.rawValue, userInfo: nil))
                return
            }
            
            guard let filePath = FileManagerAdaptor.webarchivePath(withName: fileName) else {
                completed(success: false, error: NSError(domain: WebarchiveManagerError, code: WebarchiveManagerErrorCode.CreateArchiveDirFailed.rawValue, userInfo: nil))
                return
            }
            
            if (data.writeToFile(filePath, atomically: true)) {
                completed(success: true, error: nil)
            } else {
                completed(success: false, error: NSError(domain: WebarchiveManagerError, code: WebarchiveManagerErrorCode.WriteToDiskError.rawValue, userInfo: nil))
            }
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
}

extension WebarchiveManager {
    
    func archive(url url: NSURL) {
        self.archive(url: url) { (success, errorReason) in
            if success {
                IndicatorAdaptor.whistleCalm()
            } else {
                IndicatorAdaptor.toast(message: errorReason ?? "下载网页错误")
            }
        }
    }
    
    func archive(url url: NSURL, fileName: String? = nil, finished: WebarchiveFinished) {
        
        if url.absoluteString.hasPrefix("file://") {
            IndicatorAdaptor.toast(message: "已经下载过啦")
            return
        }
        
        if self.currentTasks.contains(url) {
            finished(success: false, errorReason: "该任务正在下载中，请勿重复添加")
            return
        }
        
        // check if needed to download webpage
        var exist = false
        var article: Article? = nil
        ModelManager.dataStack.beginSynchronous { (transaction) in
            article = transaction.fetchOne(From(Article), Where("url", isEqualTo: url.absoluteString))
            exist = article?.archivePath != nil
        }
        
        // stop if the webpage already downloaded
        if exist {
            finished(success: false, errorReason: "已经下载过啦")
            return
        }
        
        // launch webpage download task
        self.taskEnqueue(withUrl: url)
        dispatch_group_enter(archiveGroup)
        self.addArchiveTask(withUrl: url, fileName: fileName) { [weak self] (archivedPath, title, error) in
            guard let safeSelf = self else {
                return
            }
            guard let fileName = archivedPath else {
                safeSelf.taskDequeue(withUrl: url)
                dispatch_group_leave(safeSelf.archiveGroup)
                return
            }
            
            // download success then save it to db
            ModelManager.dataStack.beginSynchronous({ (transaction) in
                if let article = transaction.edit(article) {
                    // feed article task
                    print("download feed article : \(article.title)")
                    article.archivePath = fileName
                } else {
                    // web article task
                    print("download web article : \(title)")
                    let article = transaction.create(Into(Article))
                    article.artileId = FileManagerAdaptor.webarchiveId(withFileName: fileName)
                    article.archivePath = fileName
                    article.url = url.absoluteString
                    article.title = title
                    article.addDate = NSDate()
                    article.domain = url.host
                }
                
                let result = transaction.commitAndWait()
                switch result {
                case .Success(let hasChanges):
                    print("commit success with changes : \(hasChanges))")
                case .Failure(let error):
                    print("commit failed : \(error)")
                }
            })
            
            safeSelf.taskDequeue(withUrl: url)
            dispatch_group_leave(safeSelf.archiveGroup)
        }
        dispatch_group_notify(self.archiveGroup, dispatch_get_main_queue()) {
            finished(success: true, errorReason: nil)
        }
    }
}

extension WebarchiveManager {
    
    func downloadArticles(articles: [Article], progress: ArticleDownloadProgress, completion: ArticleDwonloadCompletionHandler) {
        
        var completedCount = 0
        let totalCount = articles.count
        let updateProgress = {
            completedCount += 1
            progress(completedTaskCount: completedCount, totalTaskCount: totalCount)
        }
        
//        let articleGroup = dispatch_group_create()
        let articleQueue = dispatch_queue_create("com.bf.articleQueue", DISPATCH_QUEUE_SERIAL)
        
        dispatch_apply(articles.count, articleQueue) { (index) in
            let semaphore = dispatch_semaphore_create(0)
            let article = articles[index]
            self.archive(url: NSURL(string: article.url!)!, fileName: FileManagerAdaptor.fileName(withWebarhiveId: article.artileId!), finished: { (success, errorReason) in
                updateProgress()
                dispatch_semaphore_signal(semaphore)
            })
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        }
        
        completion()
        
//        for article in articles {
//            dispatch_group_async(articleGroup, articleQueue, {
//                let semaphore = dispatch_semaphore_create(0)
//                self.archive(url: NSURL(string: article.url!)!, fileName: FileManagerAdaptor.fileName(withWebarhiveId: article.artileId!), finished: { (success, errorReason) in
//                    updateProgress()
//                    dispatch_semaphore_signal(semaphore)
//                })
//                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//            })
//        }
//        dispatch_group_notify(articleGroup, articleQueue) { 
//            completion()
//        }
    }
}
