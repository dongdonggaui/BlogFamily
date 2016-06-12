//
//  ResourceAdaptor.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/18.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import Foundation
import UIKit
import Rswift

public struct Resourse {
    
    static func clockImage() -> UIImage? {
        return R.image.clock()
    }
    
    static func icFeedImage() -> UIImage? {
        return R.image.icFeed()
    }
    
}

extension Resourse {
    
    static func blogListCell() -> String {
        return R.reuseIdentifier.blogListCell.identifier
    }
    
    static func articleListCell() -> String {
        return R.reuseIdentifier.articleListCell.identifier
    }
    
    static func rssCell() -> String {
        return R.reuseIdentifier.rssCell.identifier
    }
    
    static func rssContentCell() -> String {
        return R.reuseIdentifier.rssContentCell.identifier
    }
    
    static func suggestCell() -> String {
        return R.reuseIdentifier.suggestCell.identifier
    }
}
