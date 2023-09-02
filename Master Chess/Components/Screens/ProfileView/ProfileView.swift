//
//  ProfileView.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 12/08/2023.
//

import SwiftUI

struct ProfileView: View {
    var currentUserr = CurrentUser.shared
    @AppStorage("userName") var username = "Mudoker"
    @State private var isUsernameTakenAlertPresented = false
    @State private var showAllItems = false
    @State private var isBack = false
    var columns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    }
    
    var currentUser: Users?
    
    // Function to convert date to string
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM / dd / yyyy"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack {
                    ScrollView (showsIndicators: false) {
                        VStack {
                            HStack {
                                Spacer()
                                Circle()
                                    .fill(.pink.opacity(0.4))
                                    .frame(width: proxy.size.width / 2.5)
                                    .overlay(
                                        Image(currentUser?.profilePicture ?? "profile1")
                                            .resizable()
                                            .frame(width: proxy.size.width / 3, height: proxy.size.width / 3)
                                            .overlay(
                                                ZStack {
                                                    Circle()
                                                        .fill(CurrentUser.shared.username == currentUser?.unwrappedUsername ? Color.green : .gray)
                                                        .frame(width: proxy.size.width / 18)
                                                        .position(x: proxy.size.width / 3.3, y: proxy.size.width / 3.2)
                                                    Circle()
                                                        .stroke(Color.black, lineWidth: 3)
                                                        .frame(width: proxy.size.width / 18)
                                                        .position(x: proxy.size.width / 3.3, y: proxy.size.width / 3.2)
                                                    
                                                }
                                            )
                                    )
                                
                                Spacer()
                            }
                            
                            
                            Text(currentUser?.username ?? "Mudoker")
                                .font(.title)
                                .bold()
                            VStack {
                                if currentUser?.rating ?? 2000 < 800 {
                                    Text("Newbie")
                                        .font(.title3)
                                        .bold()
                                } else if currentUser?.rating ?? 2000 < 1300 {
                                    Text("Pro")
                                        .font(.title3)
                                        .bold()
                                    
                                } else if currentUser?.rating ?? 2000 < 1600 {
                                    Text("Master")
                                        .font(.title3)
                                        .bold()
                                    
                                } else {
                                    Text("Grand Master")
                                        .font(.title3)
                                        .bold()
                                }
                                
                                HStack {
                                    Text("Join date: ")
                                    Text(formatDate(currentUser?.joinDate ?? Date()))
                                }
                            }
                            .padding(.bottom, 5)
                            
                            HStack (spacing: 20) {
                                Spacer()
                                VStack {
                                    if let totalGames = currentUser?.unwrappedUserStats.totalGames {
                                        Text(String(totalGames))
                                            .foregroundColor(.white)
                                            .font(.largeTitle)
                                            .bold()
                                    } else {
                                        Text("0")
                                            .foregroundColor(.white)
                                            .font(.largeTitle)
                                            .bold()
                                    }
                                    
                                    Text("Games")
                                        .foregroundColor(.white.opacity(0.7))
                                        .font(.callout)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    if let winrate = currentUser?.unwrappedUserStats.winRate {
                                        Text("\(Int(winrate) == Int(winrate) ? "\(Int(winrate))%" : String(format: "%.2f%", winrate))")
                                            .foregroundColor(.white)
                                            .font(.largeTitle)
                                            .bold()
                                    } else {
                                        Text("0%")
                                            .foregroundColor(.white)
                                            .font(.largeTitle)
                                            .bold()
                                    }
                                    Text("Win rate")
                                        .foregroundColor(.white.opacity(0.7))
                                        .font(.callout)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    if let rating = currentUser?.rating {
                                        
                                        Text(String(rating))
                                            .foregroundColor(.white)
                                            .font(.largeTitle)
                                            .bold()
                                    } else {
                                        Text("0")
                                            .foregroundColor(.white)
                                            .font(.largeTitle)
                                            .bold()
                                    }
                                    
                                    Text("Ratings")
                                        .foregroundColor(.white.opacity(0.7))
                                        .font(.callout)
                                }
                                Spacer()
                            }
                            
                        }
                        
                        HStack (alignment: .firstTextBaseline) {
                            Text("Achievements")
                                .font(.largeTitle)
                                .bold()
                            
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    showAllItems.toggle()
                                }
                            }) {
                                Text(showAllItems ? "Show Less" : "Show All")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        if let achievements = currentUser?.unwrappedAchievements {
                            let unlockedAchievements = achievements.filter { $0.unlocked }
                            
                            let maxAchievementsToShow = showAllItems ? unlockedAchievements.count : 3
                            
                            LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                                ForEach(0..<min(unlockedAchievements.count, maxAchievementsToShow), id: \.self) { index in
                                    let achievement = unlockedAchievements[index]
                                    
                                    VStack(alignment: .leading) {
                                        Image(achievement.icon ?? "rank1")
                                            .resizable()
                                            .frame(width: proxy.size.width / 4, height: proxy.size.width / 4)
                                            .aspectRatio(contentMode: .fit)
                                        
                                        
                                        Text(achievement.title ?? "Top 1")
                                            .font(.title3)
                                            .bold()
                                        
                                        Text(achievement.des ?? "Top 1 on the leaderboard!")
                                            .font(.caption)
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
                        
                        
                        
                        HStack {
                            Text("History")
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if let histories = currentUser?.unwrappedGameHistory {
                            ForEach(histories, id: \.self) { history in
                                Capsule()
                                    .fill(.gray.opacity(0.3))
                                    .frame(width: proxy.size.width/1.2,height: proxy.size.width/5)
                                    .overlay(
                                        HStack {
                                            Text(formatDate(history.unwrappedDatePlayed))
                                                .font(.callout)
                                                .bold()
                                            Spacer()
                                            
                                            Image(history.unwrappedOpponentUsername == "M.Carlsen" ? "magnus" : history.unwrappedOpponentUsername == "Nobita" ? "nobita" : "mitten")
                                                .resizable()
                                                .frame(width: proxy.size.width / 10, height: proxy.size.width / 12)
                                                .background(
                                                    Circle()
                                                        .foregroundColor(.white)
                                                )
                                            
                                            
                                            VStack(alignment: .leading) {
                                                Text(history.unwrappedOpponentUsername)
                                                    .bold()
                                                Text(history.unwrappedOpponentUsername == "M.Carlsen" ? "Hard" : history.unwrappedOpponentUsername == "Nobita" ? "Easy" : "Normal")
                                            }
                                            
                                            Spacer()
                                            VStack {
                                                Text(history.unwrappedOutcome)
                                                    .font(.title2)
                                                    .foregroundColor(history.unwrappedOutcome == "Win" ? .green : history.unwrappedOutcome == "Draw" ? .yellow : .red)
                                                    .bold()
                                                
                                                Text(String(history.unwrappedUserRatingChange))
                                                    .bold()
                                                    .opacity(0.7)
                                                    .foregroundColor(history.unwrappedOutcome == "Win" ? .green : history.unwrappedOutcome == "Draw" ? .yellow : .red)
                                            }
                                            
                                        }
                                            .padding(.horizontal)
                                    )
                            }
                        }else {
                            Text("No available history")
                                .padding(.vertical)
                        }
                        
                    }
                    
                    VStack {
                    }.frame(height: 30)
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                
            }
            .foregroundColor(.white)
            .background(Color(red: 0.00, green: 0.09, blue: 0.18))
        }
        .navigationViewStyle(.stack)
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(currentUser: Users())
    }
}
