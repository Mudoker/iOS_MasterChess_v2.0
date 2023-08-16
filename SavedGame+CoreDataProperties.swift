//
//  SavedGame+CoreDataProperties.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 16/08/2023.
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
    @NSManaged public var boardSetup: NSArray?
    @NSManaged public var currentPlayer: String?
    @NSManaged public var difficulty: String?
    @NSManaged public var isCheck: Bool
    @NSManaged public var language: String?
    @NSManaged public var moveAvailable: Int16
    @NSManaged public var whiteTimeLeft: Double
    @NSManaged public var source: Users?
    public var unwrappedDifficulty: String {
                difficulty ?? ""
        }
        
    public var unwrappedLanguage: String {
        language ?? ""
    }
    
    public var unwrappedAutoPromotionEnabled: Bool {
            autoPromotionEnabled
    }
    
    public var unwrappedBoardSetup: NSArray {
        return boardSetup ?? []
    }
    
    public var unwrappedWhiteTimeLeft: Double {
        whiteTimeLeft
    }
    
    public var unwrappedMoveAvailable: Int16 {
        moveAvailable
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
}

extension SavedGame : Identifiable {

}
