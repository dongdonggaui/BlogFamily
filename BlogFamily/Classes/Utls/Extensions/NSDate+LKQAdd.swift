//
//  NSDate+LKQAdd.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/18.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import Foundation

public extension NSDate {
    
    private var sharedStandardDisplayFormatter: NSDateFormatter {
        get {
            struct Static {
                static var onceToken : dispatch_once_t = 0
                static var standardDisplayFormatter : NSDateFormatter? = nil
            }
            
            dispatch_once(&Static.onceToken) {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                Static.standardDisplayFormatter = formatter
            }
            
            return Static.standardDisplayFormatter!
        }
    }
    
    private var sharedISO8601GMTFormatter: NSDateFormatter {
        get {
            struct Static {
                static var onceToken : dispatch_once_t = 0
                static var standardDisplayFormatter : NSDateFormatter? = nil
            }
            
            dispatch_once(&Static.onceToken) {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
                Static.standardDisplayFormatter = formatter
            }
            
            return Static.standardDisplayFormatter!
        }
    }
    
    public func lkq_standardDisplayDate() -> String! {
        
        return self.sharedStandardDisplayFormatter.stringFromDate(self)
    }
}
