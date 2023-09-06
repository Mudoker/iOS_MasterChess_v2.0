/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 18/08/2023
 Last modified: 03/09/2023
 Acknowledgement:
 Maciej. "Chess Simple Assets" figma.com https://www.figma.com/community/file/971870797656870866/Chess-Simple-Assets (accessed 18/08/2023)
 */

import SwiftUI

struct GameView: View {
    // Current user
    var currentUser = CurrentUser.shared
    
    // Current selected piece
    @State private var currentPiece: (ChessPiece?, CGSize) = (nil, .zero)
    
    // Watch the game state
    @StateObject var viewModel = GameViewModel()
    
    // Core Date
    @Environment(\.managedObjectContext) private var viewContext
    var user = Users()
    
    // Control state
    @State private var isRotatingWhite = true
    @State var show = true
    @State private var pulsingScale: CGFloat = 1.0
    @State private var isVibrating = false
    @State private var imageScale = 1.0
    @State var isShowPromotionModal = false
    @State private var selectedPiece = ""
    @State private var isAnimating = false
    var isDark = false
    @State var isMenu = false
    
    // Pulsing animation
    private func startPulsingAnimation() {
        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulsingScale = 1.1
        }
    }
    
    private func resetPulsingAnimation() {
        pulsingScale = 1.0
    }
    
    //Responsive
    @State var pieceImageSizeWidth1: CGFloat = 0
    @State var pieceImageSizeWidth2: CGFloat = 0
    @State var pieceImageSizeHeight1: CGFloat = 0
    @State var pieceImageSizeHeight2: CGFloat = 0
    @State var tileSizeWidth: CGFloat = 0
    @State var tileSizeHeight: CGFloat = 0
    @State var viewPush: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Overlay board view
                ChessBoardView(viewModel: viewModel, user: user)                
                VStack {
                    if proxy.size.height != 839 {
                        VStack{}
                            .frame(height: proxy.size.width/20)
                    } else if proxy.size.height == 1150 {
                        
                    } else {
                        VStack{}
                            .frame(height: proxy.size.width/26)
                    }
                    
                    // Load all pieces
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 8), spacing: 0) {
                        ForEach(0..<8) { y in
                            ForEach(0..<8) { x in
                                let currentPosition = Position(x: x, y: y)
                                let isMoveValid = viewModel.allValidMoves.contains { move in
                                    return move.to == currentPosition
                                }
                                
                                // Get piece at current position
                                if let piece = viewModel.getPiece(at: currentPosition) {
                                    let isCurrentPiece = currentPiece.0 == piece
                                    let pieceImage = Image(piece.imageView)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: pieceImageSizeWidth1, height: pieceImageSizeHeight1)
                                        .scaleEffect(0.8)
                                        .overlay(
                                            Circle()
                                                .fill(isMoveValid ? Color.blue.opacity(0.8) : .clear)
                                                .frame(width: isMoveValid ? 16 : 0, height: isMoveValid ? 16 : 0)
                                        )
                                        .offset(isCurrentPiece ? self.currentPiece.1 : .zero)
                                        .onTapGesture {
                                            // Tapping piece to move
                                            if piece.side == viewModel.currentPlayer {
                                                if isCurrentPiece {
                                                    self.currentPiece.0 = nil
                                                    viewModel.allValidMoves = []
                                                } else {
                                                    self.currentPiece = (piece, .zero)
                                                    viewModel.allMove(from: Position(x: x, y: y), piece: piece)
                                                }
                                            } else {
                                                if let selectedPiece = currentPiece.0 {
                                                    let move = Move(from: viewModel.indexOf(selectedPiece), to: currentPosition)
                                                    if viewModel.allValidMoves.contains(where: { $0 == move }) {
                                                        viewModel.didMove(move: move, piece: selectedPiece)
                                                        currentPiece.0 = nil
                                                        self.resetPulsingAnimation()
                                                    }
                                                }
                                            }
                                        }
                                        .gesture(self.dragGesture(piece)) // dragging piece to move
                                        .zIndex(isCurrentPiece ? 1 : 0) // ensure the current piece always appear on top
                                    
                                    // shaking if move invalid
                                    if isVibrating && piece == currentPiece.0{
                                        pieceImage.vibratingShaking(deadline: 1)
                                    } else {
                                        pieceImage
                                    }
                                } else {
                                    // Fill blanks with rectangles
                                    let currentPosition = Position(x: x, y: y)
                                    let isMoveValid = viewModel.allValidMoves.contains { move in
                                        return move.to == currentPosition
                                    }
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .overlay(
                                            ZStack {
                                                // show pulsing at places with valid moves
                                                if isMoveValid {
                                                    if ((currentPiece.0?.pieceName.hasPrefix("w")) != nil) {
                                                        PulsingView()
                                                    }
                                                }
                                            }
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            // On tap will move piece if valid
                                            if let selectedPiece = currentPiece.0 {
                                                let move = Move(from: viewModel.indexOf(selectedPiece), to: currentPosition)
                                                if viewModel.allValidMoves.contains(where: { $0 == move }) {
                                                    viewModel.didMove(move: move, piece: selectedPiece)
                                                    currentPiece.0 = nil
                                                    self.resetPulsingAnimation()
                                                    isVibrating = false
                                                } else {
                                                    // Vibrate if invalid move
                                                    isVibrating = true
                                                    if currentUser.settingSoundEnabled {
                                                        viewModel.playSound(sound: "illegal", type: "mp3")
                                                    }
                                                }
                                            }
                                        }
                                        .frame(width: tileSizeWidth, height: tileSizeHeight)
                                }
                            }
                        }
                    }
                    
                    // Push view
                    Spacer().frame(height: viewPush)
                }
            }
            .onAppear {
                // Responsive
                if UIDevice.current.userInterfaceIdiom == .phone {
                    pieceImageSizeWidth1 = proxy.size.width / 8
                    pieceImageSizeHeight1 = proxy.size.width / 8
                    tileSizeWidth = proxy.size.width / 8
                    tileSizeHeight = proxy.size.width / 8
                    viewPush = proxy.size.width / 4.5
                } else {
                    pieceImageSizeWidth1 = proxy.size.width / 8
                    pieceImageSizeHeight1 = proxy.size.width / 10
                    tileSizeWidth = proxy.size.width / 8
                    tileSizeHeight = proxy.size.width / 10
                    if proxy.size.width == 1024 {
                        viewPush = proxy.size.width / 19
                    } else {
                        viewPush = proxy.size.width / 7
                    }
                }
            }
            
            // Show pawn promotion panel
            if viewModel.chessGame.isPromotion {
                PromotionModal(viewModel: viewModel)
            }
            
            // Show game over view
            if viewModel.chessGame.outcome != .ongoing {
                ModalView(viewModel: viewModel, user: user)
            }
        }
        .onAppear {
            // Start new game
            self.viewModel.start()
        }
        .onChange(of: viewModel.currentPlayer) { newCurrentPlayer in
            // When a player has moved, store to Core Data
            let savedGame = SavedGame(context: viewContext)
            savedGame.boardSetup = viewModel.convertChessPieceArrayToStringArray(viewModel.chessGame.piecePositions.value)
            
            var sequenceNumber: Int16 = 0 // Initialize a sequence number
            
            // Convert moves to array of integers to save
            for historyItem in viewModel.chessGame.history.value {
                let integerOffsetsList = convertHistoryToIntegerOffsets(history: [historyItem])
                let movements = convertIntegerOffsetsToMovements(integerOffsetsList: integerOffsetsList)
                for movement in movements {
                    let savedMovement = Movement(context: viewContext)
                    savedMovement.start = movement.start
                    savedMovement.end = movement.end
                    savedMovement.order = sequenceNumber
                    savedGame.addToHistory(savedMovement)
                    sequenceNumber += 1 // Increment the sequence number
                }
            }
            
            // list of captures
            let captures: [String] = viewModel.chessGame.captures.map { $0.pieceName }
            
            // Current game state
            savedGame.captures = captures
            savedGame.kingPosition = positionToInt16(position: viewModel.chessGame.kingPosition)
            savedGame.isWhiteKingMoved = viewModel.chessGame.isWhiteKingMoved
            savedGame.isBlackKingMoved = viewModel.chessGame.isBlackKingMoved
            savedGame.isBlackLeftRookMoved = viewModel.chessGame.isBlackLeftRookMoved
            savedGame.isBlackRightRookMoved = viewModel.chessGame.isBlackRightRookMoved
            savedGame.isWhiteLeftRookMoved = viewModel.chessGame.isWhiteLeftRookMoved
            savedGame.isWhiteRightRookMoved = viewModel.chessGame.isWhiteRightRookMoved
            savedGame.whiteTimeLeft = Double(viewModel.chessGame.whiteTimeLeft)
            savedGame.blackTimeLeft = Double(viewModel.chessGame.blackTimeLeft)
            savedGame.moveAvailable = Int16(viewModel.chessGame.availableMoves)
            savedGame.currentPlayer = viewModel.chessGame.currentPlayer == .white ? "w" : "b"
            savedGame.difficulty = currentUser.savedGameDifficulty
            
            // Toggle active game
            currentUser.hasActiveGame = true
            user.hasActiveGame = true
            user.savedGame = savedGame
            
            // save to CoreData
            try? viewContext.save()
        }
    }
    
    // Drag piece to move
    private func dragGesture(_ piece: ChessPiece) -> some Gesture {
        DragGesture()
            .onChanged { dragValue in
                self.currentPiece = (piece, dragValue.translation)
                self.viewModel.objectWillChange.send()
            }
            .onEnded { dragValue in
                // Drag to a position, if valid will move piece to that
                let finalPosition = self.viewModel.indexOf(piece) + Position(dragValue.translation)
                let move = Move(from: self.viewModel.indexOf(piece), to: finalPosition)
                viewModel.allMove(from: move.from, piece: piece)
                self.viewModel.didMove(move: move, piece: currentPiece.0 ?? ChessPiece(stringLiteral: ""))
                try? viewContext.save()
                
                self.currentPiece = (nil, .zero)
            }
    }
    
    // Convert the move history to Integer to store in CoreData
    func convertHistoryToIntegerOffsets(history: [Move]) -> [[Int]] {
        var integerOffsets: [[Int]] = []
        
        for move in history {
            let startX = move.from.x
            let startY = move.from.y
            let endX = move.to.x
            let endY = move.to.y
            
            let startValue = startX * 10 + startY
            let endValue = endX * 10 + endY
            
            integerOffsets.append([startValue, endValue])
        }
        
        return integerOffsets
    }
    
    // convert from integers back to movements
    func convertIntegerOffsetsToMovements(integerOffsetsList: [[Int]]) -> [Movement]{
        var movements: [Movement] = []
        for integerOffsets in integerOffsetsList {
            guard integerOffsets.count >= 2 else {
                // Each integerOffsets array should have at least 2 values
                continue
            }
            
            let startValue = integerOffsets[0]
            let endValue = integerOffsets[1]
            
            let startX = (startValue) / 10
            let startY = (startValue) % 10
            let endX = (endValue) / 10
            let endY = (endValue) % 10
            
            let newMovement = Movement(context: viewContext)
            newMovement.start = Int16(startX * 10 + startY)
            newMovement.end = Int16(endX * 10 + endY)
            
            movements.append(newMovement)
        }
        return movements
    }
    
    // convert 1 integer to 1 movement
    func convertIntegerOffsetToMovement(integerOffsets: [Int]) -> Movement{
        guard integerOffsets.count >= 2 else {
            // Each integerOffsets array should have at least 2 values
            return Movement()
        }
        
        let startValue = integerOffsets[0]
        let endValue = integerOffsets[1]
        
        let startX = (startValue) / 10
        let startY = (startValue) % 10
        let endX = (endValue) / 10
        let endY = (endValue) % 10
        
        let newMovement = Movement(context: viewContext)
        newMovement.start = Int16(startX * 10 + startY)
        newMovement.end = Int16(endX * 10 + endY)
        
        return newMovement
    }
    
    // convert array of ChessPiece to strings of pieces' names
    func convertChessPieceArrayToStrings(chessPieceArray: [[ChessPiece?]]) -> [[String]] {
        var stringArray: [[String]] = []
        
        for row in chessPieceArray {
            var rowStrings: [String] = []
            
            for piece in row {
                if let piece = piece {
                    rowStrings.append(piece.pieceName)
                } else {
                    rowStrings.append("") // Placeholder for empty cells
                }
            }
            stringArray.append(rowStrings)
        }
        
        return stringArray
    }
    
    // convert postion to int
    func positionToInt16(position: Position) -> Int16 {
        let int16Value = Int16(position.x * 10 + position.y)
        return int16Value
    }
}

// overide + for adding with cgsize
func +(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
