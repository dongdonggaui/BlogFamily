//
//  BrickStore.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/18.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import Foundation
import LeeGo

protocol BrickConvertable {
    func brick() -> Brick
}


struct DefaultMetrics {
    static let compactView = LayoutMetrics(8, 8, 8, 8, 5, 5)
    static let compactTableViewCell = LayoutMetrics(5, 8, 5, 8, 5, 5)
    static let internalView = LayoutMetrics(0, 0, 0, 0, 5, 5)
}

struct Style {
    static let titleBasicStyle: [Appearance] = [.text("title"), .backgroundColor(UIColor(red: 0.921, green: 0.941, blue: 0.945, alpha: 1))]

    static let descriptionBasicStyle: [Appearance] = [.text("description"), .backgroundColor(UIColor(red: 0.921, green: 0.941, blue: 0.945, alpha: 1)), .textColor(UIColor.lightGrayColor()), .numberOfLines(0), .font(UIFont.systemFontOfSize(14))]

    static let blocksStyle: [Appearance] = [.backgroundColor(UIColor(red: 0.945, green: 0.769, blue: 0.0588, alpha: 1)), .cornerRadius(3)]
    static let redBlockStyle: [Appearance] = [.backgroundColor(UIColor(red: 0.906, green: 0.298, blue: 0.235, alpha: 1)), .cornerRadius(3)]
    static let greenBlockStyle: [Appearance] = [.backgroundColor(UIColor(red: 0.18, green: 0.8, blue: 0.443, alpha: 1)), .cornerRadius(3)]
    static let blueBlockStyle: [Appearance] = [.backgroundColor(UIColor(red: 0.204, green: 0.596, blue: 0.859, alpha: 1)), .cornerRadius(3)]
}

// MARK: BlogBrick

enum BlogBrick: BrickBuilderType {

    // 1. add type
    // leaf bricks
    case title, subtitle, timeIcon, timeLabel, titleInput, subtitleInput, urlInput

    // complex bricks
//    case retweetView, likeView
//    case accountHeader, toolbarFooter, retweetHeader

    // root bricks
    case blogListCell, addNewBlogView

    // 2. add reuse identifiers if needed
    static let reuseIdentifiers = [blogListCell].map { (component) -> String in
        return component.brickName
    }

    // 3. register UI class
    static let brickClass: [BlogBrick: AnyClass] = [
        title: UILabel.self,
        subtitle: UILabel.self,
        timeIcon: UIImageView.self,
        timeLabel: UILabel.self,
        titleInput: UITextField.self,
        subtitleInput: UITextField.self,
        urlInput: UITextField.self,
        blogListCell: UIView.self,
        addNewBlogView: UIView.self,
    ]
}

extension BlogBrick {

    func brick() -> Brick {
        switch self {
            
        case .title:
            return build().style([.font(UIFont.boldSystemFontOfSize(15))])
        case .subtitle:
            return build().style([.font(UIFont.systemFontOfSize(14))])
        case .timeIcon:
            return build().width(20)
        case .timeLabel:
            return build().style([.font(UIFont.systemFontOfSize(14)), .textColor(UIColor.lightGrayColor())])
        case .titleInput:
            return build().style([.font(UIFont.systemFontOfSize(14))])
        case .subtitleInput:
            return build().style([.font(UIFont.systemFontOfSize(14))])
        case .urlInput:
            return build().style([.font(UIFont.systemFontOfSize(14))])
            
        case .blogListCell:
            return Brick.union(brickName, bricks: [
                title.brick(),
                Brick.union(brickName, bricks: [
                    subtitle.brick(),
                    timeIcon.brick(),
                    timeLabel.brick(),
                    ], axis: .Horizontal, align: .Fill, distribution: .Fill, metrics: DefaultMetrics.internalView)
                ], axis: .Vertical, align: .Fill, distribution: .Fill, metrics: DefaultMetrics.compactTableViewCell)
            
        case .addNewBlogView:
            return Brick.union(brickName, bricks: [
                subtitleInput.brick(),
                urlInput.brick()
                ], axis: .Vertical, align: .Fill, distribution: .Fill, metrics: DefaultMetrics.compactView)
        }
    }
}
