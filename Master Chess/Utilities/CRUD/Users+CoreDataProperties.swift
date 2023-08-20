//
//  Users+CoreDataProperties.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 15/08/2023.
//
//

import Foundation
import CoreData


extension Users {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Users> {
        return NSFetchRequest<Users>(entityName: "Users")
    }

    @NSManaged public var joinDate: Date?
    @NSManaged public var password: String?
    @NSManaged public var profilePicture: String?
    @NSManaged public var ranking: Int16
    @NSManaged public var rating: Int16
    @NSManaged public var userID: UUID?
    @NSManaged public var username: String?
    @NSManaged public var hasActiveGame: Bool
    @NSManaged public var userAchievement: NSSet?
    @NSManaged public var userHistory: NSSet?
    @NSManaged public var userSettings: Setting?
    @NSManaged public var userStats: GameStats?
    @NSManaged public var savedGame: SavedGame?

    public var unwrappedJoinDate: Date {
                    joinDate ?? Date()
                }

    public var unwrappedPassword: String {
        password ?? ""
    }

    public var unwrappedProfilePicture: String {
        profilePicture ?? ""
    }

    public var unwrappedUserID: UUID {
        userID ?? UUID()
    }

    public var unwrappedUsername: String {
        username ?? ""
    }

    public var unwrappedAchievements: [Achievement] {
        let set = userAchievement as? Set<Achievement> ?? []
        
        return Array(set)
    }
    
    public var unwrappedGameHistory: [GameHistory] {
        let set = userHistory as? Set<GameHistory> ?? []
        
        return set.sorted {
            $0.unwrappedDatePlayed < $1.unwrappedDatePlayed
        }
    }
    
    public var unwrappedUserSetting: Setting {
            userSettings ?? Setting()
    }

    public var unwrappedUserStats: GameStats {
        userStats ?? GameStats()
    }
    
    public var unwrappedSavedGame: SavedGame {
        savedGame ?? SavedGame()
    }
}

// MARK: Generated accessors for userAchievement
extension Users {

    @objc(addUserAchievementObject:)
    @NSManaged public func addToUserAchievement(_ value: Achievement)

    @objc(removeUserAchievementObject:)
    @NSManaged public func removeFromUserAchievement(_ value: Achievement)

    @objc(addUserAchievement:)
    @NSManaged public func addToUserAchievement(_ values: NSSet)

    @objc(removeUserAchievement:)
    @NSManaged public func removeFromUserAchievement(_ values: NSSet)

}

// MARK: Generated accessors for userHistory
extension Users {

    @objc(addUserHistoryObject:)
    @NSManaged public func addToUserHistory(_ value: GameHistory)

    @objc(removeUserHistoryObject:)
    @NSManaged public func removeFromUserHistory(_ value: GameHistory)

    @objc(addUserHistory:)
    @NSManaged public func addToUserHistory(_ values: NSSet)

    @objc(removeUserHistory:)
    @NSManaged public func removeFromUserHistory(_ values: NSSet)

}

extension Users : Identifiable {

}
