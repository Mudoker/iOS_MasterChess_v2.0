//
//  GameStats+CoreDataProperties.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 10/08/2023.
//
//

import Foundation
import CoreData


extension GameStats {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameStats> {
        return NSFetchRequest<GameStats>(entityName: "GameStats")
    }

    @NSManaged public var draws: Int32
    @NSManaged public var losses: Int32
    @NSManaged public var totalGames: Int32
    @NSManaged public var winRate: Double
    @NSManaged public var wins: Int32
    @NSManaged public var source: Users?

    public var unwrappedDraws: Int {
        Int(draws)
    }
    
    public var unwrappedLosses: Int {
        Int(losses)
    }
    
    public var unwrappedTotalGames: Int {
        Int(totalGames)
    }
    
    public var unwrappedWinRate: Double {
        winRate
    }
    
    public var unwrappedWins: Int {
        Int(wins)
    }
    
    public var unwrappedSource: Users? {
        source
    }
}

extension GameStats : Identifiable {

}
