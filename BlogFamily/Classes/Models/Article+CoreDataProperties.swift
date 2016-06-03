//
//  Article+CoreDataProperties.swift
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

extension Article {

    @NSManaged var addDate: NSDate?
    @NSManaged var archivePath: String?
    @NSManaged var artileId: String?
    @NSManaged var author: String?
    @NSManaged var summary: String?
    @NSManaged var tags: String?
    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var imageUrl: String?
    @NSManaged var feed: Feed?

}
