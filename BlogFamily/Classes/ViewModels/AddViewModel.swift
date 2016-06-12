//
//  AddViewModel.swift
//  BlogFamily
//
//  Created by huangluyang on 16/6/7.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import Foundation
import UIKit
import CoreStore

protocol AddConfiguable {
    var titlePlaceholder: String {get}
    var subtitlePlaceholder: String {get}
    var titleNilMessage: String {get}
    var subtitleNilMessage: String {get}
    var subtitleInvalidMessage: String {get}
    var subtitleKey: String {get}
    func submitWithTitle(title: String, subtitle: String, handler: () -> ())
}

class AddBlogViewModel: AddConfiguable {
    var titlePlaceholder = "添加标题"
    var subtitlePlaceholder = "添加专栏链接"
    var titleNilMessage = "标题不能为空"
    var subtitleNilMessage = "专栏链接不能为空"
    var subtitleInvalidMessage = "请输入有效的专栏链接"
    var subtitleKey = "url"
    
    func submitWithTitle(title: String, subtitle: String, handler: () -> ()) {
        
        ModelManager.dataStack.beginAsynchronous { (transaction) in
            
            guard transaction.fetchOne(From(Blog), Where("url", isEqualTo: subtitle)) == nil else {
                IndicatorAdaptor.toast(message: NSLocalizedString("已经添加过了", comment: "已经添加过了"))
                return
            }
            
            let blog = transaction.create(Into(Blog))
            blog.blogId = NSUUID().UUIDString
            blog.title = title
            blog.url = subtitle
            blog.addDate = NSDate()
            
            transaction.commit({ (result) in
                dispatch_async_safely_to_main_queue({
                    switch result {
                    case .Success:
                        IndicatorAdaptor.toast(message: NSLocalizedString("添加成功", comment: "添加成功"))
                    case .Failure:
                        IndicatorAdaptor.toast(message: NSLocalizedString("添加失败", comment: "添加失败"))
                    }
                    handler()
                })
            })
        }
    }
}

class AddFeedViewModel: AddConfiguable {
    var titlePlaceholder = "添加标题"
    var subtitlePlaceholder = "添加订阅种子链接"
    var titleNilMessage = "标题不能为空"
    var subtitleNilMessage = "种子链接不能为空"
    var subtitleInvalidMessage = "请输入有效的种子链接"
    var subtitleKey = "feed"
    
    func submitWithTitle(title: String, subtitle: String, handler: () -> ()) {
        
        ModelManager.dataStack.beginAsynchronous { (transaction) in
            
            guard transaction.fetchOne(From(Feed), Where("url", isEqualTo: subtitle)) == nil else {
                IndicatorAdaptor.toast(message: NSLocalizedString("已经添加过了", comment: "已经添加过了"))
                return
            }
            
            let feed = transaction.create(Into(Feed))
            feed.feedId = NSUUID().UUIDString
            feed.title = title
            feed.url = subtitle
            feed.addDate = NSDate()
            
            transaction.commit({ (result) in
                dispatch_async_safely_to_main_queue({
                    switch result {
                    case .Success:
                        IndicatorAdaptor.toast(message: NSLocalizedString("添加成功", comment: "添加成功"))
                    case .Failure:
                        IndicatorAdaptor.toast(message: NSLocalizedString("添加失败", comment: "添加失败"))
                    }
                    handler()
                })
            })
        }
    }
}