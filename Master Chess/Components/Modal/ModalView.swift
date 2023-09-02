//
//  Modal+Win.swift
//  Master Chess
//
//  Created by quoc on 29/08/2023.
//

import SwiftUI

struct ModalView: View {
    @StateObject var viewModel: GameViewModel
    @State var isShowMenuView = false
    @State var isShowProfileView = false
    @State var isExpanded = false
    @State var isConfetti = false
    var currentUser = CurrentUser.shared
    var user = Users()
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                if isShowMenuView {
                    TabBar()
                } else if isShowProfileView {
                    ProfileView()
                } else {
                    ZStack {
                        Color(red: 0.00, green: 0.09, blue: 0.18)
                            .ignoresSafeArea()
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                VStack{
                                    Spacer()
                                        .frame(height: proxy.size.width/12)
                                    
                                    HStack {
                                        Image("trumpet")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: proxy.size.width/7)
                                            .scaleEffect(x: -1, y: 1)
                                            .rotationEffect(viewModel.chessGame.winner == .white ? .degrees(25) : .degrees(-25))
                                        
                                        VStack {
                                            if viewModel.chessGame.outcome == .checkmate ||  viewModel.chessGame.outcome == .outOfMove || viewModel.chessGame.outcome == .outOfTime{
                                                if viewModel.chessGame.winner == .white {
                                                    Text("YOU WON")
                                                        .font(.largeTitle)
                                                        .bold()
                                                        .scaleEffect(isExpanded ? 1.1 : 1) // Apply scale effect
                                                        .animation(
                                                            Animation.easeInOut(duration: 2) // Use easeInOut animation curve
                                                                .repeatForever(autoreverses: true)
                                                            ,value: isExpanded
                                                        )
                                                        .onAppear {
                                                            withAnimation {
                                                                isExpanded.toggle() // Toggle the state to start the animation
                                                            }
                                                        }
                                                        .particleEffect(status: isConfetti)
                                                        .onAppear {
                                                            isConfetti = true
                                                        }
                                                    
                                                    Text("Checkmate")
                                                        .font(.title3)
                                                        .opacity(0.7)
                                                }
                                                else {
                                                    Text("YOU LOSS")
                                                        .font(.largeTitle)
                                                        .bold()
                                                        .scaleEffect(isExpanded ? 1.1 : 1) // Apply scale effect
                                                        .animation(
                                                            Animation.easeInOut(duration: 2) // Use easeInOut animation curve
                                                                .repeatForever(autoreverses: true)
                                                            ,value: isExpanded
                                                        )
                                                        .onAppear {
                                                            withAnimation {
                                                                isExpanded.toggle() // Toggle the state to start the animation
                                                            }
                                                        }
                                                    Text("Checkmate")
                                                        .font(.title3)
                                                        .opacity(0.7)
                                                }
                                            } else {
                                                Text("DRAW")
                                                    .font(.largeTitle)
                                                    .bold()
                                                    .scaleEffect(isExpanded ? 1.1 : 1) // Apply scale effect
                                                    .animation(
                                                        Animation.easeInOut(duration: 2) // Use easeInOut animation curve
                                                            .repeatForever(autoreverses: true)
                                                        ,value: isExpanded
                                                    )
                                                    .onAppear {
                                                        withAnimation {
                                                            isExpanded.toggle() // Toggle the state to start the animation
                                                        }
                                                    }
                                                    .particleEffect(status: isConfetti)
                                                    .onAppear {
                                                        isConfetti = true
                                                    }
                                                
                                                if viewModel.chessGame.outcome == .insufficientMaterial {
                                                    Text("Insufficient Material")
                                                        .font(.title3)
                                                        .opacity(0.7)
                                                } else if viewModel.chessGame.outcome == .stalemate {
                                                    Text("Stale Mate")
                                                        .font(.title3)
                                                        .opacity(0.7)
                                                }
                                            }
                                        }
                                        Image("trumpet")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: proxy.size.width/7)
                                            .rotationEffect(viewModel.chessGame.winner == .white ? .degrees(-25) : .degrees(25))
                                    }
                                    
                                    
                                    ZStack {
                                        HStack {
                                            VStack (alignment: .leading) {
                                                Image(CurrentUser.shared.profilePicture ?? "profile1")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: proxy.size.width/3.5, height: proxy.size.width/3.5)
                                                
                                                
                                                Text(CurrentUser.shared.username ?? "Undefined")
                                                    .font(.title2)
                                                    .padding(.leading)
                                                
                                                if CurrentUser.shared.rating < 800 {
                                                    Text("Newbie")
                                                        .padding(.leading)
                                                } else if CurrentUser.shared.rating < 1300 {
                                                    Text("Pro")
                                                        .padding(.leading)
                                                } else if CurrentUser.shared.rating < 1600 {
                                                    Text("Master")
                                                        .padding(.leading)
                                                } else {
                                                    Text("Grand Master")
                                                        .padding(.leading)
                                                }
                                                
                                            }
                                            Spacer()
                                                .frame(width: proxy.size.width / 4)
                                            
                                            VStack (alignment: .trailing) {
                                                Image(viewModel.blackPlayerProfile)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: proxy.size.width/3.5, height: proxy.size.width/3.5)
                                                Text(viewModel.blackPlayerName)
                                                    .font(.title2)
                                                    .padding(.trailing)
                                                
                                                
                                                Text(viewModel.blackTitle)
                                                    .padding(.trailing)
                                                
                                            }
                                        }
                                        .frame(width: proxy.size.width)
                                        Image ("versus")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: proxy.size.width/3, height: proxy.size.width/3)
                                            .vibratingShaking(deadline: 4)
                                    }
                                    
                                    Text ("Current Rating")
                                        .font(.title2)
                                        .padding(.top)
                                    
                                    HStack {
                                        Text ("\(String(CurrentUser.shared.rating))")
                                            .font(.largeTitle)
                                            .bold()
                                        Text ( "+ \(String(CurrentUser.shared.rating - viewModel.chessGame.currentRating))")
                                    }
                                    
                                    VStack (spacing: 10) {
                                        
                                        Button(action: {
                                            withAnimation {
                                                isShowMenuView.toggle()
                                            }
                                            
                                        }) {
                                            Text("Continue")
                                                .padding()
                                                .bold()
                                                .foregroundColor(.white)
                                                .frame(width: proxy.size.width/1.5)
                                                .background(Color.green.opacity(0.95))
                                                .cornerRadius(proxy.size.width/40)
                                            
                                            
                                        }
                                        .fullScreenCover(isPresented: $isShowMenuView) {
                                            TabBar()
                                        }
                                        
                                    }
                                    
                                    Spacer()
                                        .frame(height: proxy.size.width/8)
                                }
                                .frame(width: proxy.size.width / 1.1)
                                .background(Color(red: 0.00, green: 0.09, blue: 0.18)
                                    .ignoresSafeArea())
                                .cornerRadius(proxy.size.width / 20)
                                .foregroundColor(.white)
                                Spacer()
                            }
                            
                            Spacer()
                        }
                    }
                    .ignoresSafeArea()
                    .onAppear {
                        let history = GameHistory(context: viewContext)
                        
                        user.userStats?.totalGames = Int32((user.userStats?.totalGames ?? 0) + 1)
                        history.datePlayed = Date()
                        history.gameID = UUID()
                        history.opponentUsername = viewModel.blackPlayerName
                        
                        if viewModel.chessGame.outcome == .checkmate {
                            if viewModel.chessGame.winner == .white {
                                if currentUser.settingSoundEnabled {
                                    viewModel.playSound(sound: "gameWin", type: "mp3")
                                }
                                user.userStats?.wins = Int32((user.userStats?.wins ?? 0) + 1)
                                history.outcome = "Win"
                            } else {
                                if currentUser.settingSoundEnabled {
                                    viewModel.playSound(sound: "gameLoss", type: "mp3")
                                }
                                history.outcome = "Loss"
                                user.userStats?.losses = Int32((user.userStats?.losses ?? 0) + 1)                                }
                        } else {
                            if currentUser.settingSoundEnabled {
                                viewModel.playSound(sound: "gameDraw", type: "mp3")
                            }
                            history.outcome = "Draw"
                            user.userStats?.draws = Int32((user.userStats?.draws ?? 0) + 1)                            }
                        
                        
                        let wins = user.userStats?.wins ?? 0
                        let totalGames = user.userStats?.totalGames ?? 1
                        
                        let winRate: Double
                        if totalGames > 0 {
                            winRate = (Double(wins) / Double(totalGames) * 100)
                        } else {
                            winRate = 0
                        }
                        
                        user.userStats?.winRate = Double(winRate)
                        currentUser.hasActiveGame = false
                        user.hasActiveGame = false
                        
                        history.userRatingChange = Int16(abs(Int(user.rating) - currentUser.rating))
                        
                        user.addToUserHistory(history)
                        user.rating = Int16(currentUser.rating)
                        
                        try? viewContext.save()
                    }
                    
                    
                }
                
            }
            
        }
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ModalView(viewModel: GameViewModel())
    }
}
