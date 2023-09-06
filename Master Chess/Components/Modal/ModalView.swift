/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 29/08/2023
 Last modified: 03/09/2023
 Acknowledgement:
 Baamboozle. "Ranking Numbers Design Vector" baamboozle.com https://www.baamboozle.com/study/223799 (accessed 29/08/2023)
 PNGTree. "Vs Versus 3d Transparent Background" pngtree.com https://pngtree.com/freepng/vs-versus-3d-transparent-background_5995748.html (accessed 29/08/2023)
 VectorStock. "Music trumpet icon cartoon style vector image" vectorstock.com https://www.vectorstock.com/royalty-free-vector/music-trumpet-icon-cartoon-style-vector-23436213 (accessed 29/08/2023)
 */

import SwiftUI

// Game Over modal view
struct ModalView: View {
    // Watch the state of the current game
    @StateObject var viewModel: GameViewModel
    
    // Navigate to menuview
    @State var isShowMenuView = false
    
    // Animation
    @State var isExpanded = false
    
    // Confetti animation
    @State var isConfetti = false
    
    // Current user instance
    var currentUser = CurrentUser.shared
    
    // Current user from Core Data
    var user = Users()
    
    // View context for saving to core data
    @Environment(\.managedObjectContext) private var viewContext
    
    // Localization
    @AppStorage("selectedLanguage") var selectedLanguage = "vi"
    
    // Dark mode
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("theme") var theme = ""
    @State var lightBackground = Color(red: 0.70, green: 0.90, blue: 0.90)
    @State var darkBackground = Color(red: 0.00, green: 0.09, blue: 0.18)
    
    // Responsive
    @State var outComeFontSize: CGFloat = 35
    @State var outComeDesFont: Font = .title3
    @State var playerNameFont: Font = .title2
    @State var playerTitleFont: Font = .body
    @State var ratingChange: CGFloat = 35
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Center horizontally
                HStack {
                    Spacer()
                    
                    // Center vertically
                    VStack {
                        Spacer()
                        
                        // Content
                        VStack{
                            // Push view down
                            Spacer()
                                .frame(height: proxy.size.width/12)
                            
                            // Show outcome accordingly with confetti animation
                            HStack {
                                Image("trumpet")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: proxy.size.width/7)
                                    .scaleEffect(x: -1, y: 1)
                                    .rotationEffect(viewModel.chessGame.winner == .white ? .degrees(25) : .degrees(-25))
                                
                                // Outcome
                                VStack {
                                    if viewModel.chessGame.outcome == .checkmate ||  viewModel.chessGame.outcome == .outOfMove || viewModel.chessGame.outcome == .outOfTime{
                                        if viewModel.chessGame.winner == .white {
                                            // Outcome title
                                            Text("YOU WON")
                                                .font(.system(size: outComeFontSize))
                                                .bold()
                                                .scaleEffect(isExpanded ? 1.1 : 1) // Apply scale effect
                                                .animation(
                                                    Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
                                                    value: isExpanded
                                                )
                                                .onAppear {
                                                    withAnimation {
                                                        isExpanded.toggle() // Toggle the state to start the animation
                                                    }
                                                }
                                                .particleEffect(status: isConfetti) // confetti animation
                                                .onAppear {
                                                    isConfetti = true
                                                }
                                            
                                            // Outcome description
                                            Text("Checkmate")
                                                .font(outComeDesFont)
                                                .opacity(0.7)
                                        } else {
                                            // Outcome title
                                            Text("YOU LOSS")
                                                .font(.system(size: outComeFontSize))
                                                .bold()
                                                .scaleEffect(isExpanded ? 1.1 : 1) // Apply scale effect
                                                .animation(
                                                    Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
                                                    value: isExpanded
                                                )
                                                .onAppear {
                                                    withAnimation {
                                                        isExpanded.toggle() // Toggle the state to start the animation
                                                    }
                                                }
                                            
                                            // Outcome description
                                            if viewModel.chessGame.outcome == .outOfMove {
                                                Text("Out of move")
                                                    .font(outComeDesFont)
                                                    .opacity(0.7)
                                            } else if viewModel.chessGame.outcome == .outOfTime{
                                                Text("Out of time")
                                                    .font(outComeDesFont)
                                                    .opacity(0.7)
                                            } else {
                                                Text("Checkmate")
                                                    .font(outComeDesFont)
                                                    .opacity(0.7)
                                            }
                                        }
                                    } else {
                                        // Outcome title
                                        Text("DRAW")
                                            .font(.system(size: outComeFontSize))
                                            .bold()
                                            .frame(minWidth:80)
                                            .scaleEffect(isExpanded ? 1.1 : 1) // Apply scale effect
                                            .animation(
                                                Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
                                                value: isExpanded
                                            )
                                            .onAppear {
                                                withAnimation {
                                                    isExpanded.toggle() // Toggle the state to start the animation
                                                }
                                            }
                                            .particleEffect(status: isConfetti) // confetti animation
                                            .onAppear {
                                                isConfetti = true
                                            }
                                        
                                        // Outcome description
                                        if viewModel.chessGame.outcome == .insufficientMaterial {
                                            Text("Insufficient Material")
                                                .font(outComeDesFont)
                                                .opacity(0.7)
                                        } else if viewModel.chessGame.outcome == .stalemate {
                                            Text("Stale Mate")
                                                .font(outComeDesFont)
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
                                        // Player info
                                        Image(CurrentUser.shared.profilePicture ?? "profile1")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: proxy.size.width/3.5, height: proxy.size.width/3.5)
                                        
                                        Text(CurrentUser.shared.username ?? "Undefined")
                                            .font(playerNameFont)
                                            .padding(.leading)
                                        
                                        // Convert rating to title
                                        if CurrentUser.shared.rating < 1000 {
                                            Text("Newbie")
                                                .font(playerTitleFont)
                                                .padding(.leading)
                                        } else if CurrentUser.shared.rating < 1300 {
                                            Text("Pro")
                                                .font(playerTitleFont)
                                                .padding(.leading)
                                        } else if CurrentUser.shared.rating < 1600 {
                                            Text("Master")
                                                .font(playerTitleFont)
                                                .padding(.leading)
                                        } else {
                                            Text("Grand Master")
                                                .font(playerTitleFont)
                                                .padding(.leading)
                                        }
                                    }
                                    
                                    // Push view
                                    Spacer()
                                        .frame(width: proxy.size.width / 4)
                                    
                                    // Opponent infor
                                    VStack (alignment: .trailing) {
                                        Image(viewModel.blackPlayerProfile)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: proxy.size.width/3.5, height: proxy.size.width/3.5)
                                        
                                        Text(viewModel.blackPlayerName)
                                            .font(playerNameFont)
                                            .padding(.trailing)
                                        
                                        
                                        Text(LocalizedStringKey(viewModel.blackTitle))
                                            .font(playerTitleFont)
                                            .padding(.trailing)
                                    }
                                }
                                .frame(width: proxy.size.width)
                                
                                // Image
                                Image ("versus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: proxy.size.width/3, height: proxy.size.width/3)
                                    .vibratingShaking(deadline: 4) // shaking animation
                            }
                            
                            // rating change
                            Text ("Current Rating")
                                .font(playerNameFont)
                                .padding(.top)
                            
                            HStack {
                                Text ("\(String(CurrentUser.shared.rating))")
                                    .font(.system(size: ratingChange))
                                    .bold()
                                
                                if CurrentUser.shared.rating - viewModel.chessGame.currentRating > 0 {
                                    Text ("+ \(String(CurrentUser.shared.rating - viewModel.chessGame.currentRating))")
                                        .font(playerTitleFont)
                                } else {
                                    Text (" \(String(CurrentUser.shared.rating - viewModel.chessGame.currentRating))")
                                        .font(playerTitleFont)
                                }
                            }
                            
                            VStack (spacing: 10) {
                                // Go back to menu view
                                Button(action: {
                                    withAnimation {
                                        isShowMenuView.toggle()
                                    }
                                    
                                }) {
                                    Text("Continue")
                                        .padding()
                                        .font(playerTitleFont)
                                        .bold()
                                        .frame(width: proxy.size.width/1.5, height: proxy.size.height / 15)
                                        .background(Color.green.opacity(0.95))
                                        .cornerRadius(proxy.size.width/40)
                                }
                                .fullScreenCover(isPresented: $isShowMenuView) {
                                    TabBar()
                                }
                            }
                            
                            // Push view
                            Spacer()
                                .frame(height: proxy.size.width/8)
                        }
                        .frame(width: proxy.size.width / 1.1)
                        .background(theme == "system" ? colorScheme == .dark ? darkBackground : lightBackground : theme == "light" ? lightBackground : darkBackground)
                        .cornerRadius(proxy.size.width / 20)
                        
                        // Push view
                        Spacer()
                    }
                    
                    // Push view
                    Spacer()
                }
            }
            .ignoresSafeArea()
            .onAppear {
                
                // Responsive on phone and ipad
                if UIDevice.current.userInterfaceIdiom == .phone {
                } else {
                    outComeFontSize = 70
                    outComeDesFont = .largeTitle
                    playerNameFont = .largeTitle
                    playerTitleFont = .title
                    ratingChange = 70
                }
                
                // History instance
                let history = GameHistory(context: viewContext)
                history.datePlayed = Date()
                history.gameID = UUID()
                history.opponentUsername = viewModel.blackPlayerName
                
                // Update user stats
                user.userStats?.totalGames = Int32((user.userStats?.totalGames ?? 0) + 1)

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
                        
                        user.userStats?.losses = Int32((user.userStats?.losses ?? 0) + 1)
                    }
                } else {
                    if currentUser.settingSoundEnabled {
                        viewModel.playSound(sound: "gameDraw", type: "mp3")
                    }
                    
                    history.outcome = "Draw"
                    
                    user.userStats?.draws = Int32((user.userStats?.draws ?? 0) + 1)
                }
                
                // Calculate win rate
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
                
                // Rating change
                history.userRatingChange = Int16(abs(Int(user.rating) - currentUser.rating))
                
                user.addToUserHistory(history)
                user.rating = Int16(currentUser.rating)
                
                // Save to core data
                try? viewContext.save()
            }
        }
        .background(theme == "system" ? colorScheme == .dark ? darkBackground : lightBackground : theme == "light" ? lightBackground : darkBackground) // dark mode
        .foregroundColor(theme == "system" ? colorScheme == .dark ? .white : Color.black : theme == "light" ? Color.black : Color.white) // dark mode
        .preferredColorScheme(theme == "system" ? .init(colorScheme) : theme == "light" ? .light : .dark) // dark mode
        .environment(\.locale, Locale(identifier: selectedLanguage)) // localiszation
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ModalView(viewModel: GameViewModel())
    }
}
