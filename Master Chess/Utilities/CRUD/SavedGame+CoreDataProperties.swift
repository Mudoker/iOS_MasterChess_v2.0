//
//  SavedGame+CoreDataProperties.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 17/08/2023.
//
//

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
    @NSManaged public var isCheck: Bool
    @NSManaged public var language: String?
    @NSManaged public var moveAvailable: Int16
    @NSManaged public var whiteTimeLeft: Double
    @NSManaged public var isWhiteKingMoved: Bool
    @NSManaged public var isBlackKingMoved: Bool
    @NSManaged public var isWhiteLeftRookMoved: Bool
    @NSManaged public var isWhiteRightRookMoved: Bool
    @NSManaged public var isBlackLeftRookMoved: Bool
    @NSManaged public var isBlackRightRookMoved: Bool
    @NSManaged public var kingPosition: Int16
    @NSManaged public var source: Users?
    @NSManaged public var history: NSSet?

    public var unwrappedDifficulty: String {
        difficulty ?? ""
    }
    
    public var unwrappedLanguage: String {
        language ?? ""
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
    
    public var unwrappedIsCheck: Bool {
        isCheck
    }
    
    public var unwrappedBlackTimeLeft: Double {
        blackTimeLeft
    }
    
    public var unwrappedCurrentPlayer: String {
        currentPlayer ?? ""
    }

    public var unwrappedHistory: [Movement] {
        let historyArray = history?.allObjects as? [Movement] ?? []
        return historyArray
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
