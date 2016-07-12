//
//  LogAdaptor.swift
//  BlogFamily
//
//  Created by huangluyang on 16/7/12.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import Foundation

public struct LogAdaptor {
    public static func printLog<T>(message: T,
                                file: String = #file,
                                method: String = #function,
                                line: Int = #line)
    {
        #if DEBUG
            print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
        #endif
    }
}
