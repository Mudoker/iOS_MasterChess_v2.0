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
    
    // Custom go back button
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // Responsive
    @State var titleFont: Font = .largeTitle
    @State var contentFont: Font = .title
    @State var imageSizeWidth: CGFloat = 0
    @State var imageSizeHeight: CGFloat = 0
    @State var padding: CGFloat = 16
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
                        Section(header:
                            Text("Overview of Chess Game")                        .font(titleFont)
                                .bold()
                        ) {
                            Text (LocalizedStringKey(overview))
                                .opacity(0.7)
                                .font(contentFont)
                        }
                        
                        Section(header:
                            Text("Board Setup")
                                .font(titleFont)
                                .bold()
                        ) {
                            Text (LocalizedStringKey(boardSetup))
                                .font(contentFont)
                                .opacity(0.7)
                            
                            ForEach(pieces, id: \.self) { piece in
                                HStack {
                                    Text("- ")
                                        .font(contentFont)
                                    
                                    Text(LocalizedStringKey(piece))
                                        .font(contentFont)
                                        .opacity(0.7)
                                }
                            }
                            .listStyle(InsetGroupedListStyle())
                            
                            HStack {
                                Image("chessboard1")
                                    .resizable()
                                    .frame(width: imageSizeWidth, height: imageSizeHeight)
                                
                                Spacer()
                                
                                Image("chessboard2")
                                    .resizable()
                                    .frame(width: imageSizeWidth, height: imageSizeHeight)
                            }
                        }
                        
                        Section(header:
                            Text("How to move")
                                .font(titleFont)
                                .bold()
                        ) {
                            
                            ForEach(moves, id: \.self) { move in
                                HStack {
                                    Text("• ")
                                        .font(contentFont)
                                    
                                    Text(LocalizedStringKey(move))
                                        .font(contentFont)
                                        .opacity(0.7)
                                }
                            }
                            VStack {
                                HStack {
                                    Image("pawnmove")
                                        .resizable()
                                        .frame(width: imageSizeWidth, height: imageSizeHeight)
                                    
                                    Spacer()
                                    
                                    Image("knightmove")
                                        .resizable()
                                        .frame(width: imageSizeWidth, height: imageSizeHeight)
                                }
                                HStack {
                                    Image("rookmove")
                                        .resizable()
                                        .frame(width: imageSizeWidth, height: imageSizeHeight)
                                    
                                    Spacer()
                                    
                                    Image("bishopmove")
                                        .resizable()
                                        .frame(width: imageSizeWidth, height: imageSizeHeight)
                                }
                                
                                HStack {
                                    Image("queenmove")
                                        .resizable()
                                        .frame(width: imageSizeWidth, height: imageSizeHeight)
                                    
                                    Spacer()
                                    
                                    Image("kingmove")
                                        .resizable()
                                        .frame(width: imageSizeWidth, height: imageSizeHeight)
                                }
                            }
                        }
                        
                        Section(header: Text("How to win").font(titleFont).bold()) {
                            Text (LocalizedStringKey(winCondition))
                                .font(contentFont)
                                .opacity(0.7)
                            
                            HStack {
                                Image("gamewin")
                                    .resizable()
                                    .frame(width: imageSizeWidth, height: imageSizeHeight)

                                Spacer()
                                
                                Image("gameloss")
                                    .resizable()
                                    .frame(width: imageSizeWidth, height: imageSizeHeight)
                            }
                            
                        }
                        
                        Section(header: Text("Master Rank Constraints").font(titleFont).bold()) {
                            Text (LocalizedStringKey(masterConstraints))
                                .font(contentFont)
                                .opacity(0.7)
                        }
                        
                        Section(header: Text("Grand Master Rank Constraints").font(titleFont).bold()) {
                            Text (LocalizedStringKey(grandMasterConstraints))
                                .font(contentFont)
                                .opacity(0.7)
                        }
                        
                        Section(header: Text("Score Calculation").font(titleFont).bold()) {
                            Text("In the game, points are awarded based on expected and final performance:")
                                .font(contentFont)
                                .opacity(0.7)
                                .padding(.bottom, 10) // Add some spacing after the first Text
                            
                            Text("RatingChange = KFactor * DifficultyMultiplier * (ActualOutcome - ExpectedOutcome)")
                                .font(contentFont)
                                .padding(.bottom, 5) // Add some spacing after the second Text
                                .opacity(0.7)
                            
                            Text("ExpectedOutcome = 1 / (1 + 10^((OpponentRating - PlayerRating) / 400))")
                                .font(contentFont)
                                .padding(.bottom, 10) // Add some spacing after the third Text
                                .opacity(0.7)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Where:")
                                    .font(contentFont)

                                Text("• RatingChange is the calculated change in the player's rating.")
                                    .font(contentFont)
                                
                                Text("• RatingChange is the calculated change in the player's rating.")
                                    .font(contentFont)
                                
                                Text("• KFactor represents a constant that governs the sensitivity of rating changes.")
                                    .font(contentFont)
                                
                                Text("• DifficultyMultiplier adjusts the impact of difficulty levels on the rating change.")
                                    .font(contentFont)
                                
                                Text("• ActualOutcome signifies the actual game outcome's impact on the rating change.")
                                    .font(contentFont)
                                
                                Text("• ExpectedOutcome predicts the likelihood of a player's victory based on Elo's probability estimation.")
                                    .font(contentFont)
                            }
                            .opacity(0.7)
                        }
                    }
                    .padding(.horizontal, padding)
                }
            }
            .background(theme == "system" ? colorScheme == .dark ? darkBackground : lightBackground : theme == "light" ? lightBackground : darkBackground)
            .foregroundColor(theme == "system" ? colorScheme == .dark ? .white : Color.black : theme == "light" ? Color.black : Color.white)
            .preferredColorScheme(theme == "system" ? .init(colorScheme) : theme == "light" ? .light : .dark)
            .onAppear {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    titleFont = .title2
                    contentFont = .body
                    imageSizeWidth = proxy.size.width / 2.2
                    imageSizeHeight = proxy.size.width / 1.3
                } else {
                    titleFont = .largeTitle
                    contentFont = .title
                    imageSizeWidth = proxy.size.width / 2
                    imageSizeHeight = proxy.size.width / 1.1
                    padding = 0
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .environment(\.locale, Locale(identifier: selectedLanguage))
    }
}

struct How2playScreen_Previews: PreviewProvider {
    static var previews: some View {
        How2playScreen()
    }
}
