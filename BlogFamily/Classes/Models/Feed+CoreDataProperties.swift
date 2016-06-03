//
//  Feed+CoreDataProperties.swift
//  BlogFamily
//
//  Created by huangluyang on 16/6/2.
//  Copyright © 2016年 huangluyang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Feed {

    @NSManaged var addDate: NSDate?
    @NSManaged var feedId: String?
    @NSManaged var title: String?
    @NSManaged var updateDate: NSDate?
    @NSManaged var url: String?
    @NSManaged var syncDate: NSDate?
    @NSManaged var articles: NSSet?

}
