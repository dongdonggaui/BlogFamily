//
//  Blog.swift
//  
//
//  Created by huangluyang on 16/5/17.
//
//

import Foundation
import CoreData
import LeeGo

class Blog: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension Blog {
    
    @objc dynamic var subtitle: String? {
        
        get {
            let kvcKey = "subtitle"
            if let subtitle = self.accessValueForKVCKey(kvcKey) as? String {
                return subtitle
            }
            
            if let subtitle = self.url {
                self.setPrimitiveValue(subtitle, forKey: kvcKey)
                return subtitle
            }
            
            return nil
        }
        
        set {
            self.setValue(newValue, forKVCKey: "subtitle")
        }
    }
    
    @objc dynamic var beginCharacter: String? {
        
        get {
            let kvcKey = "beginCharacter"
            if let beginCharacter = self.accessValueForKVCKey(kvcKey) as? String {
                return beginCharacter
            }
            
            if let title = self.title {
                let indexKey = title.substringToIndex(title.startIndex)
                self.setPrimitiveValue(indexKey, forKey: kvcKey)
                return indexKey
            }
            
            return nil
        }
        
        set {
            self.setValue(newValue, forKVCKey: "beginCharacter")
        }
    }
}

extension Blog: BrickDataSource {
    func update(targetView: UIView, with brick: Brick) {
        switch targetView {
        case let titleLabel as UILabel where brick == BlogBrick.title:
            titleLabel.text = self.title;
        case let subtitleLabel as UILabel where brick == BlogBrick.subtitle:
            subtitleLabel.text = self.subtitle
        case let timeIcon as UIImageView where brick == BlogBrick.timeIcon:
            timeIcon.image = Resourse.clockImage()
        case let timeLabel as UILabel where brick == BlogBrick.timeLabel:
            timeLabel.text = self.addDate?.lkq_standardDisplayDate()
        default:
            print("unsupported view : \(targetView)")
        }
    }
}
