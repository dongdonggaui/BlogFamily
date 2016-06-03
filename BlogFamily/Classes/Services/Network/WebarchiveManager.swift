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
    private func addArchiveTask(withUrl url: NSURL, completionHandler: WebarchiveCompletionHandler) {
        dispatch_async(downloadQueue) {

            self.totalTaskCountIncrement()
            
            IndicatorAdaptor.whistleLoading(withMessage: "下载中...\(self.completedTaskCount)/\(self.totalTaskCount)")
            
            let semaphore = dispatch_semaphore_create(0)
            
            Archiver.archiveWebpageFormUrl(url) { (webarchiveData, metaData, error) in
                
                let fileName = FileManagerAdaptor.generateWebarchiveName()
                
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
    
    func archive(url url: NSURL, feed: Feed? = nil, finished: WebarchiveFinished) {
        
        if url.absoluteString.hasPrefix("file://") {
            IndicatorAdaptor.toast(message: "已经下载过啦")
            return
        }
        
        if self.currentTasks.contains(url) {
            finished(success: false, errorReason: "该任务正在下载中，请勿重复添加")
            return
        }
        var exist = false
        ModelManager.dataStack.beginSynchronous { (transaction) in
            let article = transaction.fetchOne(From(Article), Where("url", isEqualTo: url.absoluteString))
            exist = article != nil
        }
        if exist {
            finished(success: false, errorReason: "已经下载过啦")
            return
        }
        self.taskEnqueue(withUrl: url)
        dispatch_group_enter(archiveGroup)
        self.addArchiveTask(withUrl: url) { [weak self] (archivedPath, title, error) in
            guard let safeSelf = self else {
                return
            }
            guard let fileName = archivedPath else {
                safeSelf.taskDequeue(withUrl: url)
                dispatch_group_leave(safeSelf.archiveGroup)
                return
            }
            
            ModelManager.dataStack.beginAsynchronous({ (transaction) in
                let article = transaction.create(Into(Article))
                article.artileId = FileManagerAdaptor.webarchiveId(withFileName: fileName)
                article.archivePath = fileName
                article.url = url.absoluteString
                article.title = title
                if feed != nil {
                    let feed = transaction.edit(feed)
                    article.feed = feed
                }
                transaction.commit()
            })
            
            safeSelf.taskDequeue(withUrl: url)
            dispatch_group_leave(safeSelf.archiveGroup)
        }
        dispatch_group_notify(self.archiveGroup, dispatch_get_main_queue()) {
            finished(success: true, errorReason: nil)
        }
    }
}
