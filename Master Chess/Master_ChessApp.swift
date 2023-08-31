//
//  Master_ChessApp.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 09/08/2023.
//

import SwiftUI

@main
struct Master_ChessApp: App {
    @StateObject private var dataManager = DataManager()
    @StateObject private var currentUser = CurrentUser() // Initialize the CurrentUser instance
    init() {
//        SoundPlayer.startBackGroundMusic()
    }
    var body: some Scene {
        WindowGroup {
            CRUD()
                .environment(\.managedObjectContext, dataManager.container.viewContext)
                .environmentObject(currentUser) // Pass currentUser as an environment object

        }
    }
}
