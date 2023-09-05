/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 9/08/2023
 Last modified: 9/08/2023
 Acknowledgement:
 */

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
