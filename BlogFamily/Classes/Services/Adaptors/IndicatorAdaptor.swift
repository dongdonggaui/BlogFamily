//
//  IndicatorAdaptor.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/17.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import Foundation
import UIKit
import Whisper
import JLToast

let whistle = WhistleFactory()

public struct IndicatorAdaptor {
    
    static func showErrorAlert(inViewController viewController: UIViewController, message: String? = nil) {
        
        let alert = UIAlertController(title: NSLocalizedString("错误", comment: "错误"), message: message ?? NSLocalizedString("发生错误", comment: "发生错误"), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: "确定"), style: .Cancel, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    static func whistleLoading(withMessage message: String = NSLocalizedString("加载中", comment: "加载中")) {
        dispatch_async_safely_to_main_queue {
            whistle.whistler(Murmur(title: message), action: .Present)
        }
    }
    
    static func updateWhistleLoading(withMessage message: String) {
        dispatch_async_safely_to_main_queue {
            whistle.titleLabel.text = message
        }
    }
    
    static func whistleCalm(withMessage message: String? = nil) {
        dispatch_async_safely_to_main_queue {
            if let message = message {
                whistle.titleLabel.text = message
            }
            whistle.calm(after: 0)
        }
    }
    
    static func toast(message message:String) {
        JLToast.makeText(message).show()
    }
}
