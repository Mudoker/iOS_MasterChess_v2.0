import swiftUI
class CurrentUser: ObservableObject {
    @Published var username: String?
    @Published var joinDate: Date?
    @Published var password: String?
    @Published var profilePicture: String?
    @Published var ranking: Int16 = 0
    @Published var rating: Int16 = 0
    @Published var userID: UUID?
    @Published var hasActiveGame: Bool = false
    // Add the new properties
    @Published var userAchievement: NSSet?
    @Published var userHistory: NSSet?
    @Published var userSettings: Setting?

    // Initialize the object with user data from Core Data or other sources
    init(username: String, joinDate: Date?, password: String?, profilePicture: String?, ranking: Int16, rating: Int16, userID: UUID?, hasActiveGame: Bool, userAchievement: NSSet?, userHistory: NSSet?, userSettings: Setting?) {
        self.username = username
        self.joinDate = joinDate
        self.password = password
        self.profilePicture = profilePicture
        self.ranking = ranking
        self.rating = rating
        self.userID = userID
        self.hasActiveGame = hasActiveGame
        self.userAchievement = userAchievement
        self.userHistory = userHistory
        self.userSettings = userSettings
    }
}
