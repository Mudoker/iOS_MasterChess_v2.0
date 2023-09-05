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

import Foundation
import CoreData


extension Setting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Setting> {
        return NSFetchRequest<Setting>(entityName: "Setting")
    }

    @NSManaged public var autoPromotionEnabled: Bool
    @NSManaged public var difficulty: String?
    @NSManaged public var isDarkMode: Bool
    @NSManaged public var isSystemTheme: Bool
    @NSManaged public var language: String?
    @NSManaged public var musicEnabled: Bool
    @NSManaged public var soundEnabled: Bool
    @NSManaged public var source: Users?
    
    public var unwrappedAutoPromotionEnabled: Bool {
        autoPromotionEnabled
    }
    
    public var unwrappedIsDarkMode: Bool {
        isDarkMode
    }
    
    public var unwrappedLanguage: String {
        language ?? "English"
    }
    
    public var unwrappedMusicEnabled: Bool {
        musicEnabled
    }
    
    public var unwrappedSoundEnabled: Bool {
        soundEnabled
    }
    
    public var unwrappedDifficulty: String {
        difficulty ?? "Easy"
    }
    public var unwrappedSource: Users? {
        source
    }
    
    public var unwrappedIsSystemTheme: Bool {
        isSystemTheme
    }

}

extension Setting : Identifiable {

}
