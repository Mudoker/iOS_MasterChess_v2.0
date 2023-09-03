//
//  How2playScreen.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 14/08/2023.
//

import SwiftUI

struct How2playScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("theme") var theme = ""
    @State var lightBackground = Color(red: 0.70, green: 0.90, blue: 0.90)
    @State var darkBackground = Color(red: 0.00, green: 0.09, blue: 0.18)
    
    @AppStorage("selectedLanguage") var selectedLanguage = "vi"
    
    let overview = "Chess is a classic two-player strategy board game that has been enjoyed for centuries. It's played on an 8x8 board called a chessboard, with each player has control upon an army of 16 pieces. The objective is to checkmate the opponent's king while protecting your own."
    
    let boardSetup = "The chessboard consists of 64 squares arranged in an 8x8 grid. Players sit in front of each other, with the board oriented so that each player has a white square on their right.\nPlace the pieces on the board as follows:"
    
    let pieces = [
        "Each player has 16 pieces: 1 king, 1 queen, 2 rooks, 2 knights, 2 bishops, and 8 pawns.",
        "Pawns occupy the second row (rank) for white and the seventh row for black.",
        "Two rooks occupy the corners.",
        "The two knights are next to the rooks.",
        "The two bishops are placed next to the knights.",
        "The queen takes her place on the remaining square of her color.",
        "The king stands beside the queen."
    ]
    
    let moves = [
        "Pawns move forward one square and capture diagonally.",
        "Rooks move horizontally or vertically across the board.",
        "Knights move in an L-shape: two squares in one direction and then one square perpendicular.",
        "Bishops move diagonally.",
        "Queens can move horizontally, vertically, or diagonally.",
        "Kings move one square in any direction."
    ]
    
    let winCondition = "The game is won by putting the opponent's king in checkmate, in other words, the king is under attack and cannot escape. You can also win if your opponent resigns, runs out of time or exceeds the number of moves."
    
    let masterConstraints = "If players are in rank Master (rating > 1300), they will have a time limit of 10 minutes for the entire game. This adds urgency and encourages quick decision-making. They will also be limited to 40 moves in total. If they reach 0 moves, it will result in an immediate loss."
    
    let grandMasterConstraints = "For those Grandmasters (rating > 1600), there's a limit on the number of moves (30 moves in total). Players must carefully plan their strategies as they're restricted in their available moves."
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
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
    
    @State var isBack = false
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ScrollView(showsIndicators: false) {
                    
                    
                    VStack (alignment: .leading, spacing: 10) {
                        Section(header: Text("Overview of Chess Game").font(.title2).bold()) {
                            Text (LocalizedStringKey(overview))
                                .font(.body)
                                .opacity(0.7)
                        }
                        
                        Section(header: Text("Board Setup").font(.title2).bold()) {
                            Text (LocalizedStringKey(boardSetup))
                                .font(.body)
                                .opacity(0.7)
                            
                            ForEach(pieces, id: \.self) { piece in
                                HStack {
                                    Text("- ")
                                    Text(LocalizedStringKey(piece))
                                        .opacity(0.7)
                                }
                            }
                            .listStyle(InsetGroupedListStyle())
                            
                            HStack {
                                Image("chessboard1")
                                    .resizable()
                                    .frame(width: proxy.size.width / 2.2, height: proxy.size.height / 2)
                                Spacer()
                                Image("chessboard2")
                                    .resizable()
                                    .frame(width: proxy.size.width / 2.2, height: proxy.size.height / 2)
                            }
                        }
                        
                        Section(header: Text("How to move").font(.title2).bold()) {
                            
                            ForEach(moves, id: \.self) { move in
                                HStack {
                                    Text("• ")
                                    Text(LocalizedStringKey(move))
                                        .opacity(0.7)
                                }
                            }
                            VStack {
                                HStack {
                                    Image("pawnmove")
                                        .resizable()
                                        .frame(width: proxy.size.width / 2.2, height: proxy.size.height / 2)
                                    Spacer()
                                    Image("knightmove")
                                        .resizable()
                                        .frame(width: proxy.size.width / 2.2, height: proxy.size.height / 2)
                                }
                                HStack {
                                    Image("rookmove")
                                        .resizable()
                                        .frame(width: proxy.size.width / 2.2, height: proxy.size.height / 2)
                                    Spacer()
                                    Image("bishopmove")
                                        .resizable()
                                        .frame(width: proxy.size.width / 2.2, height: proxy.size.height / 2)
                                }
                                
                                HStack {
                                    Image("queenmove")
                                        .resizable()
                                        .frame(width: proxy.size.width / 2.2, height: proxy.size.height / 2)
                                    Spacer()
                                    Image("kingmove")
                                        .resizable()
                                        .frame(width: proxy.size.width / 2.2, height: proxy.size.height / 2)
                                }
                            }
                        }
                        
                        Section(header: Text("How to win").font(.title2).bold()) {
                            Text (LocalizedStringKey(winCondition))
                                .font(.body)
                                .opacity(0.7)
                            
                            HStack {
                                Image("gamewin")
                                    .resizable()
                                    .frame(width: proxy.size.width / 2.2, height: proxy.size.height / 2)
                                Spacer()
                                Image("gameloss")
                                    .resizable()
                                    .frame(width: proxy.size.width / 2.2, height: proxy.size.height / 2)
                            }
                            
                        }
                        
                        Section(header: Text("Master Rank Constraints").font(.title2).bold()) {
                            Text (LocalizedStringKey(masterConstraints))
                                .font(.body)
                                .opacity(0.7)
                        }
                        
                        Section(header: Text("Grand Master Rank Constraints").font(.title2).bold()) {
                            Text (LocalizedStringKey(grandMasterConstraints))
                                .font(.body)
                                .opacity(0.7)
                        }
                        
                        Section(header: Text("Score Calculation").font(.title2).bold()) {
                            Text("In the game, points are awarded based on expected and final performance:")
                                .font(.body)
                                .opacity(0.7)
                                .padding(.bottom, 10) // Add some spacing after the first Text
                            
                            Text("RatingChange = KFactor * DifficultyMultiplier * (ActualOutcome - ExpectedOutcome)")
                                .padding(.bottom, 5) // Add some spacing after the second Text
                                .opacity(0.7)
                            
                            Text("ExpectedOutcome = 1 / (1 + 10^((OpponentRating - PlayerRating) / 400))")
                                .padding(.bottom, 10) // Add some spacing after the third Text
                                .opacity(0.7)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Where:")
                                Text("• RatingChange is the calculated change in the player's rating.")
                                
                                Text("• RatingChange is the calculated change in the player's rating.")
                                
                                Text("• KFactor represents a constant that governs the sensitivity of rating changes.")
                                
                                Text("• DifficultyMultiplier adjusts the impact of difficulty levels on the rating change.")
                                
                                Text("• ActualOutcome signifies the actual game outcome's impact on the rating change.")
                                
                                Text("• ExpectedOutcome predicts the likelihood of a player's victory based on Elo's probability estimation.")
                            }
                            .opacity(0.7)
                            
                            
                            
                        }
                        
                        
                        
                    }
                    .padding(.horizontal)
                }
            }
            .background(theme == "system" ? colorScheme == .dark ? darkBackground : lightBackground : theme == "light" ? lightBackground : darkBackground)
            .foregroundColor(theme == "system" ? colorScheme == .dark ? .white : Color.black : theme == "light" ? Color.black : Color.white)
            
            .preferredColorScheme(theme == "system" ? .init(colorScheme) : theme == "light" ? .light : .dark)
        }
        
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .navigationBarItems(leading: backButton) // Place the custom back button in the top-left corner
        .environment(\.locale, Locale(identifier: selectedLanguage))
    }
    
}


struct How2playScreen_Previews: PreviewProvider {
    static var previews: some View {
        How2playScreen()
    }
}
