import SwiftUI

struct MenuView: View {
    @State private var currentTime = Date()
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Users.rating, ascending: true)], animation: .default) private var users: FetchedResults<Users>
    @AppStorage("userName") var username = "Mudoker"
    @State private var isSheetPresented = true
    @State var showToast = false
    func getUserWithUsername(_ username: String) -> Users? {
        return users.first { $0.username == username }
    }
    @State private var languageChanged = false // Add this state
    @AppStorage("selectedLanguage") var selectedLanguage = "vi"

    // Function to convert date to string
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM / dd / yyyy"
        return dateFormatter.string(from: date)
    }
    
    var user = CurrentUser.shared
    @State var achievementImage = ""
    @State var achievementDes = ""
    
    @State var leaderBoard = false
    @State var how2playView = false
    @State var gameView = false
    @AppStorage("theme") var theme = ""
    @State var lightBackground = Color(red: 0.70, green: 0.90, blue: 0.90)
    @State var darkBackground = Color(red: 0.00, green: 0.09, blue: 0.18)
    
    var body: some View {
        
        GeometryReader { proxy in
                ZStack {
                    let currentUser = getUserWithUsername(username)
                    
                   
                    
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(getFormattedDate())
                                    .frame(height: proxy.size.width/100)
                                    .padding(.leading)
                                
                                Text(LocalizedStringKey(greeting(for: currentTime)))
                                    .font(.title2)
                                    .frame(height: proxy.size.width/10)
                                    .bold()
                                    .padding(.leading)
                            }
                            
                            Spacer()
                            
                            HStack {
                                Text("Rating: \(String(currentUser?.rating ?? 0))")
                                    .font(.caption)

                                NavigationLink(destination: LeaderBoard()) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(theme == "system" ? (colorScheme == .dark ? .gray.opacity(0.7) : .black.opacity(0.2)) : (theme == "light" ? .black.opacity(0.2) : .gray.opacity(0.7)))
                                            .frame(width: proxy.size.width/8, height: proxy.size.height/16)
                                        Image(systemName: "medal.fill")
                                            .resizable()
                                            .frame(width: proxy.size.width/16, height: proxy.size.width/16)
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
                        
                        HStack (spacing: 15) {
                            Button(action: {
                                user.savedGameBoardSetup = currentUser?.savedGame?.boardSetup ?? [[]]
                                try? viewContext.save()
                                gameView.toggle()
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(theme == "system" ? (colorScheme == .dark ? .gray.opacity(0.7) : .black.opacity(0.2)) : (theme == "light" ? .black.opacity(0.2) : .gray.opacity(0.7)))
                                        .frame(width: proxy.size.width/2.5, height: proxy.size.height/3)
                                    
                                    VStack {
                                        HStack {
                                            Image("chess")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: proxy.size.width/3)
                                            Spacer()
                                        }
                                        .frame(width: proxy.size.width/2)
                                        
                                        //                                    Spacer()
                                        
                                        VStack (alignment: .leading, spacing: 5) {
                                            Text("Competitive")
                                                .font(.custom("OpenSans", size: 25))
                                                .bold()
                                                .multilineTextAlignment(.leading)
                                            Text("Player versus\nComputer")
                                                .font(.custom("OpenSans", size: 16))
                                                .multilineTextAlignment(.leading)
                                                .lineSpacing(2)
                                        }
                                        Spacer()
                                        Divider()
                                        HStack {
                                            Text("Play")
                                            Spacer()
                                            Image(systemName: "triangle.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: proxy.size.width/35)
                                                .rotationEffect(Angle(degrees: 90))
                                            
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom)
                                        
                                        Spacer()
                                    }
                                    .frame(width: proxy.size.width/2.5, height: proxy.size.height/2.5)
                                }
                            }
                            .fullScreenCover(isPresented: $gameView){
                                GameView(user: currentUser ?? Users())
                            }
                            
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
                                                    .font(.custom("OpenSans_Italic", size: 18))
                                                    .bold()
                                                    .multilineTextAlignment(.leading)
                                                Image("how2play")
                                                    .resizable()
                                                    .frame(width: proxy.size.width/6)
                                            }
                                            .padding(.leading)
                                            Spacer()
                                            Divider()
                                            HStack {
                                                Text("Explore")
                                                    .font(.caption)
                                                Spacer()
                                                Image(systemName: "triangle.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: proxy.size.width/55)
                                                    .rotationEffect(Angle(degrees: 90))
                                                
                                            }
                                            .padding(.horizontal)
                                            Spacer()
                                        }
                                        .padding(.top)
                                        .frame(width: proxy.size.width/2.5)
                                    }
                                    .frame(width: proxy.size.width/2.5, height: proxy.size.height/6)                                }
                                .simultaneousGesture(
                                    TapGesture()
                                        .onEnded {
                                            how2playView = true
                                        }
                                )
                                
                                
                                
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
                                                    .font(.custom("OpenSans_Italic", size: 18))
                                                    .bold()
                                                    .multilineTextAlignment(.leading)
                                                Image("fide")
                                                    .resizable()
                                                    .frame(width: proxy.size.width/6)
                                            }
                                            .padding(.leading)
                                            
                                            Spacer()
                                            
                                            Divider()
                                            
                                            HStack {
                                                Text("Explore")
                                                    .font(.caption)
                                                Spacer()
                                                Image(systemName: "triangle.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: proxy.size.width/55)
                                                    .rotationEffect(Angle(degrees: 90))
                                                
                                            }
                                            .padding(.horizontal)
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
                        Spacer()
                        
                        VStack {
                            HStack {
                                Text("Recent Matches")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                                Text(String(currentUser?.userStats?.unwrappedWins ?? 0))
                                    .bold()
                                Text("|")
                                    .bold()
                                
                                Text(String(currentUser?.userStats?.unwrappedLosses ?? 0))
                                    .bold()
                                    .opacity(0.6)
                            }
                            .padding(.horizontal)
                            
                            if currentUser?.unwrappedGameHistory.isEmpty ?? true {
                                Spacer()
                                Text("No available history")
                            } else {
                                ScrollView {
                                    ForEach(currentUser?.unwrappedGameHistory.sorted(by: { $0.unwrappedDatePlayed > $1.unwrappedDatePlayed }) ?? [GameHistory(context: viewContext)], id: \.self) { history in
                                        HStack {
                                            Text(formatDate(history.unwrappedDatePlayed))
                                                .bold()
                                            
                                            Spacer()
                                            
                                            Image(history.unwrappedOpponentUsername == "M.Carlsen" ? "magnus" : history.unwrappedOpponentUsername == "Nobita" ? "nobita" : "mitten")
                                                .resizable()
                                                .frame(width: proxy.size.width / 10, height: proxy.size.width / 12)
                                            
                                            
                                            Text(history.unwrappedOpponentUsername)
                                                .bold()
                                            
                                            Spacer()
                                            
                                            Text(LocalizedStringKey(history.unwrappedOutcome))
                                                .font(.title2)
                                                .foregroundColor(history.unwrappedOutcome == "Win" ? .green : history.unwrappedOutcome == "Draw" ? .yellow : .red)
                                                .bold()
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .frame(width: proxy.size.width)
                        .padding(.top)
                    }
                    .frame(width: proxy.size.width)
                    .padding(.top)
                    
                    if showToast {
                        AchievementView(isContentVisible: showToast, imageName: achievementImage, des: achievementDes)
                    }
                }
                .frame(width: proxy.size.width)
                .onAppear {
                    let currentUser = getUserWithUsername(username)
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
        .foregroundColor(theme == "system" ? colorScheme == .dark ? .white : Color.black : theme == "light" ? Color.black : Color.white)
        .background(theme == "system" ? colorScheme == .dark ? darkBackground : lightBackground : theme == "light" ? lightBackground : darkBackground)
        .preferredColorScheme(theme == "system" ? .init(colorScheme) : theme == "light" ? .light : .dark)
        .environment(\.locale, Locale(identifier: selectedLanguage))
    }
    
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
