//
//  USDAItem.swift
//  FoodTracker
//
//  Created by Diego Valderrama on 6/17/15.
//  Copyright (c) 2015 Diego Valderrama. All rights reserved.
//

import Foundation
import CoreData

@objc (USDAItem)//To work with Objective C
class USDAItem: NSManagedObject {

    @NSManaged var calcium: String
    @NSManaged var carbohydrate: String
    @NSManaged var cholesterol: String
    @NSManaged var dateAdded: NSDate
    @NSManaged var energy: String
    @NSManaged var fatTotal: String
    @NSManaged var idValue: String
    @NSManaged var protein: String
    @NSManaged var name: String
    @NSManaged var sugar: String
    @NSManaged var vitaminC: String

}
