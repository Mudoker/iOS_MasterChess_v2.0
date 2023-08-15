//
//  ContentView.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 09/08/2023.
//

import SwiftUI
import CoreData

struct CRUD: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: []) var users: FetchedResults<Users>
    
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
    
//    public func createSetting(autoPromotionEnabled: Bool, isDarkMode: Bool, language: String, musicEnabled: Bool, soundEnabled: Bool) -> Setting {
//        let setting = Setting(context: viewContext)
//        setting.autoPromotionEnabled = autoPromotionEnabled
//        setting.isDarkMode = isDarkMode
//        setting.language = language
//        setting.musicEnabled = musicEnabled
//        setting.soundEnabled = soundEnabled
//        return setting
//    }
    var body: some View {
        VStack {
            
            ForEach(users, id: \.self)
            {user in
                Section(user.unwrappedUsername) {
                    if (!user.unwrappedUsername.isEmpty) {
                        VStack {
                            Text(user.unwrappedPassword)
                            Text(user.unwrappedUserSetting.unwrappedDifficulty)
                            ForEach(user.unwrappedGameHistory, id:\.self) { history in
                                Text("ok")
                                Text(history.unwrappedOpponentUsername)
                            }
                        }
                    }
                    
                }
            }
            Button("Add users") {
                let setting = Setting(context: viewContext)

                let user = Users(context: viewContext)
                user.userSettings = setting
                setting.source?.username = "test crud"
                setting.language = "Vietnamese"
                let history1 = GameHistory(context: viewContext)
                history1.opponentUsername = "kakashi"
                history1.source?.username = "test crud"
                let history2 = GameHistory(context: viewContext)
                history2.opponentUsername = "naruto"
                history2.source?.username = "test crud"
                user.addToUserHistory(history1)
                user.addToUserHistory(history2)
                try? viewContext.save()
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


