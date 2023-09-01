//
//  Test+CoreDataProperties.swift
//  Master Chess
//
//  Created by quoc on 31/08/2023.
//
//

import Foundation
import CoreData


extension Test {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Test> {
        return NSFetchRequest<Test>(entityName: "Test")
    }

    @NSManaged public var age: Int16
    @NSManaged public var gender: String?
    @NSManaged public var name: String?

}

extension Test : Identifiable {

}
