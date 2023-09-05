/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 12/08/2023
 Last modified: 31/08/2023
 Acknowledgement:
 */


import SwiftUI

struct ProfileView: View {
    // Current user data
    var currentUserr = CurrentUser.shared
    @AppStorage("userName") var username = "Mudoker"
    
    // Control state
    @State private var showAllItems = false
    @State private var isBack = false
    
    // Localization
    @AppStorage("selectedLanguage") var selectedLanguage = "vi"
    
    // theme
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("theme") var theme = ""
    @State var lightBackground = Color(red: 0.70, green: 0.90, blue: 0.90)
    @State var darkBackground = Color(red: 0.00, green: 0.09, blue: 0.18)
    
    // cutom back button
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // Columns of achievements
    var columns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    }
    
    // current user from core data
    var currentUser: Users?
    
    // Responsive
    @State var imageBackgroundSize: CGFloat = 0
    @State var profileImageSize: CGFloat = 0
    @State var activeStatusSize: CGFloat = 0
    @State var userNameFont: Font = .title
    @State var userTitleFont: Font = .title3
    @State var userJoinDateFont: Font = .body
    @State var gameStatsFont: CGFloat = 35
    @State var gameStatsDesFont: Font = .callout
    @State var activeStatusPositionX: CGFloat = 0
    @State var activeStatusPositionY: CGFloat = 0
    @State var achievementImageSize: CGFloat = 0
    @State var achievementTitleFont: Font = .title3
    @State var achievementDesFont: Font = .caption
    @State var historyDateFont: Font = .callout
    @State var historyOpponentName: Font = .body
    @State var historyDifficulty: Font = .body
    @State var historyOutcome: Font = .title2
    @State var historyRatingChange: Font = .body
    @State var historyImageSizeWidth: CGFloat = 0
    @State var historyImageSizeHeight: CGFloat = 0
    @State var historyCapsuleSizeWidth: CGFloat = 0
    @State var historyCapsuleSizeHeight: CGFloat = 0
    
    // custom back button
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "arrow.left.circle.fill")
                    .imageScale(.large)
                Text("Go Back")
            }
            .padding()
            .foregroundColor(.blue)
        }
    }
    
    // Function to convert date to string
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM / dd / yyyy"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                ScrollView (showsIndicators: false) {
                    VStack {
                        HStack {
                            // Push view
                            Spacer()
                            
                            Circle()
                                .fill(.pink.opacity(0.4))
                                .frame(width: imageBackgroundSize)
                                .overlay(
                                    Image(currentUser?.profilePicture ?? "profile1")
                                        .resizable()
                                        .frame(width: profileImageSize, height: profileImageSize)
                                        .overlay(
                                            // Activity sign
                                            ZStack {
                                                Circle()
                                                    .fill(CurrentUser.shared.username == currentUser?.unwrappedUsername ? Color.green : .gray)
                                                    .frame(width: activeStatusSize)
                                                    .position(x: activeStatusPositionX, y: activeStatusPositionY)
                                                
                                                Circle()
                                                    .stroke(Color.black, lineWidth: 3)
                                                    .frame(width: activeStatusSize)
                                                    .position(x: activeStatusPositionX, y: activeStatusPositionY)
                                            }
                                        )
                                )
                            
                            // push view
                            Spacer()
                        }
                        
                        // Name
                        Text(currentUser?.username ?? "Mudoker")
                            .font(userNameFont)
                            .bold()
                        
                        // Title
                        VStack {
                            if currentUser?.rating ?? 2000 < 800 {
                                Text("Newbie")
                                    .font(userTitleFont)
                                    .bold()
                            } else if currentUser?.rating ?? 2000 < 1300 {
                                Text("Pro")
                                    .font(userTitleFont)
                                    .bold()
                                
                            } else if currentUser?.rating ?? 2000 < 1600 {
                                Text("Master")
                                    .font(userTitleFont)
                                    .bold()
                                
                            } else {
                                Text("Grand Master")
                                    .font(userTitleFont)
                                    .bold()
                            }
                            
                            // Date joined
                            HStack {
                                Text("Join date: ")
                                    .font(userJoinDateFont)

                                Text(formatDate(currentUser?.joinDate ?? Date()))
                                    .font(userJoinDateFont)
                            }
                        }
                        .padding(.bottom, 5)
                        
                        // User stats
                        HStack (spacing: 20) {
                            // Push view
                            Spacer()
                            
                            VStack {
                                if let totalGames = currentUser?.unwrappedUserStats.totalGames {
                                    Text(String(totalGames))
                                        .font(.largeTitle)
                                        .bold()
                                } else {
                                    Text("0")
                                        .font(.system(size: gameStatsFont))
                                        .bold()
                                }
                                
                                Text("Games")
                                    .opacity(0.7)
                                    .font(gameStatsDesFont)
                            }
                            
                            // push view
                            Spacer()
                            
                            VStack {
                                if let winrate = currentUser?.unwrappedUserStats.winRate {
                                    Text("\(Int(winrate) == Int(winrate) ? "\(Int(winrate))%" : String(format: "%.2f%", winrate))")
                                        .font(.largeTitle)
                                        .bold()
                                } else {
                                    Text("0%")
                                        .font(.system(size: gameStatsFont))
                                        .bold()
                                }
                                Text("Win rate")
                                    .opacity(0.7)
                                    .font(gameStatsDesFont)
                            }
                            
                            // push view
                            Spacer()
                            
                            VStack {
                                if let rating = currentUser?.rating {
                                    
                                    Text(String(rating))
                                        .font(.largeTitle)
                                        .bold()
                                } else {
                                    Text("0")
                                        .font(.system(size: gameStatsFont))
                                        .bold()
                                }
                                
                                Text("Ratings")
                                    .opacity(0.7)
                                    .font(gameStatsDesFont)
                            }
                            
                            // push view
                            Spacer()
                        }
                        
                    }
                    
                    // User achievements
                    HStack (alignment: .firstTextBaseline) {
                        Text("Achievements")
                            .font(.largeTitle)
                            .bold()
                        
                        // push view
                        Spacer()
                        
                        // Show full or at most 3 achievements
                        Button(action: {
                            withAnimation {
                                showAllItems.toggle()
                            }
                        }) {
                            Text(showAllItems ? "Show Less" : "Show All")
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // List of achievements
                    if let achievements = currentUser?.unwrappedAchievements {
                        // filter unlocked ones
                        let unlockedAchievements = achievements.filter { $0.unlocked }
                        
                        // number of achievements shown
                        let maxAchievementsToShow = showAllItems ? unlockedAchievements.count : 3
                        
                        let filteredAchievements = Array(unlockedAchievements.prefix(maxAchievementsToShow))
                        
                        if !filteredAchievements.isEmpty {
                            LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                                ForEach(filteredAchievements, id: \.self) { achievement in
                                    VStack(alignment: .leading) {
                                        Image(achievement.icon ?? "rank1")
                                            .resizable()
                                            .frame(width: achievementImageSize, height: achievementImageSize)
                                            .aspectRatio(contentMode: .fit)
                                        
                                        Text(LocalizedStringKey(achievement.title ?? "Top 1"))
                                            .font(achievementTitleFont)
                                            .bold()
                                        
                                        Text(LocalizedStringKey(achievement.des ?? "Top 1 on the leaderboard!"))
                                            .font(achievementDesFont)
                                            .bold()
                                            .opacity(0.7)
                                        
                                        Spacer() // Push content to the top
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            Text("No available achievement")
                                .padding(.vertical)
                        }
                    } else {
                        Text("No available achievement")
                            .padding(.vertical)
                    }
                    
                    // Gaming history
                    HStack {
                        Text("History")
                            .font(.largeTitle)
                            .bold()
                        
                        // push view
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Show list of histories
                    if let histories = currentUser?.unwrappedGameHistory.sorted(by: { $0.unwrappedDatePlayed > $1.unwrappedDatePlayed }) {
                        ForEach(histories, id: \.self) { history in
                            Capsule()
                                .fill(.gray.opacity(0.3))
                                .frame(width: historyCapsuleSizeWidth,height: historyCapsuleSizeHeight)
                                .overlay(
                                    HStack {
                                        // Date
                                        Text(formatDate(history.unwrappedDatePlayed))
                                            .font(historyDateFont)
                                            .bold()
                                        
                                        // push view
                                        Spacer()
                                        
                                        // Opponent infor
                                        Image(history.unwrappedOpponentUsername == "M.Carlsen" ? "magnus" : history.unwrappedOpponentUsername == "Nobita" ? "nobita" : "mitten")
                                            .resizable()
                                            .frame(width: historyImageSizeWidth, height: historyImageSizeHeight)
                                            .background(
                                                Circle()
                                            )
                                        
                                        VStack(alignment: .leading) {
                                            Text(history.unwrappedOpponentUsername)
                                                .bold()
                                                .font(historyOpponentName)

                                            Text(history.unwrappedOpponentUsername == "M.Carlsen" ? "Hard" : history.unwrappedOpponentUsername == "Nobita" ? "Easy" : "Normal")
                                                .font(historyDifficulty)
                                        }
                                        
                                        // push view
                                        Spacer()
                                        
                                        // Outcome
                                        VStack {
                                            Text(LocalizedStringKey(history.unwrappedOutcome))
                                                .font(historyOutcome)
                                                .foregroundColor(history.unwrappedOutcome == "Win" ? .green : history.unwrappedOutcome == "Draw" ? .yellow : .red)
                                                .bold()
                                            
                                            Text(String(history.unwrappedUserRatingChange))
                                                .bold()
                                                .opacity(0.7)
                                                .foregroundColor(history.unwrappedOutcome == "Win" ? .green : history.unwrappedOutcome == "Draw" ? .yellow : .red)
                                                .font(historyRatingChange)
                                        }
                                    }
                                    .padding(.horizontal)
                                )
                        }
                    } else {
                        Text("No available history")
                            .padding(.vertical)
                    }
                }
                
                // push view
                VStack {
                }.frame(height: 30)
                
            }
            .onAppear {
                // Responsive
                if UIDevice.current.userInterfaceIdiom == .phone {
                    imageBackgroundSize = proxy.size.width / 2.5
                    profileImageSize = proxy.size.width / 3
                    activeStatusSize = proxy.size.width / 18
                    activeStatusPositionX = proxy.size.width / 3.3
                    activeStatusPositionY = proxy.size.width / 3.2
                    achievementImageSize = proxy.size.width / 4
                    historyCapsuleSizeWidth = proxy.size.width/1.1
                    historyCapsuleSizeHeight = proxy.size.width/6
                    historyImageSizeWidth = proxy.size.width / 10
                    historyImageSizeHeight = proxy.size.width / 12
                } else {
                    userNameFont = .largeTitle
                    userTitleFont = .title
                    userJoinDateFont = .title2
                    gameStatsFont = 50
                    gameStatsDesFont = .title3
                    profileImageSize = proxy.size.width / 5
                    imageBackgroundSize = proxy.size.width / 3.5
                    activeStatusSize = proxy.size.width / 24
                    activeStatusPositionX = proxy.size.width / 4.6
                    activeStatusPositionY = proxy.size.width / 5.5
                    achievementImageSize = proxy.size.width / 6
                    achievementTitleFont = .title
                    achievementDesFont = .title3
                    historyCapsuleSizeWidth = proxy.size.width/1.1
                    historyCapsuleSizeHeight = proxy.size.width/7
                    historyImageSizeWidth = proxy.size.width / 8
                    historyImageSizeHeight = proxy.size.width / 10
                    historyDateFont = .title
                    historyOutcome = .largeTitle
                    historyDifficulty = .title
                    historyRatingChange = .title2
                    historyOpponentName = .title
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            
        }
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .navigationBarItems(leading: backButton) // Place the custom back button in the top-left corner
        // theme
        .background(theme == "system" ? colorScheme == .dark ? darkBackground : lightBackground : theme == "light" ? lightBackground : darkBackground)
        .foregroundColor(theme == "system" ? colorScheme == .dark ? .white : Color.black : theme == "light" ? Color.black : Color.white)
        
        .preferredColorScheme(theme == "system" ? .init(colorScheme) : theme == "light" ? .light : .dark)
        .environment(\.locale, Locale(identifier: selectedLanguage)) // localization
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
