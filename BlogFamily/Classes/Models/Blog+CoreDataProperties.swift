//
//  Blog+CoreDataProperties.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/17.
//  Copyright © 2016年 huangluyang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import CoreStore

extension Blog {

    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var addDate: NSDate?
    @NSManaged var blogId: String?

}
