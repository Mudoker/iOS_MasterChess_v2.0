/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Doan Huu Quoc
  ID: 3927776
  Created  date: 09/08/2023
  Last modified: 05/09/2023
  Acknowledgement:
*/

import SwiftUI

@main
struct Master_ChessApp: App {
    // Core Date instance
    @StateObject private var dataManager = DataManager()
    
    // CurrentUser instance
    @StateObject private var currentUser = CurrentUser()
    
    var body: some Scene {
        WindowGroup {
            SettingView()
                .environment(\.managedObjectContext, dataManager.container.viewContext) // pass for core date CRUD
                .environmentObject(currentUser) // Pass currentUser as an environment object
        }
    }
}
