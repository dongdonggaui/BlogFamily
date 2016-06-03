//
//  ModelManager.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/17.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import Foundation
import CoreStore

struct ModelManager {
    
    static let dataStack: DataStack = {
        
        let theDataStack = DataStack(modelName: "Model")
        try! theDataStack.addSQLiteStore(completion: { (store) in
            print("add \(store) completed")
        })
        
        return theDataStack
    }()
    
    static let blogs: ListMonitor<Blog> = {
        
        return dataStack.monitorList(
            From(Blog),
            OrderBy(.Descending("addDate"))
//            SectionBy("beginCharacter"),
//            OrderBy(.Ascending("title"))
        )
    }()
    
    static let feeds: ListMonitor<Feed> = {
        
        return dataStack.monitorList(
            From(Feed),
            OrderBy(.Descending("addDate"))
        )
    }()
    
    static let articles: ListMonitor<Article> = {
        
        return dataStack.monitorList(
            From(Article),
            OrderBy(.Descending("addDate"))
        )
    }()
}
