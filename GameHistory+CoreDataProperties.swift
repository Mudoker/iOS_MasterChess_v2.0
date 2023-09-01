//
//  GameHistory+CoreDataProperties.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 12/08/2023.
//
//

import Foundation
import CoreData


extension GameHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameHistory> {
        return NSFetchRequest<GameHistory>(entityName: "GameHistory")
    }

    @NSManaged public var datePlayed: Date?
    @NSManaged public var gameID: UUID?
    @NSManaged public var gameLength: Int16
    @NSManaged public var opponentUsername: String?
    @NSManaged public var outcome: String?
    @NSManaged public var userColor: Bool
    @NSManaged public var userRatingChange: Int16
    @NSManaged public var source: Users?
    public var unwrappedDatePlayed: Date {
           datePlayed ?? Date()
       }
       
       public var unwrappedGameID: UUID {
           gameID ?? UUID()
       }
       
       public var unwrappedGameLength: Int {
           Int(gameLength)
       }
       
       public var unwrappedOpponentUsername: String {
           opponentUsername ?? ""
       }
       
       public var unwrappedOutcome: String {
           outcome ?? ""
       }
       
       public var unwrappedUserColor: Bool {
           userColor
       }
       
       public var unwrappedUserRatingChange: Int {
           Int(userRatingChange)
       }
       
       public var unwrappedSource: Users? {
           source
       }
}

extension GameHistory : Identifiable {

}
