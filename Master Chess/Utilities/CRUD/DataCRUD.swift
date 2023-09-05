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

import SwiftUI
import CoreData

struct CRUD: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: []) var users: FetchedResults<Users>
    @FetchRequest(sortDescriptors: []) var achievements: FetchedResults<Achievement>

    public func createUser(username: String, password: String, profilePicture: String, setting: Setting) {
        let user = Users(context: viewContext)
        user.username = username
        user.userID = UUID()
        user.userSettings = setting
        user.joinDate = Date()
        user.password = password
        user.profilePicture = profilePicture
        
        do {
            try viewContext.save()
        } catch {
            print("Error creating user: \(error)")
        }
    }
    
    var body: some View {
        VStack {
            
            ForEach(users, id: \.self)
            {user in
                Section(user.unwrappedUsername) {
                    if (!user.unwrappedUsername.isEmpty) {
                        ForEach(user.unwrappedAchievements, id: \.self) { achievement in
                            Text(achievement.title ?? "ok")
//                            Text(achievement.des)
                        }
                    }

                }
            }
            
            Button("Add users") {
//                let setting = Setting(context: viewContext)

//                user.userSettings = setting
//                setting.source?.username = "test crud"
//                setting.language = "Vietnamese"
//                let history1 = GameHistory(context: viewContext)
//                history1.opponentUsername = "kakashi"
//                history1.source?.username = "test crud"
//                let history2 = GameHistory(context: viewContext)
//                history2.opponentUsername = "naruto"
//                history2.source?.username = "test crud"
//                user.addToUserHistory(history1)
//                user.addToUserHistory(history2)
                let user1 = Users(context: viewContext)
                user1.username = "Quoc 1"
                user1.userID = UUID()
                user1.userSettings = Setting(context: viewContext)
                user1.joinDate = Date()
                user1.password = "1"
                user1.profilePicture = "profile4"
                user1.addToUserAchievement( Achievement(context: viewContext))
                user1.addToUserHistory( GameHistory(context: viewContext))
                user1.userStats = GameStats(context: viewContext)
                user1.hasActiveGame = false
                
                let user2 = Users(context: viewContext)
                user2.username = "Quoc 2"
                user2.userID = UUID()
                user2.userSettings = Setting(context: viewContext)
                user2.joinDate = Date()
                user2.password = "1"
                user2.profilePicture = "profile2"
                user2.addToUserAchievement( Achievement(context: viewContext))
                user2.addToUserHistory( GameHistory(context: viewContext))
                user2.userStats = GameStats(context: viewContext)
                user2.hasActiveGame = false
                
                let user3 = Users(context: viewContext)
                user3.username = "Quoc 3"
                user3.userID = UUID()
                user3.userSettings = Setting(context: viewContext)
                user3.joinDate = Date()
                user3.password = "1"
                user3.profilePicture = "profile1"
                user3.addToUserAchievement( Achievement(context: viewContext))
                user3.addToUserHistory( GameHistory(context: viewContext))
                user3.userStats = GameStats(context: viewContext)
                user3.hasActiveGame = false
                
                let achivement1 = Achievement(context: viewContext)
                achivement1.category = "Common"
                achivement1.des = "First time login!"
                achivement1.points = 20
                achivement1.progress = 0
                achivement1.targetProgress = 1
                achivement1.title = "First Step"
                achivement1.unlocked = false
                achivement1.unlockDate = Date()
                achivement1.id = UUID()
                achivement1.icon = "firstLogin"

                let achivement2 = Achievement(context: viewContext)
                achivement2.category = "Elite"
                achivement2.des = "Top 1 on the leaderboard!"
                achivement2.points = 2000
                achivement2.progress = 0
                achivement2.targetProgress = 1
                achivement2.title = "Top 1"
                achivement2.icon = "rank1"
                achivement2.unlocked = false
                achivement2.unlockDate = Date()
                achivement2.id = UUID()

                let achivement3 = Achievement(context: viewContext)
                achivement3.category = "Elite"
                achivement3.des = "Top 2 on the leaderboard!"
                achivement3.points = 1500
                achivement3.progress = 0
                achivement3.targetProgress = 1
                achivement3.title = "Top 2"
                achivement3.icon = "rank2"
                achivement3.unlocked = false
                achivement3.unlockDate = Date()
                achivement3.id = UUID()

                let achivement4 = Achievement(context: viewContext)
                achivement4.category = "Elite"
                achivement4.des = "Top 3 on the leaderboard!"
                achivement4.points = 1000
                achivement4.progress = 0
                achivement4.targetProgress = 1
                achivement4.title = "Top 3"
                achivement4.icon = "rank3"
                achivement4.unlocked = false
                achivement4.unlockDate = Date()
                achivement4.id = UUID()

                let achivement5 = Achievement(context: viewContext)
                achivement5.category = "Common"
                achivement5.des = "Play 1 game!"
                achivement5.points = 10
                achivement5.progress = 0
                achivement5.targetProgress = 1
                achivement5.title = "Get's started"
                achivement5.icon = "play1"
                achivement5.unlocked = false
                achivement5.unlockDate = Date()
                achivement5.id = UUID()

                let achivement6 = Achievement(context: viewContext)
                achivement6.category = "Common"
                achivement6.des = "Play 5 game!"
                achivement6.points = 30
                achivement6.progress = 0
                achivement6.targetProgress = 5
                achivement6.title = "Game Lover"
                achivement6.icon = "play5"
                achivement6.unlocked = false
                achivement6.unlockDate = Date()
                achivement6.id = UUID()

                let achivement7 = Achievement(context: viewContext)
                achivement7.category = "Common"
                achivement7.des = "Play 10 game!"
                achivement7.points = 150
                achivement7.progress = 0
                achivement7.targetProgress = 10
                achivement7.title = "Friend with AI"
                achivement7.icon = "play10"
                achivement7.unlocked = false
                achivement7.unlockDate = Date()
                achivement7.id = UUID()

                let achivement8 = Achievement(context: viewContext)
                achivement8.category = "Uncommon"
                achivement8.des = "Play 20 game!"
                achivement8.points = 250
                achivement8.progress = 0
                achivement8.targetProgress = 20
                achivement8.title = "The Challenger"
                achivement8.icon = "play20"
                achivement8.unlocked = false
                achivement8.unlockDate = Date()
                achivement8.id = UUID()

                let achivement9 = Achievement(context: viewContext)
                achivement9.category = "Rare"
                achivement9.des = "Play 50 game!"
                achivement9.points = 150
                achivement9.progress = 0
                achivement9.targetProgress = 50
                achivement9.title = "AI Killer"
                achivement9.icon = "play50"
                achivement9.unlocked = false
                achivement9.unlockDate = Date()
                achivement9.id = UUID()

                let achivement10 = Achievement(context: viewContext)
                achivement10.category = "Common"
                achivement10.des = "Reach Newbie ranking"
                achivement10.points = 100
                achivement10.progress = 0
                achivement10.targetProgress = 800
                achivement10.title = "Newbie"
                achivement10.icon = "newbie"
                achivement10.unlocked = false
                achivement10.unlockDate = Date()
                achivement10.id = UUID()

                let achivement11 = Achievement(context: viewContext)
                achivement11.category = "Uncommon"
                achivement11.des = "Reach Pro ranking"
                achivement11.points = 500
                achivement11.progress = 0
                achivement11.targetProgress = 1300
                achivement11.title = "Pro Player"
                achivement11.icon = "pro"
                achivement11.unlocked = false
                achivement11.unlockDate = Date()
                achivement11.id = UUID()

                let achivement12 = Achievement(context: viewContext)
                achivement12.category = "Rare"
                achivement12.des = "Reach Master ranking"
                achivement12.points = 1000
                achivement12.progress = 0
                achivement12.targetProgress = 1600
                achivement12.title = "Master"
                achivement12.icon = "master"
                achivement12.unlocked = false
                achivement12.unlockDate = Date()
                achivement12.id = UUID()

                let achivement13 = Achievement(context: viewContext)
                achivement13.category = "Rare"
                achivement13.des = "Reach Grand Master ranking"
                achivement13.points = 1000
                achivement13.progress = 0
                achivement13.targetProgress = 1600
                achivement13.title = "Grand Master"
                achivement13.icon = "gmaster"
                achivement13.unlocked = false
                achivement13.unlockDate = Date()
                achivement13.id = UUID()

                let achivement14 = Achievement(context: viewContext)
                achivement14.category = "Rare"
                achivement14.des = "Win in 5 minutes"
                achivement14.points = 1000
                achivement14.progress = 0
                achivement14.targetProgress = 1
                achivement14.title = "The Flash"
                achivement14.icon = "winfast"
                achivement14.unlocked = false
                achivement14.unlockDate = Date()
                achivement14.id = UUID()

                let achivement15 = Achievement(context: viewContext)
                achivement15.category = "Rare"
                achivement15.des = "Win in the last 1 minutes"
                achivement15.points = 1000
                achivement15.progress = 0
                achivement15.targetProgress = 1
                achivement15.title = "Turn the Tables"
                achivement15.icon = "winlong"
                achivement15.unlocked = false
                achivement15.unlockDate = Date()
                achivement15.id = UUID()
//
                
                try? viewContext.save()
            }
            Button("Add achievement") {
//                let achivement1 = Achievement(context: viewContext)
//                achivement1.category = "Common"
//                achivement1.des = "First time login!"
//                achivement1.points = 20
//                achivement1.progress = 0
//                achivement1.targetProgress = 1
//                achivement1.title = "First Step"
//                achivement1.unlocked = false
//                achivement1.unlockDate = Date()
//                achivement1.id = UUID()
//                achivement1.icon = "firstLogin"
//
//                let achivement2 = Achievement(context: viewContext)
//                achivement2.category = "Elite"
//                achivement2.des = "Top 1 on the leaderboard!"
//                achivement2.points = 2000
//                achivement2.progress = 0
//                achivement2.targetProgress = 1
//                achivement2.title = "Top 1"
//                achivement2.icon = "rank1"
//                achivement2.unlocked = false
//                achivement2.unlockDate = Date()
//                achivement2.id = UUID()
//
//                let achivement3 = Achievement(context: viewContext)
//                achivement3.category = "Elite"
//                achivement3.des = "Top 2 on the leaderboard!"
//                achivement3.points = 1500
//                achivement3.progress = 0
//                achivement3.targetProgress = 1
//                achivement3.title = "Top 2"
//                achivement3.icon = "rank2"
//                achivement3.unlocked = false
//                achivement3.unlockDate = Date()
//                achivement3.id = UUID()
//
//                let achivement4 = Achievement(context: viewContext)
//                achivement4.category = "Elite"
//                achivement4.des = "Top 3 on the leaderboard!"
//                achivement4.points = 1000
//                achivement4.progress = 0
//                achivement4.targetProgress = 1
//                achivement4.title = "Top 3"
//                achivement4.icon = "rank3"
//                achivement4.unlocked = false
//                achivement4.unlockDate = Date()
//                achivement4.id = UUID()
//
//                let achivement5 = Achievement(context: viewContext)
//                achivement5.category = "Common"
//                achivement5.des = "Play 1 game!"
//                achivement5.points = 10
//                achivement5.progress = 0
//                achivement5.targetProgress = 1
//                achivement5.title = "Get's started"
//                achivement5.icon = "play1"
//                achivement5.unlocked = false
//                achivement5.unlockDate = Date()
//                achivement5.id = UUID()
//
//                let achivement6 = Achievement(context: viewContext)
//                achivement6.category = "Common"
//                achivement6.des = "Play 5 game!"
//                achivement6.points = 30
//                achivement6.progress = 0
//                achivement6.targetProgress = 5
//                achivement6.title = "Game Lover"
//                achivement6.icon = "play5"
//                achivement6.unlocked = false
//                achivement6.unlockDate = Date()
//                achivement6.id = UUID()
//
//                let achivement7 = Achievement(context: viewContext)
//                achivement7.category = "Common"
//                achivement7.des = "Play 10 game!"
//                achivement7.points = 150
//                achivement7.progress = 0
//                achivement7.targetProgress = 10
//                achivement7.title = "Friend with AI"
//                achivement7.icon = "play10"
//                achivement7.unlocked = false
//                achivement7.unlockDate = Date()
//                achivement7.id = UUID()
//
//                let achivement8 = Achievement(context: viewContext)
//                achivement8.category = "Uncommon"
//                achivement8.des = "Play 20 game!"
//                achivement8.points = 250
//                achivement8.progress = 0
//                achivement8.targetProgress = 20
//                achivement8.title = "The Challenger"
//                achivement8.icon = "play20"
//                achivement8.unlocked = false
//                achivement8.unlockDate = Date()
//                achivement8.id = UUID()
//
//                let achivement9 = Achievement(context: viewContext)
//                achivement9.category = "Rare"
//                achivement9.des = "Play 50 game!"
//                achivement9.points = 150
//                achivement9.progress = 0
//                achivement9.targetProgress = 50
//                achivement9.title = "AI Killer"
//                achivement9.icon = "play50"
//                achivement9.unlocked = false
//                achivement9.unlockDate = Date()
//                achivement9.id = UUID()
//
//                let achivement10 = Achievement(context: viewContext)
//                achivement10.category = "Common"
//                achivement10.des = "Reach Newbie ranking"
//                achivement10.points = 100
//                achivement10.progress = 0
//                achivement10.targetProgress = 800
//                achivement10.title = "Newbie"
//                achivement10.icon = "newbie"
//                achivement10.unlocked = false
//                achivement10.unlockDate = Date()
//                achivement10.id = UUID()
//
//                let achivement11 = Achievement(context: viewContext)
//                achivement11.category = "Uncommon"
//                achivement11.des = "Reach Pro ranking"
//                achivement11.points = 500
//                achivement11.progress = 0
//                achivement11.targetProgress = 1300
//                achivement11.title = "Pro Player"
//                achivement11.icon = "pro"
//                achivement11.unlocked = false
//                achivement11.unlockDate = Date()
//                achivement11.id = UUID()
//
//                let achivement12 = Achievement(context: viewContext)
//                achivement12.category = "Rare"
//                achivement12.des = "Reach Master ranking"
//                achivement12.points = 1000
//                achivement12.progress = 0
//                achivement12.targetProgress = 1600
//                achivement12.title = "Master"
//                achivement12.icon = "master"
//                achivement12.unlocked = false
//                achivement12.unlockDate = Date()
//                achivement12.id = UUID()
//
//                let achivement13 = Achievement(context: viewContext)
//                achivement13.category = "Rare"
//                achivement13.des = "Reach Grand Master ranking"
//                achivement13.points = 1000
//                achivement13.progress = 0
//                achivement13.targetProgress = 1600
//                achivement13.title = "Grand Master"
//                achivement13.icon = "gmaster"
//                achivement13.unlocked = false
//                achivement13.unlockDate = Date()
//                achivement13.id = UUID()
//
//                let achivement14 = Achievement(context: viewContext)
//                achivement14.category = "Rare"
//                achivement14.des = "Win in 5 minutes"
//                achivement14.points = 1000
//                achivement14.progress = 0
//                achivement14.targetProgress = 1
//                achivement14.title = "The Flash"
//                achivement14.icon = "winfast"
//                achivement14.unlocked = false
//                achivement14.unlockDate = Date()
//                achivement14.id = UUID()
//
//                let achivement15 = Achievement(context: viewContext)
//                achivement15.category = "Rare"
//                achivement15.des = "Win in the last 1 minutes"
//                achivement15.points = 1000
//                achivement15.progress = 0
//                achivement15.targetProgress = 1
//                achivement15.title = "Turn the Tables"
//                achivement15.icon = "winlong"
//                achivement15.unlocked = false
//                achivement15.unlockDate = Date()
//                achivement15.id = UUID()
//
//                user.addToUserHistory(achivement15)
//                user.addToUserHistory(achivement14)
//                user.addToUserHistory(achivement13)
//                user.addToUserHistory(achivement12)
                
                try? viewContext.save()
            }
            
            Button("Reset Achiement") {
                // Fetch the managed object context
                let context = viewContext

                do {
                    // Fetch all Users from Core Data
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Achievement.fetchRequest()
                    let achievements = try context.fetch(fetchRequest) as! [NSManagedObject]

                    // Delete each user object
                    for achievement in achievements {
                        context.delete(achievement)
                    }

                    // Save the changes to Core Data
                    try context.save()
                } catch {
                    // Handle any errors that occur during deletion or saving
                    print("Error resetting data: \(error)")
                }
            }
            Button("Reset") {
                // Fetch the managed object context
                let context = viewContext

                do {
                    // Fetch all Users from Core Data
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Users.fetchRequest()
                    let users = try context.fetch(fetchRequest) as! [NSManagedObject]

                    // Delete each user object
                    for user in users {
                        context.delete(user)
                    }

                    // Save the changes to Core Data
                    try context.save()
                } catch {
                    // Handle any errors that occur during deletion or saving
                    print("Error resetting data: \(error)")
                }
            }

            
            Button("Update users") {
                var userUpdated = false
                for index in users.indices {
                    if users[index].username == "hehe" {
                        users[index].username = "quoc"
                        userUpdated = true
                        break
                    }
                }

                if userUpdated {
                    do {
                        try viewContext.save()
                    } catch {
                        // Handle the error appropriately
                        print("Error saving context: \(error)")
                    }
                }
            }

        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

//struct sdf: PreviewProvider {
//    static var previews: some View {
//        CRUD()
//    }
//}


