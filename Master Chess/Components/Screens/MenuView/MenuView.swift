/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 12/08/2023
 Last modified: 21/08/2023
 Acknowledgement:
 Free3D. "Chess Pieces - Queen White 3D Model" free3d.com https://free3d.com/3d-model/chess-pieces-queen-white-2529.html (accessed 12/08/2023)
 FIDE. "" fide.com https://fide.com (accessed 12/08/2023)
 Chess Titans. "Chess Titans, Encyclopedia, Science News & Research Reviews" academic-accelerator.com https://academic-accelerator.com/encyclopedia/chess-titans (accessed 12/08/2023)
 Capitoni. "Legends of Chess" behance.net https://www.behance.net/gallery/101853937/Legends-Of-Chess/modules/586723731 (accessed 12/08/2023)
 A. Raymond. "Chess playing bot Mittens the Cat has the snark, and the game, to leave you in shreds" deseret.com https://www.deseret.com/2023/1/19/23562766/chess-playing-bot-mittens-the-cat-has-snark-and-game-leave-you-in-shreds (accessed 12/08/2023)
 Wikipedia. "Nobita Nobi" wikipedia.org https://en.wikipedia.org/wiki/Nobita_Nobi (accessed 12/08/2023)
 */


import SwiftUI

struct MenuView: View {
    // Current Date time
    @State private var currentTime = Date()
    
    // Load from core date
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Users.rating, ascending: true)], animation: .default) private var users: FetchedResults<Users>
    @AppStorage("userName") var username = "Mudoker"
    
    // Control state
    @State private var isSheetPresented = true
    @State var showToast = false
    @State var achievementImage = ""
    @State var achievementDes = ""
    @State var leaderBoard = false
    @State var how2playView = false
    @State var gameView = false
    
    // Localization
    @AppStorage("selectedLanguage") var selectedLanguage = "vi"
    
    // Function to convert date to string
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM / dd / yyyy"
        return dateFormatter.string(from: date)
    }
    
    // user data
    var user = CurrentUser.shared
    
    // theme
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("theme") var theme = ""
    @State var lightBackground = Color(red: 0.70, green: 0.90, blue: 0.90)
    @State var darkBackground = Color(red: 0.00, green: 0.09, blue: 0.18)
    
    // Responsive
    @State var currentDateSizeHeight: CGFloat = 0
    @State var currentDateFont: Font = .body
    @State var greetingSizeHeight: CGFloat = 0
    @State var greetingFont: Font = .title2
    @State var ratingFont: Font = .caption
    @State var medalIconSizeWidth: CGFloat = 0
    @State var medalIconSizeHeight: CGFloat = 0
    @State var medalIconBackgroundSizeWidth: CGFloat = 0
    @State var medalIconBackgroundSizeHeight: CGFloat = 0
    @State var gameViewIconBackgroundSizeWidth: CGFloat = 0
    @State var gameViewIconBackgroundSizeHeight: CGFloat = 0
    @State var gameViewTitleFontSize: CGFloat = 25
    @State var gameViewDesFontSize: CGFloat = 16
    @State var gameViewIconSizeWidth: CGFloat = 0
    @State var onClickTextFont: Font = .body
    @State var gameViewTriangleIconSize: CGFloat = 0
    @State var otherIconBackgroundSizeWidth: CGFloat = 0
    @State var otherIconBackgroundSizeHeight: CGFloat = 0
    @State var otherTitleFontSize: CGFloat = 16
    @State var otherOnClickTextFont: Font = .caption
    @State var historyFont: Font = .title3
    @State var historyNumberFont: Font = .body
    @State var historyEmptyFont: Font = .body
    @State var historyDateFont: Font = .body
    @State var historyOpponentImageSizeWidth: CGFloat = 0
    @State var historyOpponentImageSizeHeight: CGFloat = 0
    @State var historyOpponentNameFont: Font = .body
    @State var historyOutcomeFont: Font = .title2
    @State var gameViewBottomPadding: CGFloat = 16
    
    // Get user
    func getUserWithUsername(_ username: String) -> Users? {
        return users.first { $0.username == username }
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // get user
                let currentUser = getUserWithUsername(username)
                
                // Greetings
                VStack(alignment: .leading) {
                    HStack {
                        // Gretings
                        VStack(alignment: .leading) {
                            Text(getFormattedDate())
                                .frame(height: currentDateSizeHeight)
                                .padding(.leading)
                                .font(currentDateFont)
                            
                            Text(LocalizedStringKey(greeting(for: currentTime)))
                                .font(greetingFont)
                                .frame(height: greetingSizeHeight)
                                .bold()
                                .padding(.leading)
                        }
                        
                        // Push view
                        Spacer()
                        
                        HStack {
                            Text("Rating: \(String(currentUser?.rating ?? 0))")
                                .font(ratingFont)
                            
                            // On press, navigate to leader board
                            NavigationLink(destination: LeaderBoard()) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(theme == "system" ? (colorScheme == .dark ? .gray.opacity(0.7) : .black.opacity(0.2)) : (theme == "light" ? .black.opacity(0.2) : .gray.opacity(0.7)))
                                        .frame(width: medalIconBackgroundSizeWidth, height: medalIconBackgroundSizeHeight)
                                    
                                    Image(systemName: "medal.fill")
                                        .resizable()
                                        .frame(width: medalIconSizeWidth, height: medalIconSizeHeight)
                                }
                            }
                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded {
                                        leaderBoard = true
                                    }
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Game view navigation
                    HStack (spacing: 15) {
                        Button(action: {
                            // loaded saved board
                            user.savedGameBoardSetup = currentUser?.savedGame?.boardSetup ?? [[]]
                            
                            // save to core data
                            try? viewContext.save()
                            gameView.toggle()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(theme == "system" ? (colorScheme == .dark ? .gray.opacity(0.7) : .black.opacity(0.2)) : (theme == "light" ? .black.opacity(0.2) : .gray.opacity(0.7)))
                                    .frame(width: gameViewIconBackgroundSizeWidth, height: gameViewIconBackgroundSizeHeight)
                                
                                VStack {
                                    HStack {
                                        Image("chess")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: gameViewIconSizeWidth)
                                        
                                        // Push view
                                        Spacer()
                                    }
                                    .frame(width: proxy.size.width/2)
                                    
                                    VStack (alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text("Competitive")
                                                .font(.custom("OpenSans", size: gameViewTitleFontSize))
                                                .bold()
                                                .multilineTextAlignment(.leading)
                                            
                                            // Push view
                                            Spacer()
                                        }
                                        .padding(.leading)
                                        
                                        HStack {
                                            Text("Player versus\nComputer")
                                                .font(.custom("OpenSans", size: gameViewDesFontSize))
                                                .multilineTextAlignment(.leading)
                                                .lineSpacing(2)
                                            
                                            // Push view
                                            Spacer()
                                        }
                                        .padding(.leading)
                                    }
                                    
                                    // Push view
                                    Spacer()
                                    
                                    // Line separator
                                    Divider()
                                    
                                    HStack {
                                        Text("Play")
                                            .font(onClickTextFont)
                                        
                                        // Push view
                                        Spacer()
                                        
                                        Image(systemName: "triangle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: gameViewTriangleIconSize)
                                            .rotationEffect(Angle(degrees: 90))
                                        
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, gameViewBottomPadding)
                                    
                                    // Push view
                                    Spacer()
                                }
                                .frame(width: proxy.size.width/2.5, height: proxy.size.height/2.5)
                            }
                        }
                        .fullScreenCover(isPresented: $gameView){
                            GameView(user: currentUser ?? Users())
                        }
                        
                        // How2Play view
                        VStack {
                            NavigationLink(destination: How2playScreen()
                                .navigationBarTitle("")
                                .navigationBarHidden(false)) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(theme == "system" ? (colorScheme == .dark ? .gray.opacity(0.7) : .black.opacity(0.2)) : (theme == "light" ? .black.opacity(0.2) : .gray.opacity(0.7)))
                                            .frame(width: proxy.size.width/2.5, height: proxy.size.height/6.1)
                                        
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text("How to play?")
                                                    .font(.custom("OpenSans_Italic", size: otherTitleFontSize))
                                                    .bold()
                                                    .multilineTextAlignment(.leading)
                                                
                                                Image("how2play")
                                                    .resizable()
                                                    .frame(width: proxy.size.width/6)
                                            }
                                            .padding(.leading)
                                            
                                            // Push view
                                            Spacer()
                                            
                                            // Line separator
                                            Divider()
                                            
                                            HStack {
                                                Text("Explore")
                                                    .font(otherOnClickTextFont)
                                                
                                                // Push view
                                                Spacer()
                                                
                                                Image(systemName: "triangle.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: proxy.size.width/55)
                                                    .rotationEffect(Angle(degrees: 90))
                                                
                                            }
                                            .padding(.horizontal)
                                            
                                            // Push view
                                            Spacer()
                                        }
                                        .padding(.top)
                                        .frame(width: proxy.size.width/2.5)
                                    }
                                    .frame(width: proxy.size.width/2.5, height: proxy.size.height/6)
                                }
                                .simultaneousGesture(
                                    TapGesture()
                                        .onEnded {
                                            how2playView = true
                                        }
                                )
                            
                            // Link to FIDE website
                            Button(action: {
                                if let url = URL(string: "https://www.fide.com") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(theme == "system" ? (colorScheme == .dark ? .gray.opacity(0.7) : .black.opacity(0.2)) : (theme == "light" ? .black.opacity(0.2) : .gray.opacity(0.7)))
                                        .frame(width: proxy.size.width/2.5, height: proxy.size.height/6.3)
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("Official Website")
                                                .font(.custom("OpenSans_Italic", size: otherTitleFontSize))
                                                .bold()
                                                .multilineTextAlignment(.leading)
                                            
                                            Image("fide")
                                                .resizable()
                                                .frame(width: proxy.size.width/6)
                                        }
                                        .padding(.leading)
                                        
                                        // Push view
                                        Spacer()
                                        
                                        // Line separator
                                        Divider()
                                        
                                        HStack {
                                            Text("Explore")
                                                .font(otherOnClickTextFont)
                                            
                                            // Push view
                                            Spacer()
                                            
                                            Image(systemName: "triangle.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: proxy.size.width/55)
                                                .rotationEffect(Angle(degrees: 90))
                                        }
                                        .padding(.horizontal)
                                        
                                        // Push view
                                        Spacer()
                                    }
                                    .padding(.top)
                                    .frame(width: proxy.size.width/2.5)
                                }
                            }
                            .frame(width: proxy.size.width/2.5, height: proxy.size.height/6.3)
                        }
                    }
                    .frame(width: proxy.size.width)
                    .padding(.top)
                    
                    // Push view
                    Spacer()
                    
                    // History of current player
                    VStack {
                        HStack {
                            Text("Recent Matches")
                                .font(historyFont)
                                .bold()
                            
                            // Push view
                            Spacer()
                            
                            Text(String(currentUser?.userStats?.unwrappedWins ?? 0))
                                .bold()
                                .font(historyNumberFont)
                            
                            Text("|")
                                .bold()
                            
                            Text(String(currentUser?.userStats?.unwrappedLosses ?? 0))
                                .bold()
                                .opacity(0.6)
                                .font(historyNumberFont)
                        }
                        .padding(.horizontal)
                        
                        if currentUser?.unwrappedGameHistory.isEmpty ?? true {
                            // Push view
                            Spacer()
                            
                            Text("No available history")
                                .font(historyEmptyFont)
                        } else {
                            // List of recent game played
                            ScrollView {
                                ForEach(currentUser?.unwrappedGameHistory.sorted(by: { $0.unwrappedDatePlayed > $1.unwrappedDatePlayed }) ?? [GameHistory(context: viewContext)], id: \.self) { history in
                                    HStack {
                                        // Date
                                        Text(formatDate(history.unwrappedDatePlayed))
                                            .bold()
                                        
                                        // Push view
                                        Spacer()
                                        
                                        // Opponent infor
                                        Image(history.unwrappedOpponentUsername == "M.Carlsen" ? "magnus" : history.unwrappedOpponentUsername == "Nobita" ? "nobita" : "mitten")
                                            .resizable()
                                            .frame(width: proxy.size.width / 10, height: proxy.size.width / 12)
                                        
                                        Text(history.unwrappedOpponentUsername)
                                            .bold()
                                        
                                        // Push view
                                        Spacer()
                                        
                                        // Outcome
                                        Text(LocalizedStringKey(history.unwrappedOutcome))
                                            .font(.title2)
                                            .foregroundColor(history.unwrappedOutcome == "Win" ? .green : history.unwrappedOutcome == "Draw" ? .yellow : .red)
                                            .bold()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Push view
                        Spacer()
                    }
                    .frame(width: proxy.size.width)
                    .padding(.top)
                }
                .frame(width: proxy.size.width)
                .padding(.top)
                
                // show achievement toast if have
                if showToast {
                    AchievementView(isContentVisible: showToast, imageName: achievementImage, des: achievementDes)
                }
            }
            .frame(width: proxy.size.width)
            .onAppear {
                // Responsive
                if UIDevice.current.userInterfaceIdiom == .phone {
                    currentDateSizeHeight = proxy.size.width/100
                    greetingSizeHeight = proxy.size.width/10
                    ratingFont = .caption
                    medalIconSizeWidth = proxy.size.width/16
                    medalIconSizeHeight = proxy.size.width/16
                    medalIconBackgroundSizeWidth = proxy.size.height/14
                    medalIconBackgroundSizeHeight = proxy.size.height/16
                    gameViewIconBackgroundSizeWidth = proxy.size.width/2.5
                    gameViewIconBackgroundSizeHeight = proxy.size.height/3
                    gameViewIconSizeWidth = proxy.size.width/3
                    gameViewTriangleIconSize = proxy.size.width/35
                    otherTitleFontSize = 18
                } else {
                    currentDateSizeHeight = proxy.size.width/250
                    greetingSizeHeight = proxy.size.width/15
                    ratingFont = .title2
                    medalIconSizeWidth = proxy.size.width/20
                    medalIconSizeHeight = proxy.size.width/18
                    medalIconBackgroundSizeWidth = proxy.size.height/14
                    medalIconBackgroundSizeHeight = proxy.size.height/16
                    greetingFont = .largeTitle
                    currentDateFont = .title
                    gameViewIconBackgroundSizeWidth = proxy.size.width/2.5
                    gameViewIconBackgroundSizeHeight = proxy.size.height/3
                    gameViewTitleFontSize = 40
                    gameViewDesFontSize = 25
                    gameViewIconSizeWidth = proxy.size.width/3.5
                    gameViewTriangleIconSize = proxy.size.width/50
                    onClickTextFont = .title
                    otherTitleFontSize = 24
                    otherOnClickTextFont = .title3
                    historyFont = .title
                    historyNumberFont = .title2
                    historyEmptyFont = .title
                    historyDateFont = .title
                    historyOutcomeFont = .title
                    historyOpponentNameFont = .title
                    historyOpponentImageSizeWidth =  proxy.size.width / 10
                    historyOpponentImageSizeHeight = proxy.size.width / 12
                    gameViewBottomPadding = 32
                }
                
                // get user
                let currentUser = getUserWithUsername(username)
                
                // check if user have meet requirements to add achievements
                for achievement in currentUser?.unwrappedAchievements ?? [] {
                    if achievement.title == "First Step" && !achievement.unlocked {
                        achievementImage = achievement.icon ?? ""
                        achievementDes = achievement.des ?? ""
                        showToast = true
                        achievement.unlocked = true
                    }
                    
                    if achievement.title == "Top 1" {
                        if currentUser == users[0] && !achievement.unlocked {
                            achievementImage = achievement.icon ?? ""
                            achievementDes = achievement.des ?? ""
                            showToast = true
                            achievement.unlocked = true
                        }
                    }
                    
                    if users.count >= 3 {
                        if achievement.title == "Top 2" {
                            if currentUser == users[1] && !achievement.unlocked {
                                achievementImage = achievement.icon ?? ""
                                achievementDes = achievement.des ?? ""
                                showToast = true
                                achievement.unlocked = true
                            }
                        }
                        
                        if achievement.title == "Top 3" {
                            if currentUser == users[2] && !achievement.unlocked {
                                achievementImage = achievement.icon ?? ""
                                achievementDes = achievement.des ?? ""
                                showToast = true
                                achievement.unlocked = true
                            }
                        }
                    }
                    
                    
                    if achievement.title == "Get's started" {
                        if currentUser?.userStats?.totalGames == 1 && !achievement.unlocked {
                            achievementImage = achievement.icon ?? ""
                            achievementDes = achievement.des ?? ""
                            showToast = true
                            achievement.unlocked = true
                        }
                    }
                    
                    if achievement.title == "Game Lover" {
                        if currentUser?.userStats?.totalGames == 5 && !achievement.unlocked {
                            achievementImage = achievement.icon ?? ""
                            achievementDes = achievement.des ?? ""
                            showToast = true
                            achievement.unlocked = true
                        }
                    }
                    
                    if achievement.title == "Friend with AI" {
                        if currentUser?.userStats?.totalGames == 10 && !achievement.unlocked {
                            achievementImage = achievement.icon ?? ""
                            achievementDes = achievement.des ?? ""
                            showToast = true
                            achievement.unlocked = true
                        }
                    }
                    
                    if achievement.title == "The Challenger" {
                        if currentUser?.userStats?.totalGames == 20 && !achievement.unlocked {
                            achievementImage = achievement.icon ?? ""
                            achievementDes = achievement.des ?? ""
                            showToast = true
                            achievement.unlocked = true
                        }
                    }
                    
                    if achievement.title == "AI Killer" {
                        if currentUser?.userStats?.totalGames == 50 && !achievement.unlocked {
                            achievementImage = achievement.icon ?? ""
                            achievementDes = achievement.des ?? ""
                            showToast = true
                            achievement.unlocked = true
                        }
                    }
                    
                    if achievement.title == "Newbie" {
                        if currentUser?.rating ?? 0 < 1000 && !achievement.unlocked {
                            achievementImage = achievement.icon ?? ""
                            achievementDes = achievement.des ?? ""
                            showToast = true
                            achievement.unlocked = true
                        }
                    }
                    
                    if achievement.title == "Pro Player" {
                        if 1000 <= (currentUser?.rating ?? 0) && (currentUser?.rating ?? 0) < 1300 && !achievement.unlocked {
                            achievementImage = achievement.icon ?? ""
                            achievementDes = achievement.des ?? ""
                            showToast = true
                            achievement.unlocked = true
                        }
                    }
                    
                    if achievement.title == "Master" {
                        if 1300 <= (currentUser?.rating ?? 0) && (currentUser?.rating ?? 0) < 1600 && !achievement.unlocked {
                            achievementImage = achievement.icon ?? ""
                            achievementDes = achievement.des ?? ""
                            showToast = true
                            achievement.unlocked = true
                        }
                    }
                    
                    if achievement.title == "Grand Master" {
                        if currentUser?.rating ?? 0 >= 1600 && !achievement.unlocked {
                            achievementImage = achievement.icon ?? ""
                            achievementDes = achievement.des ?? ""
                            showToast = true
                            achievement.unlocked = true
                        }
                    }
                    showToast = false
                }
            }
        }
        // theme
        .foregroundColor(theme == "system" ? colorScheme == .dark ? .white : Color.black : theme == "light" ? Color.black : Color.white)
        .background(theme == "system" ? colorScheme == .dark ? darkBackground : lightBackground : theme == "light" ? lightBackground : darkBackground)
        .preferredColorScheme(theme == "system" ? .init(colorScheme) : theme == "light" ? .light : .dark)
        .environment(\.locale, Locale(identifier: selectedLanguage)) // localization
    }
    
    // Generate greeting text based on time
    private func greeting(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        
        if hour >= 0 && hour < 12 {
            return "Good morning!"
        } else if hour >= 12 && hour < 18 {
            return "Good afternoon!"
        } else {
            return "Good evening!"
        }
    }
    
    // Format date to string
    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        
        // Check the selected language and set the locale accordingly
        if selectedLanguage == "en" {
            dateFormatter.locale = Locale(identifier: "en_US")
        } else if selectedLanguage == "vi" {
            dateFormatter.locale = Locale(identifier: "vi_VN")
        }
        
        dateFormatter.dateFormat = "E, MMM d yyyy"
        return dateFormatter.string(from: Date())
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
