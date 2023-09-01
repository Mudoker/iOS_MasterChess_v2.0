//
//  Achievement+CoreDataProperties.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 11/08/2023.
//
//

import Foundation
import CoreData


extension Achievement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Achievement> {
        return NSFetchRequest<Achievement>(entityName: "Achievement")
    }

    @NSManaged public var category: String?
    @NSManaged public var des: String?
    @NSManaged public var icon: String?
    @NSManaged public var id: UUID?
    @NSManaged public var points: Int16
    @NSManaged public var progress: Int32
    @NSManaged public var targetProgress: Int32
    @NSManaged public var title: String?
    @NSManaged public var unlockDate: Date?
    @NSManaged public var unlocked: Bool
    @NSManaged public var source: NSSet?
    public var unwrappedCategory: String {
            category ?? ""
    }

    public var unwrappedDescription: String {
            des ?? ""
    }

    public var unwrappedIcon: String {
            icon ?? ""
    }

    public var unwrappedID: UUID {
            id ?? UUID()
    }

    public var unwrappedTitle: String {
            title ?? ""
    }

    public var unwrappedUnlockDate: Date {
            unlockDate ?? Date()
    }

    public var unwrappedUnlocked: Bool {
            unlocked
    }
}

// MARK: Generated accessors for source
extension Achievement {

    @objc(addSourceObject:)
    @NSManaged public func addToSource(_ value: Users)

    @objc(removeSourceObject:)
    @NSManaged public func removeFromSource(_ value: Users)

    @objc(addSource:)
    @NSManaged public func addToSource(_ values: NSSet)

    @objc(removeSource:)
    @NSManaged public func removeFromSource(_ values: NSSet)

}
