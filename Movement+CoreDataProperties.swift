//
//  Movement+CoreDataProperties.swift
//  Master Chess
//
//  Created by quoc on 01/09/2023.
//
//

import Foundation
import CoreData


extension Movement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movement> {
        return NSFetchRequest<Movement>(entityName: "Movement")
    }

    @NSManaged public var end: Int16
    @NSManaged public var start: Int16
    @NSManaged public var order: Int16
    @NSManaged public var source: SavedGame?

}

extension Movement : Identifiable {

}
