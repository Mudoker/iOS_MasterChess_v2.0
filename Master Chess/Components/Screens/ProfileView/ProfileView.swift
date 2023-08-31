//
//  ProfileView.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 12/08/2023.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Users.username, ascending: true)], animation: .default) private var users: FetchedResults<Users>
    @EnvironmentObject var currentUserr: CurrentUser
    @AppStorage("userName") var username = "Mudoker"
    @State private var isUsernameTakenAlertPresented = false
    @State private var showAllItems = false
    
    var columns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    }
    
    func isUsernameAvailable(_ newUsername: String) -> Bool {
        let isTaken = users.contains { user in
            user.unwrappedUsername == newUsername
        }
        return !isTaken
    }
    // Function to convert date to string
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM / dd / yyyy"
        return dateFormatter.string(from: date)
    }
    
    func getUserWithUsername(_ username: String) -> Users? {
        return users.first { $0.username == username }
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                let currentUser = getUserWithUsername(username)
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
                                                    .fill( CurrentUser.shared.username == username ? Color.green : .gray)
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
                                    Text("\(String(winrate))%")
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
                        .padding(.horizontal)
                        
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
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(achievements, id: \.self) { achivement in
                                VStack {
                                    Image(achivement.icon ?? "rank1")
                                        .resizable()
                                        .frame(width: proxy.size.width / 4, height: proxy.size.width / 4)
                                    Text(achivement.title ?? "Top 1")
                                        .font(.title)
                                        .bold()
                                    
                                    Text(achivement.des ?? "Top 1 on the leaderboard!")
                                        .font(.callout)
                                        .bold()
                                        .opacity(0.7)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        
                    } else {
                        Text("No available achievement")
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
                                            Text("Easy")
                                        }
                                        
                                        Spacer()
                                        VStack {
                                            Text(history.unwrappedOutcome)
                                                .font(.title2)
                                                .foregroundColor(.green)
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
                        Spacer()
                        Text("No available history")
                    }
                    
                }
                VStack {
                }.frame(height: 30)
                
            }
        }
        .foregroundColor(.white)
        .background(Color(red: 0.00, green: 0.09, blue: 0.18))
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
