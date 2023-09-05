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


extension SavedGame {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedGame> {
        return NSFetchRequest<SavedGame>(entityName: "SavedGame")
    }

    @NSManaged public var autoPromotionEnabled: Bool
    @NSManaged public var blackTimeLeft: Double
    @NSManaged public var boardSetup: [[String]]?
    @NSManaged public var currentPlayer: String?
    @NSManaged public var difficulty: String?
    @NSManaged public var isBlackKingMoved: Bool
    @NSManaged public var isBlackLeftRookMoved: Bool
    @NSManaged public var isBlackRightRookMoved: Bool
    @NSManaged public var isEnpassant: Bool
    @NSManaged public var isWhiteKingMoved: Bool
    @NSManaged public var isWhiteLeftRookMoved: Bool
    @NSManaged public var isWhiteRightRookMoved: Bool
    @NSManaged public var kingPosition: Int16
    @NSManaged public var moveAvailable: Int16
    @NSManaged public var whiteTimeLeft: Double
    @NSManaged public var captures: [String]?
    @NSManaged public var history: NSSet?
    @NSManaged public var source: Users?

    public var unwrappedDifficulty: String {
            difficulty ?? ""
        }
        
    public var unwrappedIsEnpassant: Bool {
        isEnpassant
    }
    public var unwrappedAutoPromotionEnabled: Bool {
        autoPromotionEnabled
    }
    
    public var unwrappedBoardSetup: [[String]] {
        boardSetup ?? [[]]
    }
    
    public var unwrappedWhiteTimeLeft: Double {
        whiteTimeLeft
    }
    
    public var unwrappedMoveAvailable: Int {
        Int(moveAvailable)
    }
    
    public var unwrappedBlackTimeLeft: Double {
        blackTimeLeft
    }
    
    public var unwrappedCurrentPlayer: String {
        currentPlayer ?? ""
    }
    
    public var unwrappedHistory: [Movement] {
        guard let set = history as? Set<Movement> else {
            return []
        }
        
        return Array(set)
    }
    public var unwrappedCaptures: [String] {
        captures ?? []
    }
}

// MARK: Generated accessors for history
extension SavedGame {

    @objc(addHistoryObject:)
    @NSManaged public func addToHistory(_ value: Movement)

    @objc(removeHistoryObject:)
    @NSManaged public func removeFromHistory(_ value: Movement)

    @objc(addHistory:)
    @NSManaged public func addToHistory(_ values: NSSet)

    @objc(removeHistory:)
    @NSManaged public func removeFromHistory(_ values: NSSet)

}

extension SavedGame : Identifiable {

}
