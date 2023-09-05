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
 Paul Hudson. One-to-many relationships with @FetchRequest and SwiftUI – Core Data SwiftUI Tutorial 7/7 (Nov. 28, 2021). Accessed Aug. 20, 2023. [Online Video]. Available: https://www.youtube.com/watch?v=0QGt0THnlwU&ab_channel=PaulHudson
 */

import Foundation
import CoreData

class DataManager: ObservableObject {
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "Master_Chess")
        
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        storeDescription?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load data: \(error.localizedDescription)")
            }
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }
}
