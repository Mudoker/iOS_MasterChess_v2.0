//
//  DataManager.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 10/08/2023.
//

import Foundation
import CoreData

class DataManager: ObservableObject {
    let container = NSPersistentContainer(name: "Master_Chess")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Failt to load data: \(error.localizedDescription)")
            }
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }
}
