//
//  ErrorAdaptor.swift
//  BlogFamily
//
//  Created by huangluyang on 16/6/2.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import Foundation

enum ErrorCode: Int {
    case UnKnown = 9999
    case FeedParseError = 100
}

let AppErrorDomain = "com.hly.appError"
let AppErrorUnknown = "UnKnown"

struct ErrorAdaptor {
    static func appErrorWith(code: ErrorCode, description: String? = nil) -> NSError {
        let error = NSError(domain: AppErrorDomain, code: code.rawValue, userInfo: [NSLocalizedDescriptionKey: description ?? AppErrorUnknown])
        return error
    }
}
