/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 14/08/2023
 Last modified: 03/09/2023
 Acknowledgement:
 */

import SwiftUI

struct ChessBoardView: View {
    // Current User
    var currentUser = CurrentUser.shared
    
    // Core Date
    @Environment(\.managedObjectContext) private var viewContext
    
    // Watch game state
    @StateObject var viewModel: GameViewModel
    
    // Decoy data
    var history: [Move] = [
        Move(from: Position(x: 0, y: 1), to: Position(x: 2, y: 3)),
        Move(from: Position(x: 1, y: 2), to: Position(x: 2, y: 3)),
        Move(from: Position(x: 4, y: 4), to: Position(x: 5, y: 5)),
        Move(from: Position(x: 3, y: 0), to: Position(x: 4, y: 1)),
        Move(from: Position(x: 7, y: 6), to: Position(x: 6, y: 5)),
        Move(from: Position(x: 2, y: 1), to: Position(x: 0, y: 0)),
        Move(from: Position(x: 6, y: 0), to: Position(x: 7, y: 1)),
        Move(from: Position(x: 3, y: 7), to: Position(x: 4, y: 6)),
        Move(from: Position(x: 1, y: 5), to: Position(x: 3, y: 4)),
        Move(from: Position(x: 5, y: 2), to: Position(x: 4, y: 3))
    ]
    
    // Localization
    @AppStorage("selectedLanguage") var selectedLanguage = "vi"
    
    // menu view navigation
    @State var isMenu = false
    
    // Animatoin
    @State private var isExpanded = false
    @State var isAnimation = false

    // Current user
    var user: Users
    
    // Convert history to chess note
    let columnLabels = "abcdefghijklmnopqrstuvwxyz"

    // Theme
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("theme") var theme = ""
    @State var lightBackground = Color(red: 0.70, green: 0.90, blue: 0.90)
    @State var darkBackground = Color(red: 0.00, green: 0.09, blue: 0.18)
    
    // Control state
    @State var boardBackground = UIBlurEffect.Style.light
    @State var selectedOpacity: Double = 0.0
    @State var nonSelectedOpacity: Double = 0.0
    @State var backgroundColor = Color.white
    
    // Convert histories of move to string
    func coordinateString(for point: Position) -> String {
        let xCoordinate = String(columnLabels[columnLabels.index(columnLabels.startIndex, offsetBy: point.x)])
        let yCoordinate = "\(point.y + 1)"
        return "\(xCoordinate)\(yCoordinate)"
    }
    
    // For seconds to time
    func formatTime(_ timeString: String) -> String {
        guard let totalSeconds = Int(timeString) else {
            return ""
        }
        
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        let formattedTime = String(format: "%02d:%02d", minutes, seconds)
        return formattedTime
    }
    
    // Responsive
    @State var profileImageSize: CGFloat = 0
    @State var userNameFont: Font = .body
    @State var userTitleFont: Font = .body
    @State var timerFont: Font = .callout
    @State var timerSpacing: CGFloat = 0
    @State var playerTurnFrameSizeWidth: CGFloat = 0
    @State var playerTurnFrameSizeHeight: CGFloat = 0
    @State var remainingMovesFont: Font = .body
    @State var timerBackground: CGFloat = 0
    @State var timerRoundedCorner: CGFloat = 0
    @State var boardSizeWidth: CGFloat = 0
    @State var boardSizeHeight: CGFloat = 0
    @State var inforHubPaddingBottom: CGFloat = 0
    @State var inforHubPaddingHorizontal: CGFloat = 8
    @State var capturedPieceImageSize: CGFloat = 0
    @State var capturedPaneFrameSize: CGFloat = 0
    @State var historyFrameSizeWidth: CGFloat = 0
    @State var historyFrameSizeHeight: CGFloat = 0
    @State var historyTextFont: Font = .caption
    @State var adminButtonSizeWidth: CGFloat = 0
    @State var adminButtonSizeHeight: CGFloat = 0
    @State var playerTurnRoundedCorner: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack(spacing: 0) {
                    ZStack {
                        // Infor hub
                        HStack {
                            // Player
                            VStack(alignment: .leading) {
                                Image(currentUser.profilePicture ?? "profile1")
                                    .resizable()
                                    .frame(width: profileImageSize, height: profileImageSize)
                                
                                VStack (alignment: .leading) {
                                    Text(currentUser.username ?? "Mudoker")
                                        .font(userNameFont)
                                    
                                    if CurrentUser.shared.rating < 800 {
                                        Text("Newbie")
                                            .opacity(0.7)
                                            .font(userTitleFont)
                                    } else if CurrentUser.shared.rating < 1300 {
                                        Text("Pro")
                                            .opacity(0.7)
                                            .font(userTitleFont)
                                    } else if CurrentUser.shared.rating < 1600 {
                                        Text("Master")
                                            .opacity(0.7)
                                            .font(userTitleFont)
                                    } else {
                                        Text("Grand Master")
                                            .opacity(0.7)
                                            .font(userTitleFont)
                                    }
                                }
                            }
                            
                            // Push view
                            Spacer()
                            
                            // Opponent
                            VStack(alignment: .trailing) {
                                Image(viewModel.blackPlayerName == "M.Carlsen" ? "magnus" : viewModel.blackPlayerName.lowercased())
                                    .resizable()
                                    .frame(width: profileImageSize, height: profileImageSize)
                                
                                VStack (alignment: .trailing) {
                                    Text(viewModel.blackPlayerName)
                                        .font(userNameFont)
                                    
                                    Text(LocalizedStringKey(viewModel.blackTitle))
                                        .opacity(0.7)
                                        .font(userTitleFont)
                                }
                            }
                        }
                        .padding(.horizontal, inforHubPaddingHorizontal)
                        .padding(.bottom, inforHubPaddingBottom)
                        
                        // Timer
                        VStack (spacing: timerSpacing) {
                            HStack {
                                if UIDevice.current.userInterfaceIdiom == .pad {
                                    Spacer()
                                }
                                
                                Text(formatTime(viewModel.whiteRemainigTime))
                                    .font(timerFont)
                                    .padding(10)
                                    .background(viewModel.currentPlayer == .white ?  Color.gray.opacity(0.7) : Color.gray.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: timerRoundedCorner))
                                    .frame(width: timerBackground)

                                Text(formatTime(viewModel.blackRemainigTime))
                                    .font(timerFont)
                                    .padding(10)
                                    .background(viewModel.currentPlayer == .white ? Color.gray.opacity(0.2) : Color.gray.opacity(0.7))
                                    .clipShape(RoundedRectangle(cornerRadius: timerRoundedCorner))
                                    .frame(width: timerBackground)
                                
                                // spacing
                                if UIDevice.current.userInterfaceIdiom == .pad {
                                    Spacer()
                                }
                            }
                            
                            // Player turn
                            ZStack {
                                RoundedRectangle(cornerRadius: proxy.size.width/40)
                                    .stroke(Color.blue, lineWidth: proxy.size.width/100)
                                    .background(Color.clear) // Set the background to clear to capture touches
                                    .frame(width: playerTurnFrameSizeWidth, height: playerTurnFrameSizeHeight)
                                
                                Text("\(viewModel.currentPlayer == .white ? (currentUser.username ?? "undefined") : (viewModel.blackPlayerName == "M.Carlsen" ? "Carlsen" : viewModel.blackPlayerName))'s Turn")
                                    .font(timerFont)
                                    .padding(10)
                                    .clipShape(RoundedRectangle(cornerRadius: playerTurnRoundedCorner))
                                    .scaleEffect(isExpanded ? 1 : 0.95) // Apply scale effect
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
                            }
                            
                            // Available moves
                            if viewModel.currentPlayer == .white {
                                if UIDevice.current.userInterfaceIdiom == .phone {
                                    Text("\(String(viewModel.chessGame.availableMoves)) moves left")
                                        .font(remainingMovesFont)
                                        .frame(height: proxy.size.width / 20)
                                } else {
                                    Text("\(String(viewModel.chessGame.availableMoves)) moves left")
                                        .font(remainingMovesFont)
                                        .frame(height: proxy.size.width / 40)
                                }
                            } else {
                                if UIDevice.current.userInterfaceIdiom == .phone {
                                    Text("Unlimited moves")
                                        .font(remainingMovesFont)
                                        .frame(height: proxy.size.width / 20)
                                } else {
                                    Text("Unlimited moves")
                                        .font(remainingMovesFont)
                                        .frame(height: proxy.size.width / 40)
                                }
                            }
                        }
                    }
                    
                    // Chess board
                    ForEach((0...7).reversed(), id: \.self) { y in
                        HStack(spacing: 0) {
                            ForEach(0...7, id: \.self) { x in
                                // REsponsive
                                if UIDevice.current.userInterfaceIdiom == .phone {
                                    GlassMorphicCard(
                                        isDarkMode: .constant(!(x + y).isMultiple(of: 2)),
                                        width: proxy.size.width / 8,
                                        height: proxy.size.width / 8,
                                        cornerRadius: 0,
                                        color: .constant(theme == "system" ? colorScheme == .dark ? UIBlurEffect.Style.light : UIBlurEffect.Style.dark : theme == "light" ? UIBlurEffect.Style.dark : UIBlurEffect.Style.light),
                                        isCustomColor: (x + y).isMultiple(of: 2)
                                    )
                                } else {
                                    GlassMorphicCard(
                                        isDarkMode: .constant(!(x + y).isMultiple(of: 2)),
                                        width: proxy.size.width / 8,
                                        height: proxy.size.width / 10,
                                        cornerRadius: 0,
                                        color: .constant(theme == "system" ? colorScheme == .dark ? UIBlurEffect.Style.light : UIBlurEffect.Style.dark : theme == "light" ? UIBlurEffect.Style.dark : UIBlurEffect.Style.light),
                                        isCustomColor: (x + y).isMultiple(of: 2)
                                    )
                                }
                            }
                        }
                    }
                    
                    // Captured list
                    HStack {
                        // get list of captures
                        let whiteCaptures = viewModel.chessGame.captures.filter { $0.pieceName.starts(with: "b") }
                        let blackCaptures = viewModel.chessGame.captures.filter { $0.pieceName.starts(with: "w") }
                        
                        // show at most 3 pieces
                        if whiteCaptures.count > 4 {
                            ForEach(0..<3, id: \.self) { index in
                                if index < whiteCaptures.count {
                                    let pieceName = whiteCaptures[index].pieceName
                                    if !pieceName.isEmpty {
                                        Image(pieceName)
                                            .resizable()
                                            .frame(width: capturedPieceImageSize, height: capturedPieceImageSize)
                                            .transition(AnyTransition.opacity.animation(.easeIn)) // animation
                                    }
                                }
                            }
                            Text("+\(whiteCaptures.count - 3)")
                        } else {
                            ForEach(whiteCaptures.indices, id: \.self) { index in
                                let pieceName = whiteCaptures[index].pieceName
                                if !pieceName.isEmpty {
                                    Image(pieceName)
                                        .resizable()
                                        .frame(width: capturedPieceImageSize, height: capturedPieceImageSize)
                                        .id(index)
                                        .transition(AnyTransition.opacity.animation(.easeIn)) // animation
                                }
                            }
                        }
                        
                        // Push view
                        Spacer()
                        
                        // Show at most 3 pieces
                        if blackCaptures.count > 4 {
                            ForEach(0..<3, id: \.self) { index in
                                if index < blackCaptures.count {
                                    let pieceName = blackCaptures[index].pieceName
                                    if !pieceName.isEmpty {
                                        Image(pieceName)
                                            .resizable()
                                            .frame(width: capturedPieceImageSize, height: capturedPieceImageSize)
                                            .transition(AnyTransition.opacity.animation(.easeIn)) // animation
                                    }
                                }
                            }
                            
                            Text("+\(blackCaptures.count - 3)")
                        } else {
                            ForEach(blackCaptures.indices, id: \.self) { index in
                                let pieceName = blackCaptures[index].pieceName
                                if !pieceName.isEmpty {
                                    Image(pieceName)
                                        .resizable()
                                        .frame(width: capturedPieceImageSize, height: capturedPieceImageSize)
                                        .transition(AnyTransition.opacity.animation(.easeIn)) // animation
                                }
                            }
                        }
                    }
                    .frame(height: proxy.size.height/22)
                    .padding(.horizontal)
                    .padding(.vertical)
                    
                    // Move histories
                    if viewModel.chessGame.history.value.isEmpty {
                        Text("Start a move!")
                            .font(.title3.bold())
                            .opacity(0.7)
                            .frame(height: proxy.size.height / 20)
                    } else {
                        // Horizontal scroll view
                        ScrollView(.horizontal, showsIndicators: false) {
                            ScrollViewReader { scrollProxy in
                                HStack(spacing: proxy.size.width/30) {
                                    ForEach(viewModel.chessGame.history.value.indices, id: \.self) { index in
                                        let move = viewModel.chessGame.history.value[index]
                                        Rectangle()
                                            .frame(width: proxy.size.width/6, height: proxy.size.width/12)
                                            .opacity(0.1)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: proxy.size.width/40)
                                                    .stroke(index % 2 == 0 ? Color.blue : Color.clear, lineWidth: proxy.size.width/100)
                                            )
                                            .overlay(
                                                Text("\(coordinateString(for: move.from))\(coordinateString(for: move.to))")
                                                    .multilineTextAlignment(.center)
                                                    .font(.caption)
                                            )
                                            .cornerRadius(proxy.size.width/40)
                                            .id(move)
                                    }
                                    .onChange(of: viewModel.chessGame.history.value.count) { _ in
                                        withAnimation {
                                            // automatically scroll to end
                                            scrollProxy.scrollTo(viewModel.chessGame.history.value.last, anchor: .trailing)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        .frame(height: proxy.size.height / 20)
                    }
                    
                    // Push view
                    Spacer()
                    
                    // REsponsive
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        // Buttons
                        HStack (spacing: 20) {
                            // New game
                            Button(action: {
                                // reset all
                                currentUser.hasActiveGame = false
                                user.hasActiveGame = false
                                user.savedGame?.history = []
                                user.savedGame?.captures = []
                                viewModel.chessGame.captures = []
                                viewModel.start()
                            }) {
                                VStack {
                                    Image(systemName: "plus.circle")
                                        .resizable()
                                        .frame(width: proxy.size.width/18, height: proxy.size.width/18)
                                    
                                    Text("New Game")
                                }
                            }
                            
                            // Resign
                            Button(action: {
                                viewModel.chessGame.outcome = .checkmate
                                viewModel.chessGame.winner = .black
                                currentUser.rating -= viewModel.chessGame.ratingChange.calculateRatingChange(playerRating: currentUser.rating, opponentRating: currentUser.settingDifficulty == "easy" ? 400 : currentUser.settingDifficulty == "medium" ? 1000 : 2000, result: viewModel.chessGame.outcome, difficulty: currentUser.settingDifficulty)
                            }) {
                                VStack {
                                    Image(systemName: "flag")
                                        .resizable()
                                        .frame(width: proxy.size.width/18, height: proxy.size.width/18)
                                    
                                    Text("Resign")
                                }
                            }
                        }
                        
                        // admin buttons
                        if currentUser.username == "admin" {
                            HStack (spacing: 20) {
                                // Force win
                                Button(action: {
                                    viewModel.chessGame.outcome = .checkmate
                                    viewModel.chessGame.winner = .white
                                    user.hasActiveGame = false
                                    currentUser.rating += viewModel.chessGame.ratingChange.calculateRatingChange(playerRating: currentUser.rating, opponentRating: currentUser.settingDifficulty == "easy" ? 400 : currentUser.settingDifficulty == "medium" ? 1000 : 2000, result: viewModel.chessGame.outcome, difficulty: currentUser.settingDifficulty)
                                }) {
                                    VStack {
                                        Text("Force Win")
                                            .frame(width: adminButtonSizeWidth, height: adminButtonSizeHeight)
                                            .foregroundColor(.green)
                                            .bold()
                                            .background(theme == "system" ? colorScheme == .dark ? Color.gray.opacity(0.3) : Color.black.opacity(0.5) : theme == "light" ? Color.black.opacity(0.5)  : Color.gray.opacity(0.3))
                                            .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/50))
                                    }
                                }
                                
                                // Force draw
                                Button(action: {
                                    viewModel.chessGame.outcome = .stalemate
                                    currentUser.rating += viewModel.chessGame.ratingChange.calculateRatingChange(playerRating: currentUser.rating, opponentRating: currentUser.settingDifficulty == "easy" ? 400 : currentUser.settingDifficulty == "medium" ? 1000 : 2000, result: viewModel.chessGame.outcome, difficulty: currentUser.settingDifficulty)
                                }) {
                                    VStack {
                                        Text("Force Draw")
                                            .frame(width: adminButtonSizeWidth, height: adminButtonSizeHeight)
                                            .foregroundColor(.yellow)
                                            .bold()
                                            .background(theme == "system" ? colorScheme == .dark ? Color.gray.opacity(0.3) : Color.black.opacity(0.5) : theme == "light" ? Color.black.opacity(0.5)  : Color.gray.opacity(0.3))
                                            .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/50))
                                    }
                                }
                                
                                // Forece draw
                                Button(action: {
                                    viewModel.chessGame.outcome = .checkmate
                                    viewModel.chessGame.winner = .black
                                    currentUser.rating -= viewModel.chessGame.ratingChange.calculateRatingChange(playerRating: currentUser.rating, opponentRating: currentUser.settingDifficulty == "easy" ? 400 : currentUser.settingDifficulty == "medium" ? 1000 : 2000, result: viewModel.chessGame.outcome, difficulty: currentUser.settingDifficulty)
                                    
                                    // Avoid negative rating
                                    if currentUser.rating < 0 {
                                        currentUser.rating = 0
                                    }
                                    
                                }) {
                                    VStack {
                                        Text("Force Lose")
                                            .frame(width: adminButtonSizeWidth, height: adminButtonSizeHeight)
                                            .foregroundColor(.red)
                                            .bold()
                                            .background(theme == "system" ? colorScheme == .dark ? Color.gray.opacity(0.3) : Color.black.opacity(0.5) : theme == "light" ? Color.black.opacity(0.5)  : Color.gray.opacity(0.3))
                                            .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/50))
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                    } else {
                        // The same as iphone
                        HStack (spacing: 20) {
                            Button(action: {
                                currentUser.hasActiveGame = false
                                user.hasActiveGame = false
                                user.savedGame?.history = []
                                user.savedGame?.captures = []
                                viewModel.chessGame.captures = []
                                viewModel.start()
                            }) {
                                VStack {
                                    Image(systemName: "plus.circle")
                                        .resizable()
                                        .frame(width: proxy.size.width/18, height: proxy.size.width/18)
                                    Text("New Game")
                                }
                            }
                            
                            Button(action: {
                                viewModel.chessGame.outcome = .checkmate
                                viewModel.chessGame.winner = .black
                                currentUser.rating -= viewModel.chessGame.ratingChange.calculateRatingChange(playerRating: currentUser.rating, opponentRating: currentUser.settingDifficulty == "easy" ? 400 : currentUser.settingDifficulty == "medium" ? 1000 : 2000, result: viewModel.chessGame.outcome, difficulty: currentUser.settingDifficulty)
                            }) {
                                VStack {
                                    Image(systemName: "flag")
                                        .resizable()
                                        .frame(width: proxy.size.width/18, height: proxy.size.width/18)
                                    Text("Resign")
                                }
                            }
                            
                            if currentUser.username == "admin" {
                                HStack (spacing: 20) {
                                    Button(action: {
                                        viewModel.chessGame.outcome = .checkmate
                                        viewModel.chessGame.winner = .white
                                        user.hasActiveGame = false
                                        currentUser.rating += viewModel.chessGame.ratingChange.calculateRatingChange(playerRating: currentUser.rating, opponentRating: currentUser.settingDifficulty == "easy" ? 400 : currentUser.settingDifficulty == "medium" ? 1000 : 2000, result: viewModel.chessGame.outcome, difficulty: currentUser.settingDifficulty)
                                    }) {
                                        VStack {
                                            Text("Force Win")
                                                .frame(width: adminButtonSizeWidth, height: adminButtonSizeHeight)
                                                .foregroundColor(.green)
                                                .bold()
                                                .background(theme == "system" ? colorScheme == .dark ? Color.gray.opacity(0.3) : Color.black.opacity(0.5) : theme == "light" ? Color.black.opacity(0.5)  : Color.gray.opacity(0.3))
                                                .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/50))
                                        }
                                    }
                                    
                                    Button(action: {
                                        viewModel.chessGame.outcome = .stalemate
                                        
                                        currentUser.rating += viewModel.chessGame.ratingChange.calculateRatingChange(playerRating: currentUser.rating, opponentRating: currentUser.settingDifficulty == "easy" ? 400 : currentUser.settingDifficulty == "medium" ? 1000 : 2000, result: viewModel.chessGame.outcome, difficulty: currentUser.settingDifficulty)
                                    }) {
                                        VStack {
                                            Text("Force Draw")
                                                .frame(width: adminButtonSizeWidth, height: adminButtonSizeHeight)
                                                .foregroundColor(.yellow)
                                                .bold()
                                                .background(theme == "system" ? colorScheme == .dark ? Color.gray.opacity(0.3) : Color.black.opacity(0.5) : theme == "light" ? Color.black.opacity(0.5)  : Color.gray.opacity(0.3))
                                                .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/50))
                                        }
                                    }
                                    
                                    Button(action: {
                                        viewModel.chessGame.outcome = .checkmate
                                        viewModel.chessGame.winner = .black
                                        
                                        currentUser.rating -= viewModel.chessGame.ratingChange.calculateRatingChange(playerRating: currentUser.rating, opponentRating: currentUser.settingDifficulty == "easy" ? 400 : currentUser.settingDifficulty == "medium" ? 1000 : 2000, result: viewModel.chessGame.outcome, difficulty: currentUser.settingDifficulty)
                                        
                                        if currentUser.rating < 0 {
                                            currentUser.rating = 0
                                        }
                                        
                                    }) {
                                        VStack {
                                            Text("Force Lose")
                                                .frame(width: adminButtonSizeWidth, height: adminButtonSizeHeight)
                                                .foregroundColor(.red)
                                                .bold()
                                                .background(theme == "system" ? colorScheme == .dark ? Color.gray.opacity(0.3) : Color.black.opacity(0.5) : theme == "light" ? Color.black.opacity(0.5)  : Color.gray.opacity(0.3))
                                                .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/50))
                                        }
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                }
            }
            .onAppear {
                // Responsive
                if UIDevice.current.userInterfaceIdiom == .phone {
                    profileImageSize = proxy.size.width/5
                    timerSpacing = proxy.size.width/30
                    playerTurnFrameSizeWidth = proxy.size.width / 2.6
                    playerTurnFrameSizeHeight = proxy.size.width / 8
                    timerBackground = proxy.size.width / 6
                    timerRoundedCorner = proxy.size.width/40
                    boardSizeWidth = proxy.size.width/8
                    boardSizeHeight = proxy.size.width/8
                    inforHubPaddingBottom = proxy.size.width/20
                    capturedPieceImageSize = proxy.size.width/15
                    capturedPaneFrameSize = proxy.size.height / 20
                    historyFrameSizeWidth = proxy.size.width/6
                    historyFrameSizeHeight = proxy.size.width/12
                    playerTurnRoundedCorner = proxy.size.width/35
                    adminButtonSizeWidth = proxy.size.width / 4
                    adminButtonSizeHeight = proxy.size.width / 10
                } else {
                    profileImageSize = proxy.size.width/8
                    timerSpacing = proxy.size.width/40
                    playerTurnFrameSizeWidth = proxy.size.width / 4
                    playerTurnFrameSizeHeight = proxy.size.width / 12
                    timerBackground = proxy.size.width / 8
                    userNameFont = .title
                    userTitleFont = .title2
                    remainingMovesFont = .title2
                    timerFont = .title
                    timerRoundedCorner = proxy.size.width/90
                    inforHubPaddingBottom = proxy.size.width/40
                    inforHubPaddingHorizontal = 32
                    capturedPieceImageSize = proxy.size.width/19
                    historyFrameSizeWidth = proxy.size.width/8
                    historyFrameSizeHeight = proxy.size.width/16
                    historyTextFont = .title2
                    adminButtonSizeWidth = proxy.size.width / 6
                    adminButtonSizeHeight = proxy.size.width / 14
                    playerTurnRoundedCorner = proxy.size.width/120
                }
            }
        }
        // theme
        .background(theme == "system" ? colorScheme == .dark ? darkBackground : lightBackground : theme == "light" ? lightBackground : darkBackground)
        .foregroundColor(theme == "system" ? colorScheme == .dark ? .white : Color.black : theme == "light" ? Color.black : Color.white)
        .preferredColorScheme(theme == "system" ? .init(colorScheme) : theme == "light" ? .light : .dark)
        .environment(\.locale, Locale(identifier: selectedLanguage)) // localization
    }
}

struct ChessBoardView_Previews: PreviewProvider {
    static var previews: some View {
        ChessBoardView(viewModel: GameViewModel(), user: Users())
    }
}
