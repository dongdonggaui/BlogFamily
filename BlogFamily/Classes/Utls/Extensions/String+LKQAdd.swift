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
            let regex = try NSRegularExpression(pattern: "<[\\s\\S]*>", options: .CaseInsensitive)
            let matches = regex.matchesInString(s as String, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, (s as NSString).length)) as NSArray
            matches.enumerateObjectsWithOptions(.Reverse, usingBlock: { (result, index, stop) in
                let result = result as! NSTextCheckingResult
                let replacement = s.substringWithRange(result.range)
                s = s.stringByReplacingOccurrencesOfString(replacement, withString: "")
            })
        } catch {
            print("clear html error")
        }
        
        return s as String
    }
}
