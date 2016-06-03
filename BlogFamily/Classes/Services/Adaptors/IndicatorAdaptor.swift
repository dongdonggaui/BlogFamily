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

public struct IndicatorAdaptor {
    
    static func showErrorAlert(inViewController viewController: UIViewController, message: String? = nil) {
        
        let alert = UIAlertController(title: "Error", message: message ?? "There is a error", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    static func whistleLoading(withMessage message: String = "loading") {
        dispatch_async_safely_to_main_queue {
            Whistle(Murmur(title: message), action: .Present)
        }
    }
    
    static func whistleCalm(withMessage message: String? = nil) {
        dispatch_async_safely_to_main_queue {
            if let message = message {
                Whistle(Murmur(title: message))
            } else {
                Calm()
            }
        }
    }
    
    static func toast(message message:String) {
        JLToast.makeText(message).show()
    }
}
