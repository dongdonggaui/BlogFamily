//
//  String+LKQAdd.swift
//  BlogFamily
//
//  Created by huangluyang on 16/6/3.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import Foundation

extension String {
    func lkq_stringByClearHTMLElements() -> String {
        var s = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) as NSString
        do {
            let regex = try NSRegularExpression(pattern: "<[^>]+>", options: .CaseInsensitive)
            s = regex.stringByReplacingMatchesInString(s as String, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, s.length), withTemplate: "")
        } catch {
            print("clear html error")
        }
        
        return s as String
    }
}
