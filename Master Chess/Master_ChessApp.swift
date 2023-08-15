//
//  Master_ChessApp.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 09/08/2023.
//

import SwiftUI

@main
struct Master_ChessApp: App {
//    let persistenceController = PersistenceController.shared
    @StateObject private var dataManager = DataManager()
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(\.managedObjectContext, dataManager.container.viewContext)
        }
    }
}
