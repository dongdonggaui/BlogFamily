//
//  Tag+CoreDataProperties.swift
//  BlogFamily
//
//  Created by huangluyang on 16/6/3.
//  Copyright © 2016年 huangluyang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Tag {

    @NSManaged var name: String?
    @NSManaged var articles: NSSet?

}
