import Combine
import Foundation


class CurrentUser: ObservableObject {
    @Published var username: String? = "test"
    @Published var joinDate: Date? = Date()
    @Published var password: String? = "123"
    @Published var profilePicture: String? = "profile1"
    @Published var ranking: Int = 0
    @Published var rating: Int = 0
    @Published var userID: UUID? = UUID()
    @Published var hasActiveGame: Bool = false
    // Add the new properties
    @Published var userAchievement: NSSet? = []
    @Published var userHistory: NSSet? = []
    // Properties from Setting
    @Published var settingAutoPromotionEnabled: Bool = false
    @Published var settingIsDarkMode: Bool = false
    @Published var settingLanguage: String = ""
    @Published var settingMusicEnabled: Bool = false
    @Published var settingSoundEnabled: Bool = false
    @Published var settingDifficulty: String = ""
    
    // Properties from SavedGame
    @Published var savedGameAutoPromotionEnabled: Bool = false
    @Published var savedGameBlackTimeLeft: Double = 0
    @Published var savedGameBoardSetup: [[String]] = []
    @Published var savedGameCurrentPlayer: String = ""
    @Published var savedGameDifficulty: String = ""
    @Published var savedGameIsCheck: Bool = false
    @Published var savedGameLanguage: String = ""
    @Published var savedGameMoveAvailable: Int16 = 0
    @Published var savedGameWhiteTimeLeft: Double = 0
    @Published var savedGameIsWhiteKingMoved: Bool = false
    @Published var savedGameIsBlackKingMoved: Bool = false
    @Published var savedGameIsWhiteLeftRookMoved: Bool = false
    @Published var savedGameIsWhiteRightRookMoved: Bool = false
    @Published var savedGameIsBlackLeftRookMoved: Bool = false
    @Published var savedGameIsBlackRightRookMoved: Bool = false
    @Published var savedGameKingPosition: Int16 = 0
    static let shared = CurrentUser()
    
}
