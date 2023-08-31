

import Foundation
import Combine
import SwiftUI
import AVFoundation

class ChessBoard: ObservableObject, NSCopying {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Users.username, ascending: true)], animation: .default) private var users: FetchedResults<Users>
    var currentUser = CurrentUser.shared
    var piecePositions: CurrentValueSubject<[[ChessPiece?]], Never> = CurrentValueSubject([])
    var audioPlayer = AVAudioPlayer()
    @Published var currentPlayer = Player.white
    @Published var isChecked = false
    var activePieces: [ChessPiece] {
        piecePositions.value.flatMap { $0 }.compactMap { $0 }
    }
    @Published var currentPlayerIsInCheck = false
    var isSoundPlayed = false
    // Calculate the rating change based on game result, player ratings, and difficulty
    let ratingChange = RatingCalculator.shared
    var currentRating = 0
    @Published var whiteTimeLeft = 0 // Initialize with default value
    @Published var blackTimeLeft = 0// Initialize with default value
    @Published var cancellables = Set<AnyCancellable>()
    @Published var timer = Timer.publish(every: 1.0, on: .main, in: .common)
    var history: CurrentValueSubject<[Move], Never> = CurrentValueSubject([])
    @Published var kingPosition: Position = Position(x: 4, y: 7)
    @Published var whiteKingPosition: Position = Position(x: 0, y: 0)
    @Published var blackKingPosition: Position = Position(x: 0, y: 0)
    @Published var isWhiteKingMoved = false
    @Published var isWhiteRightRookMoved = false
    @Published var isWhiteLeftRookMoved = false
    @Published var isBlackKingMoved = false
    @Published var isBlackRightRookMoved = false
    @Published var isBlackLeftRookMoved = false
    @Published var winner: Player = .white
    @Published var allValidMoves: [Move] = []
    @Published var outcome: GameResult = .ongoing
    @Published var captures: [ChessPiece] = []
    @Published var availableMoves = 0
    @Published var promoteType: PieceType = .queen
    @Published var isPromotion = false
    @Published var isEnpassant = false
    
    func getUserWithUsername(_ username: String) -> Users? {
        return users.first { $0.username == username }
    }
    // Start new game
    func createInitialBoard() -> [[ChessPiece?]] {
        var piecePositions = Array(repeating: Array<ChessPiece?>(repeating: nil, count: Constant.boardSize), count: Constant.boardSize)
        for (rank, files) in Constant.initialBoardSetup.enumerated() {
            for (file, pieceCode) in files.enumerated() {
                if pieceCode != "" {
                    let piece = ChessPiece(stringLiteral: pieceCode)
                    if pieceCode == "bk"{
                        blackKingPosition = Position(x: file, y: rank)
                    } else if pieceCode == "wk" {
                        whiteKingPosition = Position(x: file, y: rank)
                    }
                    piecePositions[rank][file] = piece
                } else {
                    piecePositions[rank][file] = nil
                }
            }
        }
        return piecePositions
    }
    
    // Load game from saved
    func createBoardFromLoad() -> [[ChessPiece?]] {
        var piecePositions = Array(repeating: Array<ChessPiece?>(repeating: nil, count: Constant.boardSize), count: Constant.boardSize)
        let unwrappedBoardSetup = currentUser.savedGameBoardSetup
        for (rank, files) in unwrappedBoardSetup.enumerated() {
            for (file, pieceCode) in files.enumerated() {
                if pieceCode != "" {
                    let piece = ChessPiece(stringLiteral: pieceCode)
                    if pieceCode == "bk"{
                        blackKingPosition = Position(x: file, y: rank)
                    } else if pieceCode == "wk" {
                        whiteKingPosition = Position(x: file, y: rank)
                    }
                    piecePositions[rank][file] = piece
                } else {
                    piecePositions[rank][file] = nil
                    
                }
            }
        }
        
        return piecePositions
    }
    
    func start() {
        // Clean up any existing cancellables
        cancellables.removeAll()
        // Create a timer that publishes every 1.0 seconds on the main thread in a common mode
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
        timer.connect().store(in: &cancellables)
        
        // Set up the initial game state
        if currentUser.hasActiveGame {
            // Load board from saved
            piecePositions.value = createBoardFromLoad() // Populate piecePositions
            
            if let currentUserr = getUserWithUsername(currentUser.username ?? "") {
                let savedGame = currentUserr.savedGame // Get the saved game from currentUserr

//                currentUser.savedGameBoardSetup = savedGame?.boardSetup ?? [[]]
//                currentUser.savedGameAutoPromotionEnabled = savedGame?.autoPromotionEnabled ?? false
//                currentUser.savedGameBlackTimeLeft = savedGame?.blackTimeLeft ?? 0
//                currentUser.savedGameWhiteTimeLeft = savedGame?.whiteTimeLeft ?? 0
//                currentUser.savedGameCurrentPlayer = savedGame?.currentPlayer ?? "w"
//                currentUser.savedGameDifficulty = savedGame?.difficulty ?? "easy"
//                currentUser.savedGameIsBlackKingMoved = savedGame?.isBlackKingMoved ?? false
//                currentUser.savedGameIsWhiteKingMoved = savedGame?.isWhiteKingMoved ?? false
//                currentUser.savedGameIsWhiteLeftRookMoved = savedGame?.isWhiteLeftRookMoved ?? false
//                currentUser.savedGameIsWhiteRightRookMoved = savedGame?.isWhiteRightRookMoved ?? false
//                currentUser.savedGameIsBlackLeftRookMoved = savedGame?.isBlackLeftRookMoved ?? false
//                currentUser.savedGameIsBlackRightRookMoved = savedGame?.isBlackRightRookMoved ?? false
                
                if let histories = savedGame?.unwrappedHistory {
                    history.value = convertMovementsToMoves(movements: histories)
                }
            }
            whiteTimeLeft = Int(currentUser.savedGameWhiteTimeLeft)
            blackTimeLeft = Int(currentUser.savedGameBlackTimeLeft)

            
            
        } else {
            // Create new board
            piecePositions.value = createInitialBoard() // Populate piecePositions
            
            // save current board to currentUser
            currentUser.savedGameBoardSetup = Constant.initialBoardSetup
            
            // White starts first
            currentPlayer = .white
            // Limit 30 moves for grandmaster and 50 for master
            availableMoves = currentUser.rating >= 1600 ? 30 : currentUser.rating >= 1300 ? 40 : 100
            let initialTimeLimit: TimeInterval = currentUser.rating > 1300 ? 10 * 60 : 25 * 60
            whiteTimeLeft = Int(initialTimeLimit)
            blackTimeLeft = Int(initialTimeLimit)
        }
        currentRating = currentUser.rating
        // Start the clocks to begin tracking time
        startClocks()
        playSound(sound: "game-start", type: "mp3")
    }
    
    func getPiece(at position: Position) -> ChessPiece? {
        if piecePositions.value.isEmpty {
            return nil
        }
        return piecePositions.value[position.y][position.x]
    }
    
    func getPiece(_ piece: ChessPiece) -> Position {
        if let index = piecePositions.value.flatMap({ $0 }).firstIndex (where: { $0?.id == piece.id }) {
            return Position(x: index % 8, y: index / 8)
        }
        return Position(x: -1, y: -1)
    }
    
    func movePiece(from start: Position, to end: Position) {
        if allValidMoves.first(where: { $0.from == start && $0.to == end }) != nil {
            guard start.isValid && end.isValid else {
                print("invalid")
                return
            }
            // Create a copy of piecePositions
            let updatedPiecePositions = piecePositions
            
            // Check if a piece exists at the starting position
            if let movingPiece = updatedPiecePositions.value[start.y][start.x] {
                // Move the piece
                updatedPiecePositions.value[start.y][start.x] = nil
                // Check for capture
                if let endPiece = piecePositions.value[end.y][end.x] {
                    captures.append(endPiece)
                    playSound(sound: "capture", type: "mp3")
                    isSoundPlayed = true
                } else { // List of captured pieces and enpassant
                    let verticalDir = currentPlayer == .white ? 1 : -1
                    // if there is no capture at the destination but pawn still move diagonally -> en passant
                    if movingPiece.pieceType == .pawn && abs(end.x - start.x) == 1 {
                        if currentPlayer == .white {
                            captures.append(ChessPiece(stringLiteral: "bp"))
                        } else {
                            captures.append(ChessPiece(stringLiteral: "wp"))
                        }
                        playSound(sound: "capture", type: "mp3")
                        isSoundPlayed = true
                        updatedPiecePositions.value[end.y + verticalDir][end.x] = nil
                    }
                    
                }
                // Check if castling
                if movingPiece.pieceType == .king {
                    if movingPiece.side == .white {
                        if start.x == 4 && end.x == 6 {
                            updatedPiecePositions.value[7][7] = nil
                            updatedPiecePositions.value[7][5] = ChessPiece(stringLiteral: "wr")
                            isWhiteRightRookMoved = true
                        } else if start.x == 4 && end.x == 2 {
                            // Castling to the right for white
                            updatedPiecePositions.value[7][0] = nil
                            updatedPiecePositions.value[7][3] = ChessPiece(stringLiteral: "wr")
                            isWhiteLeftRookMoved = true
                        }
                        isWhiteKingMoved = true
                        whiteKingPosition = Position(x: end.x, y: end.y)
                        kingPosition = whiteKingPosition
                    } else {
                        if start.x == 4 && end.x == 6 {
                            updatedPiecePositions.value[0][7] = nil
                            updatedPiecePositions.value[0][5] = ChessPiece(stringLiteral: "br")
                            isBlackRightRookMoved = true
                        } else if start.x == 4 && end.x == 2 {
                            // Castling to the right for white
                            updatedPiecePositions.value[0][0] = nil
                            updatedPiecePositions.value[0][3] = ChessPiece(stringLiteral: "br")
                            isBlackLeftRookMoved = true
                        }
                        isBlackKingMoved = true
                        blackKingPosition = Position(x: end.x, y: end.y)
                        kingPosition = blackKingPosition
                    }
                    playSound(sound: "castle", type: "mp3")
                    isSoundPlayed = true
                } else if movingPiece.pieceType == .rook { // Turn on or off Castling
                    if movingPiece.side == .white {
                        if start.x == 0 {
                            isWhiteLeftRookMoved = true
                        } else {
                            isWhiteRightRookMoved = true
                        }
                    } else {
                        if start.x == 0 {
                            isBlackLeftRookMoved = true
                        } else {
                            isBlackRightRookMoved = true
                        }
                    }
                }
                
                // Must update to allow custom promotion
                if movingPiece.pieceType == .pawn && (end.y == 7 || end.y == 0) {
                    if currentPlayer == .white {
                        if currentUser.settingAutoPromotionEnabled {
                            isPromotion = true
                        } else {
                            updatedPiecePositions.value[end.y][end.x] = ChessPiece(stringLiteral: "wq")
                        }
                    } else {
                        updatedPiecePositions.value[end.y][end.x] = ChessPiece(stringLiteral: "bq")
                    }
                } else {
                    updatedPiecePositions.value[end.y][end.x] = movingPiece
                    if !isSoundPlayed {
                        playSound(sound: "move-self", type: "mp3")
                        isSoundPlayed = true
                    }
                }
                
                
                
                // Update the piecePositions with the new value
                piecePositions = updatedPiecePositions
                
                // Update the boardSetup in SavedGame
                currentUser.savedGameBoardSetup[end.y][end.x] = currentUser.savedGameBoardSetup[start.y][start.x]
                currentUser.savedGameBoardSetup[start.y][start.x] = ""
                
                
                // For every move of user then minus one (Not applicable for AI)
                availableMoves = currentPlayer == .white ? availableMoves - 1 : availableMoves
                
                // Switch to the next player's turn
                currentPlayer = (currentPlayer == .white) ? .black : .white
                currentUser.savedGameCurrentPlayer = currentPlayer == .black ? "b" : "w"
                // Store move history
                history.value.append(Move(from: Position(x: start.x, y: start.y), to: Position(x: end.x, y: end.y)))
                
                if let currentUsername = currentUser.username {
                    if let currentUserr = getUserWithUsername(currentUsername) {
                        currentUserr.savedGame?.boardSetup = currentUser.savedGameBoardSetup
                        currentUserr.savedGame?.autoPromotionEnabled = currentUser.savedGameAutoPromotionEnabled
                        currentUserr.savedGame?.blackTimeLeft = currentUser.savedGameBlackTimeLeft
                        currentUserr.savedGame?.whiteTimeLeft = currentUser.savedGameWhiteTimeLeft
                        currentUserr.savedGame?.currentPlayer = currentUser.savedGameCurrentPlayer
                        currentUserr.savedGame?.difficulty = currentUser.savedGameDifficulty
                        currentUserr.savedGame?.isBlackKingMoved = currentUser.savedGameIsBlackKingMoved
                        currentUserr.savedGame?.isWhiteKingMoved = currentUser.savedGameIsWhiteKingMoved
                        currentUserr.savedGame?.isWhiteLeftRookMoved = currentUser.savedGameIsWhiteLeftRookMoved
                        currentUserr.savedGame?.isWhiteRightRookMoved = currentUser.savedGameIsWhiteRightRookMoved
                        currentUserr.savedGame?.isBlackLeftRookMoved = currentUser.savedGameIsBlackLeftRookMoved
                        currentUserr.savedGame?.isBlackRightRookMoved = currentUser.savedGameIsBlackRightRookMoved
                        currentUserr.savedGame?.kingPosition = currentUser.savedGameKingPosition
                        convertIntegerOffsetsToMovements(integerOffsetsList: convertHistoryToIntegerOffsets(history: history.value))
                    }
                }
                
                
                if isCheckMate(player: currentPlayer) || isStaleMate(player: currentPlayer) ||
                   isOutOfMove(player: currentPlayer) || isOutOfTime(player: currentPlayer) ||
                   isInsufficientMaterial(player: currentPlayer) {
                    playSound(sound: "game-end", type: "mp3")
                    if winner == .white {
                        currentUser.rating += ratingChange.calculateRatingChange(playerRating: currentUser.rating, opponentRating: currentUser.settingDifficulty == "easy" ? 400 : currentUser.settingDifficulty == "medium" ? 1000 : 2000, result: outcome, difficulty: currentUser.settingDifficulty)
                    } else {
                        currentUser.rating -= ratingChange.calculateRatingChange(playerRating: currentUser.rating, opponentRating: currentUser.settingDifficulty == "easy" ? 400 : currentUser.settingDifficulty == "medium" ? 1000 : 2000, result: outcome, difficulty: currentUser.settingDifficulty)
                        if currentUser.rating < 0 {
                            currentUser.rating = 0
                        }
                    }
                } else {
                    print(outcome)
                }
                isSoundPlayed = false
            } else {
                print("No piece found at the starting position.")
            }
        } else {
            print("Invalid move.")
        }
    }
    
    func movePieceAI(from start: Position, to end: Position) {
        guard start.isValid && end.isValid else {
                return
        }
        // Create a copy of piecePositions
        let updatedPiecePositions = piecePositions
        
        // Check if a piece exists at the starting position
        if let movingPiece = updatedPiecePositions.value[start.y][start.x] {
            // Move the piece
            updatedPiecePositions.value[start.y][start.x] = nil
            if let endPiece = piecePositions.value[end.y][end.x] {
                captures.append(endPiece)
            } else { // List of captured pieces
                let verticalDir = currentPlayer == .white ? 1 : -1
                if movingPiece.pieceType == .pawn && abs(end.x - start.x) == 1 {
                    if currentPlayer == .white {
                        captures.append(ChessPiece(stringLiteral: "bp"))
                    } else {
                        captures.append(ChessPiece(stringLiteral: "wp"))
                    }
                    updatedPiecePositions.value[end.y + verticalDir][end.x] = nil
                }
            }
            if movingPiece.pieceType == .pawn && (end.y == 7 || end.y == 0) {
                if currentPlayer == .white {
                    updatedPiecePositions.value[end.y][end.x] = ChessPiece(stringLiteral: "wq")
                } else {
                    updatedPiecePositions.value[end.y][end.x] = ChessPiece(stringLiteral: "bq")
                }
            } else {
                updatedPiecePositions.value[end.y][end.x] = movingPiece
            }

            // Check if castling
            if movingPiece.pieceType == .king {
                if movingPiece.side == .white {
                    if start.x == 4 && end.x == 6 {
                        updatedPiecePositions.value[7][7] = nil
                        updatedPiecePositions.value[7][5] = ChessPiece(stringLiteral: "wr")
                        isWhiteRightRookMoved = true
                    } else if start.x == 4 && end.x == 2 {
                        // Castling to the right for white
                        updatedPiecePositions.value[7][0] = nil
                        updatedPiecePositions.value[7][3] = ChessPiece(stringLiteral: "wr")
                        isWhiteLeftRookMoved = true
                    }
                    isWhiteKingMoved = true
                    whiteKingPosition = Position(x: end.x, y: end.y)
                    kingPosition = whiteKingPosition
                } else {
                    if start.x == 4 && end.x == 6 {
                        updatedPiecePositions.value[0][7] = nil
                        updatedPiecePositions.value[0][5] = ChessPiece(stringLiteral: "br")
                        isBlackRightRookMoved = true
                    } else if start.x == 4 && end.x == 2 {
                        // Castling to the right for white
                        updatedPiecePositions.value[0][0] = nil
                        updatedPiecePositions.value[0][3] = ChessPiece(stringLiteral: "br")
                        isBlackLeftRookMoved = true
                    }
                    isBlackKingMoved = true
                    blackKingPosition = Position(x: end.x, y: end.y)
                    kingPosition = blackKingPosition
                }
            } else if movingPiece.pieceType == .rook { // Turn on or off Castling
                if movingPiece.side == .white {
                    if start.x == 0 {
                        isWhiteLeftRookMoved = true
                    } else {
                        isWhiteRightRookMoved = true
                    }
                } else {
                    if start.x == 0 {
                        isBlackLeftRookMoved = true
                    } else {
                        isBlackRightRookMoved = true
                    }
                }
            }
            
            // Update the piecePositions with the new value
            piecePositions = updatedPiecePositions
            
            // Update the boardSetup in SavedGame
            currentUser.savedGameBoardSetup[end.y][end.x] = currentUser.savedGameBoardSetup[start.y][start.x]
            currentUser.savedGameBoardSetup[start.y][start.x] = ""
            
            // Store move history
            history.value.append(Move(from: Position(x: start.x, y: start.y), to: Position(x: end.x, y: end.y)))
            
            // Switch to the next player's turn
            currentPlayer = (currentPlayer == .white) ? .black : .white
            
            if let currentUsername = currentUser.username {
                if let currentUserr = getUserWithUsername(currentUsername) {
                    currentUserr.savedGame?.boardSetup = currentUser.savedGameBoardSetup
                    currentUserr.savedGame?.autoPromotionEnabled = currentUser.savedGameAutoPromotionEnabled
                    currentUserr.savedGame?.blackTimeLeft = currentUser.savedGameBlackTimeLeft
                    currentUserr.savedGame?.whiteTimeLeft = currentUser.savedGameWhiteTimeLeft
                    currentUserr.savedGame?.currentPlayer = currentUser.savedGameCurrentPlayer
                    currentUserr.savedGame?.difficulty = currentUser.savedGameDifficulty
                    currentUserr.savedGame?.isBlackKingMoved = currentUser.savedGameIsBlackKingMoved
                    currentUserr.savedGame?.isWhiteKingMoved = currentUser.savedGameIsWhiteKingMoved
                    currentUserr.savedGame?.isWhiteLeftRookMoved = currentUser.savedGameIsWhiteLeftRookMoved
                    currentUserr.savedGame?.isWhiteRightRookMoved = currentUser.savedGameIsWhiteRightRookMoved
                    currentUserr.savedGame?.isBlackLeftRookMoved = currentUser.savedGameIsBlackLeftRookMoved
                    currentUserr.savedGame?.isBlackRightRookMoved = currentUser.savedGameIsBlackRightRookMoved
                    currentUserr.savedGame?.kingPosition = currentUser.savedGameKingPosition
                    convertIntegerOffsetsToMovements(integerOffsetsList: convertHistoryToIntegerOffsets(history: history.value))
                }
            }
            
        } else {
            print("No piece found at the starting position.")
            print("Start: \(start.x), \(start.y)")
            print("End: \(end.x), \(end.y)")
            print("Current Player for not found")
            print(currentPlayer)
            print("-----")
        }
    }
    // Remove a piece at specific location
    func removePiece(at position: Position) {
        let updatedPiecePositions = piecePositions
        updatedPiecePositions.value[position.y][position.x] = nil
        piecePositions = updatedPiecePositions
        
    }
    
    // Promote a pawn when reach the end of board
    func promotePiece(at position: Position, to type: PieceType, player: Player) {
        let getCurrentSide = player == .white ? "w" : "b"
        let pieceName = getCurrentSide + String(type.rawValue.first!)
        let promotedPiece = ChessPiece(stringLiteral: pieceName)
        let updatedPiecePositions = piecePositions
        updatedPiecePositions.value[position.y][position.x] = promotedPiece
        piecePositions = updatedPiecePositions
    }
    
    // Check if a move from A to B of pawn is valid
    func validPawnMove(board: [[ChessPiece?]], from start: Position, to end: Position, history: [Move], player: Player) -> Bool {
        guard start.isValid && end.isValid else {
                return false
        }
        let deltaX = abs(start.x - end.x)
        let deltaY = end.y - start.y
        // Simulate the movement (to check if after the movement will left the current king in check)
        var tempBoard = board
        tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
        tempBoard[start.y][start.x] = nil
        
        // Check for diagonal move
        if deltaX == 1 {
            if !history.isEmpty {
                // Check for en passant
                if deltaY == (player == .white ? -1 : 1) {
                    if let lastMove = history.last, lastMove.to.x == end.x {
                        if let piece = board[lastMove.to.y][lastMove.to.x], piece.pieceType == .pawn, piece.side != player {
                            if (player == .white && lastMove.from.y == end.y - 1 && lastMove.to.y == end.y + 1) ||
                                (player == .black && lastMove.from.y == end.y + 1 && lastMove.to.y == end.y - 1) {
                                if !isKingInCheck(board: tempBoard, player: currentPlayer) {
                                    isEnpassant = true
                                    return true
                                }
                            }
                        }
                    }
                }
            }
            
            // Capture
            if let destinationPiece = board[end.y][end.x] {
                // Check if the destination piece belongs to the same player
                if destinationPiece.side == player {
                    return false
                }
                
                return deltaY == (player == .white ? -1 : 1) && !isKingInCheck(board: tempBoard, player: currentPlayer)
            }
        }
        
        // Check for vertical move
        if deltaX == 0 {
            let middleY = start.y + (player == .white ? -1 : 1)
            
            if deltaY == (player == .white ? -1 : 1) {
                // Check if the destination is empty
                if board[end.y][end.x] == nil {
                    return !isKingInCheck(board: tempBoard, player: currentPlayer)
                }
            } else if deltaY == (player == .white ? -2 : 2) {
                // Check for the initial double move of the pawn
                if board[end.y][end.x] == nil && board[middleY][start.x] == nil {
                    // Make sure it's the initial move for the pawn
                    if (player == .white && start.y == 6) || (player == .black && start.y == 1) {
                        return !isKingInCheck(board: tempBoard, player: currentPlayer)
                    }
                }
            }
        }
        return false
    }
    
    // Show all available moves for a pawn
    func allValidPawnMoves(board: [[ChessPiece?]], from start: Position, history: [Move]) -> [Move]{
        allValidMoves.removeAll()
        let directions: [Position] = [
            Position(x: 0, y: currentPlayer == .white ? -1 : 1), // Forward 1 move
            Position(x: 1, y: currentPlayer == .white ? -1 : 1), // Diagonal right capture
            Position(x: -1, y: currentPlayer == .white ? -1 : 1), // Diagonal left capture
            Position(x: 0, y: currentPlayer == .white ? -2 : 2), // Forward 2 moves
        ]
        
        for direction in directions {
            let destination = start + direction
            
            // Check if the destination is valid
            guard destination.isValid else {
                continue
            }
            
            // For every valid move will add to the current array -> show available moves on screen
            if validPawnMove(board: board, from: start, to: destination, history: history, player: currentPlayer) {
                allValidMoves.append(Move(from: start, to: destination))
            }
        }
        return allValidMoves
    }
    
    // L-shape movement for Knight
    func validKnightMove(board: [[ChessPiece?]],from start: Position, to end: Position, player: Player) -> Bool {
        guard start.isValid && end.isValid else {
                return false
        }
        let deltaX = abs(end.x - start.x)
        let deltaY = abs(end.y - start.y)
        
        if deltaX == 1 && deltaY == 2 {
            // Simulate the movement
            var tempBoard = board
            tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
            tempBoard[start.y][start.x] = nil
            
            // check if destination is our piece
            if piecePositions.value[end.y][end.x]?.side == player {
                return false
            }
            
            // if move to that position not lead to king in check
            if !isKingInCheck(board: tempBoard, player: currentPlayer) {
                return true
            }
        } else if deltaX == 2 && deltaY == 1 {
            // The same as above
            var tempBoard = board
            tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
            tempBoard[start.y][start.x] = nil
            
            if piecePositions.value[end.y][end.x]?.side == player {
                return false
            }
            
            if !isKingInCheck(board: tempBoard, player: currentPlayer) {
                return true
            }
        }
        
        return false
    }
    
    // All L-shape movement for Knight
    func allValidKnightMoves(board: [[ChessPiece?]], from start: Position) -> [Move] {
        allValidMoves.removeAll()
        let possibleMoves: [Position] = [
            Position(x: start.x + 1, y: start.y + 2),
            Position(x: start.x + 1, y: start.y - 2),
            Position(x: start.x - 1, y: start.y + 2),
            Position(x: start.x - 1, y: start.y - 2),
            Position(x: start.x + 2, y: start.y + 1),
            Position(x: start.x + 2, y: start.y - 1),
            Position(x: start.x - 2, y: start.y + 1),
            Position(x: start.x - 2, y: start.y - 1)
        ]
        
        for move in possibleMoves {
            // Check if the destination is valid
            guard move.isValid else {
                continue
            }
            // Add all availables move -> show all available moves on screen
            if validKnightMove(board: board, from: start, to: move, player: currentPlayer) {
                allValidMoves.append(Move(from: start, to: move))
            }
        }
        return allValidMoves
    }
    
    // Validate king move
    private func validKingMove(board: [[ChessPiece?]], from start: Position, to end: Position, player: Player) -> Bool {
        guard start.isValid && end.isValid else {
            return false
        }
        
        let deltaX = abs(start.x - end.x)
        let deltaY = abs(start.y - end.y)
        
        switch (deltaX, deltaY) {
        case (0...1, 0...1):
            guard end.isValid else {
                return false
            }
            
            // Check if the destination square is empty or occupied by an opponent's piece
            if let piece = board[end.y][end.x], piece.side == player {
                return false
            }
            
            // Simulate the movement
            var tempBoard = board
            tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
            tempBoard[start.y][start.x] = nil
            return !isKingInCheck(board: tempBoard, player: currentPlayer)
            
        // Castling
        case (2, 0):
            print("Castle")
            guard start.isValid && end.isValid else {
                return false
            }
            
            if isKingInCheck(board: piecePositions.value, player: currentPlayer) {
                return false
            }
            let castlingDirection = end.x > start.x ? 1 : -1
            
            var x = start.x + castlingDirection
            if castlingDirection == 1 {
                while x < 7 {
                    // Check for pieces in between
                    if getPiece(at: Position(x: x, y: end.y)) != nil {
                        return false
                    }
                    
                    // Simulate the movement
                    var tempBoard = board
                    tempBoard[end.y][x] = tempBoard[start.y][start.x]
                    tempBoard[start.y][start.x] = nil
                    
                    // if king pass through a position in check
                    if isKingInCheck(board: tempBoard, player: currentPlayer) {
                        return false
                    }
                    
                    x += castlingDirection
                }
            } else {
                while x > 0 {
                    if getPiece(at: Position(x: x, y: end.y)) != nil {
                        return false
                    }
                    
                    // Simulate the movement
                    var tempBoard = board
                    tempBoard[end.y][x] = tempBoard[start.y][start.x]
                    tempBoard[start.y][start.x] = nil
                    
                    // if king pass through a position in check
                    if isKingInCheck(board: tempBoard, player: currentPlayer) {
                        return false
                    }
                    
                    x += castlingDirection
                }
            }
            
            let kingMoved = player == .white ? isWhiteKingMoved : isBlackKingMoved
            let leftRookMoved = player == .white ? isWhiteLeftRookMoved : isBlackLeftRookMoved
            let rightRookMoved = player == .white ? isWhiteRightRookMoved : isBlackRightRookMoved
            
            return !kingMoved && !(leftRookMoved && rightRookMoved)
            
        default:
            return false
        }
    }

    
    // All moves for king
    func allValidKingMoves(board: [[ChessPiece?]], from start: Position) -> [Move]{
        allValidMoves.removeAll()
        let directions: [Position] = [
            Position(x: -1, y: -1),
            Position(x: -1, y: 0),
            Position(x: -1, y: 1),
            Position(x: 0, y: -1),
            Position(x: 0, y: 1),
            Position(x: 1, y: -1),
            Position(x: 1, y: 0),
            Position(x: 1, y: 1)
        ]
        
        for direction in directions {
            let destination = start + direction
            
            // Check if the destination is valid
            guard destination.isValid else {
                continue
            }
            
            // All available moves
            if validKingMove(board: board, from: start, to: destination, player: currentPlayer) {
                allValidMoves.append(Move(from: start, to: destination))
            }
        }
        
        // Check for castling moves
        if validKingMove(board: board, from: start, to: start + Position(x: 2, y: 0), player: currentPlayer) {
            allValidMoves.append(Move(from: start, to: start + Position(x: 2, y: 0)))
        }
        if validKingMove(board: board, from: start, to: start + Position(x: -2, y: 0), player: currentPlayer) {
            allValidMoves.append(Move(from: start, to: start + Position(x: -2, y: 0)))
        }
        return allValidMoves
    }
    
    // Check if the current King is in check (used for validating the movements of pieces)
    func isKingInCheck(board: [[ChessPiece?]], player: Player) -> Bool {
        // Find the opponent
        let opponentSide = player == .white ? Player.black : Player.white
        // Find the position of the current player's king
        var kingPosition: Position = Position(x: -1, y: -1) // Initialize with an invalid position
        for y in 0..<board.count {
            for x in 0..<board[y].count {
                if let piece = board[y][x], piece.side == currentPlayer, piece.pieceType == .king {
                    kingPosition = Position(x: x, y: y)
                    break
                }
            }
        }
        
        // Check for threats from opponent's pawn
        let pawnDirection = opponentSide == .white ? 1 : -1
        let pawnOffsets: [(dx: Int, dy: Int)] = [(1, pawnDirection), (-1, pawnDirection)]
        for offset in pawnOffsets {
            let x = kingPosition.x + offset.dx
            let y = kingPosition.y + offset.dy
            
            if y >= 0 && y < board.count && x >= 0 && x < board[y].count {
                if let piece = board[y][x] {
                    // Validate if there is a opponent pawn
                    if piece.side == opponentSide && piece.pieceType == .pawn {
                        return true
                    }
                }
            }
        }
        
        // Horizontal and vertical threats (Rooks and Queen)
        let directions: [(dx: Int, dy: Int)] = [(1, 0), (-1, 0), (0, 1), (0, -1)]
        for dir in directions {
            var x = kingPosition.x + dir.dx
            var y = kingPosition.y + dir.dy
            
            while y >= 0 && y < board.count && x >= 0 && x < board[y].count {
                if let piece = board[y][x] {
                    // If on the loop find a piece of opponent
                    if piece.side == opponentSide {
                        // if it's a rook or queen
                        if piece.pieceType == .rook || piece.pieceType == .queen {
                            return true
                        } else {
                            break
                        }
                    } else {
                        break
                    }
                }
                x += dir.dx
                y += dir.dy
            }
        }
        
        
        // Diagonal threats (Bishops & Queen & Bishop)
        let diagonalDirections: [(dx: Int, dy: Int)] = [(1, 1), (-1, 1), (1, -1), (-1, -1)]
        for dir in diagonalDirections {
            var x = kingPosition.x + dir.dx
            var y = kingPosition.y + dir.dy
            
            while y >= 0 && y < board.count && x >= 0 && x < board[y].count {
                if let piece = board[y][x] {
                    // If on the loop find a piece of opponent
                    if piece.side == opponentSide {
                        // if it's a bishop or queen
                        if piece.pieceType == .bishop || piece.pieceType == .queen {
                            return true
                        } else {
                            break
                        }
                    } else {
                        break
                    }
                }
                x += dir.dx
                y += dir.dy
            }
        }
        
        
        // Check for threats from opponent's knight
        let knightOffsets: [(dx: Int, dy: Int)] = [
            (1, 2), (-1, 2), (1, -2), (-1, -2),
            (2, 1), (-2, 1), (2, -1), (-2, -1)
        ]
        
        for offset in knightOffsets {
            let x = kingPosition.x + offset.dx
            let y = kingPosition.y + offset.dy
            
            if y >= 0 && y < board.count && x >= 0 && x < board[y].count {
                if let piece = board[y][x] {
                    // Validate if there is a opponent knight
                    if piece.side == opponentSide && piece.pieceType == .knight {
                        return true
                    }
                }
            }
        }
        
        // Check for threats from opponent's king
        let kingOffsets: [(dx: Int, dy: Int)] = [
            (1, 0), (-1, 0), (0, 1), (0, -1),
            (1, 1), (-1, 1), (1, -1), (-1, -1)
        ]
        for offset in kingOffsets {
            let x = kingPosition.x + offset.dx
            let y = kingPosition.y + offset.dy
            
            if y >= 0 && y < board.count && x >= 0 && x < board[y].count {
                if let piece = board[y][x] {
                    // Validate if there is a opponent king
                    if piece.side == opponentSide && piece.pieceType == .king {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    
    // if king in check and no available move -> lose
    func isCheckMate(player: Player) -> Bool {
        if isKingInCheck(board: piecePositions.value, player: player) {
            if allValidKingMoves(board: piecePositions.value, from: player == .white ? whiteKingPosition : blackKingPosition).isEmpty {
                // finish the game, since this function is check on the current user, if true -> opponent wins
                outcome = .checkmate
                winner = player == .white ? .black : .white
                return true
            }
        }
        return false
    }
    
    func isStaleMate(player: Player) -> Bool {
        if isKingInCheck(board: piecePositions.value, player: player) == false {
            // Get all pieces of the current player
            let playerPieces = activePieces.filter { $0.side == player }
            
            // Iterate through all pieces to check if any move is valid
            for piece in playerPieces {
                let pieceIndex = getPiece(piece)
                
                // Get available moves for the piece
                let validMoves: [Move]
                switch piece.pieceType {
                case .pawn:
                    validMoves = allValidPawnMoves(board: piecePositions.value, from: pieceIndex, history: history.value)
                case .knight:
                    validMoves = allValidKnightMoves(board: piecePositions.value, from: pieceIndex)
                case .king:
                    validMoves = allValidKingMoves(board: piecePositions.value, from: pieceIndex)
                case .rook:
                    validMoves = allValidRookMoves(board: piecePositions.value, from: pieceIndex)
                case .bishop:
                    validMoves = allValidBishopMoves(board: piecePositions.value, from: pieceIndex)
                case .queen:
                    let bishopMoves = allValidBishopMoves(board: piecePositions.value, from: pieceIndex)
                    let rookMoves = allValidRookMoves(board: piecePositions.value, from: pieceIndex)
                    validMoves = bishopMoves + rookMoves
                }
                
                // Check if any valid move can be made
                if validMoves.count > 0 {
                    return false
                }
            }
            
            // If no piece has valid moves, the player is in stalemate
            outcome = .stalemate
            return true
        }
        
        return false
    }
    
    // Insufficient material -> draw
    func isInsufficientMaterial(player: Player) -> Bool {
        // Get the active pieces for both players
        let currentPlayerPieces = activePieces.filter { $0.side == player }
        let opponentPieces = activePieces.filter { $0.side != player }
        
        var counter = 0
        // since King cannot be captured, 1 piece left = king
        if currentPlayerPieces.count == 1 && opponentPieces.count == 1 {
            outcome = .insufficientMaterial
            return true
        }
        
        // king + bishop
        if currentPlayerPieces.count == 2 && opponentPieces.count == 2 {
            for piece in currentPlayerPieces {
                if piece.pieceType == .bishop {
                    for oppPiece in opponentPieces {
                        if oppPiece.pieceType == .bishop {
                            outcome = .insufficientMaterial
                            return true
                        }
                    }
                }
            }
        }
        
        // king + knight
        if currentPlayerPieces.count == 2 && opponentPieces.count == 2 {
            for piece in currentPlayerPieces {
                if piece.pieceType == .knight {
                    for oppPiece in opponentPieces {
                        if oppPiece.pieceType == .knight {
                            outcome = .insufficientMaterial
                            return true
                        }
                    }
                }
            }
        }
        
        // 1 King 2 knight vs 1 king
        if currentPlayerPieces.count == 3 {
            for piece in currentPlayerPieces {
                if piece.pieceType == .knight {
                    counter += 1
                }
            }
            if counter == 2 {
                if opponentPieces.count == 1 {
                    outcome = .insufficientMaterial
                    return true
                } else {
                    counter = 0
                }
            }
        }
        
        // 1 King 2 knight vs 1 king
        if opponentPieces.count == 3 {
            for piece in opponentPieces {
                if piece.pieceType == .knight {
                    counter += 1
                }
            }
            if counter == 2 {
                if currentPlayerPieces.count == 1 {
                    outcome = .insufficientMaterial
                    return true
                } else {
                    counter = 0
                }
            }
        }
        
        return false
    }
    
    // check if out of move (for Grand Master rank - 50 moves in total) -> lose
    func isOutOfMove(player: Player) -> Bool {

        if player == .white && availableMoves <= 0 {
            print (availableMoves)
            outcome = .outOfMove
            // User is white by default
            winner = .black
            return true
        }
        return false
    }
    
    // Out of time -> lose
    func isOutOfTime(player: Player) -> Bool {
        if player == .white {
            if whiteTimeLeft <= 0 {
                winner = .black
                outcome = .outOfTime
                return true
            }
        } else {
            if blackTimeLeft <= 0 {
                winner = .white
                outcome = .outOfTime
                return true
            }
        }
        return false
    }
    
    func validRookMove(board: [[ChessPiece?]], from start: Position, to end: Position, player: Player) -> Bool {
        guard start.isValid && end.isValid else {
                return false
        }
        let deltaX = abs(start.x - end.x)
        let deltaY = abs(start.y - end.y)
        
        // Check if the move is along the same column (x) or same row (y)
        if deltaX == 0 || deltaY == 0 {
            let startCoord = deltaX == 0 ? start.y : start.x
            let endCoord = deltaX == 0 ? end.y : end.x
            let movementDirection = startCoord < endCoord ? 1 : -1
            
            // Determine the range of positions (including endCoord)
            let range = stride(from: startCoord + movementDirection, through: endCoord, by: movementDirection)
            // Check for obstacles in between
            for coord in range {
                let pieceAtPosition = deltaX == 0 ? board[coord][start.x] : board[start.y][coord]
                if pieceAtPosition != nil {
                    return false
                }
            }
            
            // Create a temporary board with the updated move
            var tempBoard = board
            tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
            tempBoard[start.y][start.x] = nil
            
            // Check if the move results in the king being in check
            return !isKingInCheck(board: tempBoard, player: currentPlayer)
        }
        
        // If none of the above conditions match, the move is not valid for a rook
        return false
    }
    
    func allValidRookMoves(board: [[ChessPiece?]], from start: Position) -> [Move]{
        allValidMoves.removeAll()
        let directions: [Position] = [
            Position(x: 1, y: 0), // Right
            Position(x: -1, y: 0), // Left
            Position(x: 0, y: 1), // Up
            Position(x: 0, y: -1) // Down
        ]
        
        for direction in directions {
            var currentPosition = start + direction
            
            while currentPosition.isValid {
                if validRookMove(board: board, from: start, to: currentPosition, player: currentPlayer) {
                    allValidMoves.append(Move(from: start, to: currentPosition))
                }
                
                if let piece = board[currentPosition.y][currentPosition.x] {
                    // Simulate the movement
                    var tempBoard = board
                    tempBoard[currentPosition.y][currentPosition.x] = tempBoard[start.y][start.x]
                    tempBoard[start.y][start.x] = nil
                    
                    // Check and add to available moves
                    if piece.side != currentPlayer && !isKingInCheck(board: tempBoard, player: currentPlayer) {
                        allValidMoves.append(Move(from: start, to: currentPosition)) // Capture move
                    }
                    break // Stop moving in this direction if a piece is encountered
                }
                
                currentPosition += direction
            }
        }
        return allValidMoves
    }
    
    // Validate bishop move
    func validBishopMove(board: [[ChessPiece?]], from start: Position, to end: Position) -> Bool {
        guard start.isValid && end.isValid else {
                return false
        }
        let deltaX = abs(start.x - end.x)
        let deltaY = abs(start.y - end.y)
        
        // Check if the move is along a diagonal
        if deltaX == deltaY {
            let dx = (end.x - start.x).signum()
            let dy = (end.y - start.y).signum()
            
            let xIncrement = dx
            let yIncrement = dy
            
            var x = start.x + xIncrement
            var y = start.y + yIncrement
            
            // Check for an obstacle at the destination position
            if board[end.y][end.x] != nil {
                return false
            }
            
            while x != end.x || y != end.y {
                let pieceAtPosition = board[y][x]
                if pieceAtPosition != nil {
                    return false
                }
                
                x += xIncrement
                y += yIncrement
            }
            
            // Create a temporary board with the updated move
            var tempBoard = board
            tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
            tempBoard[start.y][start.x] = nil
            
            // Check if the move results in the king being in check
            return !isKingInCheck(board: tempBoard, player: currentPlayer)
        }
        
        // If none of the above conditions match, the move is not valid for a bishop
        return false
    }
    
    // All bishop moves
    func allValidBishopMoves(board: [[ChessPiece?]], from start: Position) -> [Move]{
        allValidMoves.removeAll()
        let directions: [Position] = [
            Position(x: 1, y: 1), // Diagonal up-right
            Position(x: 1, y: -1), // Diagonal down-right
            Position(x: -1, y: 1), // Diagonal up-left
            Position(x: -1, y: -1) // Diagonal down-left
        ]
        
        for direction in directions {
            var currentPosition = start + direction
            
            while currentPosition.isValid {
                if validBishopMove(board: board, from: start, to: currentPosition) {
                    allValidMoves.append(Move(from: start, to: currentPosition))
                }
                
                if let piece = board[currentPosition.y][currentPosition.x] {
                    // Create a temporary board with the updated move
                    var tempBoard = board
                    tempBoard[currentPosition.y][currentPosition.x] = tempBoard[start.y][start.x]
                    tempBoard[start.y][start.x] = nil
                    if piece.side != currentPlayer && !isKingInCheck(board: tempBoard, player: currentPlayer) {
                        allValidMoves.append(Move(from: start, to: currentPosition)) // Capture move
                    }
                    break // Stop moving in this direction if a piece is encountered
                }
                
                currentPosition += direction
            }
        }
        return allValidMoves
    }
    
    // Start timer
    func startClocks() {
        timer.sink { [self] _ in
            let currentPlayer = self.currentPlayer
            let timeLeftKeyPath = currentPlayer == .white ? \ChessBoard.whiteTimeLeft : \ChessBoard.blackTimeLeft
            
            var newValue = self[keyPath: timeLeftKeyPath] - 1
            newValue = max(newValue, 0) // Ensure the value doesn't go negative
            
            if currentPlayer == .white {
                self.whiteTimeLeft = newValue
            } else {
                self.blackTimeLeft = newValue
            }
        }
        .store(in: &cancellables)
    }
    
    // Copy the current Settings (For the AI evaluation, any changes will not affect the actual board)
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ChessBoard()
        copy.currentPlayer = currentPlayer
        copy.piecePositions.value = piecePositions.value
        copy.whiteKingPosition = whiteKingPosition
        copy.blackKingPosition = blackKingPosition
        copy.isWhiteKingMoved = isWhiteKingMoved
        copy.isWhiteRightRookMoved = isWhiteRightRookMoved
        copy.isWhiteLeftRookMoved = isWhiteLeftRookMoved
        copy.isBlackKingMoved = isBlackKingMoved
        copy.isBlackRightRookMoved = isBlackRightRookMoved
        copy.isBlackLeftRookMoved = isBlackLeftRookMoved
        copy.history.value = history.value
        copy.allValidMoves = allValidMoves
        return copy
    }
    
    func playSound(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer.play()
            } catch {
                print("Fail to play song")
            }
        }
    }
    
    // Convert the move history to Integer to store in CoreData
    func convertHistoryToIntegerOffsets(history: [Move]) -> [[Int]] {
        var integerOffsets: [[Int]] = []
        
        for move in history {
            let startX = move.from.x + 1
            let startY = move.from.y + 1
            let endX = move.to.x + 1
            let endY = move.to.y + 1
            
            let startValue = startX * 10 + startY
            let endValue = endX * 10 + endY
            
            integerOffsets.append([startValue, endValue])
        }
        
        return integerOffsets
    }
    
    func convertMovementsToMoves(movements: [Movement]) -> [Move] {
        var moves: [Move] = []
        
        for movement in movements {
            let startValue = Int(movement.start)
            let endValue = Int(movement.end)
            
            let startX = (startValue - 1) / 10
            let startY = (startValue - 1) % 10
            let endX = (endValue - 1) / 10
            let endY = (endValue - 1) % 10
            
            let from = Position(x: startX, y: startY)
            let to = Position(x: endX, y: endY)
            
            let move = Move(from: from, to: to)
            moves.append(move)
        }
        
        return moves
    }
    
    func convertMovementToMoves(movement: Movement) -> Move {
        
        let startValue = Int(movement.start)
        let endValue = Int(movement.end)
        
        let startX = (startValue - 1) / 10
        let startY = (startValue - 1) % 10
        let endX = (endValue - 1) / 10
        let endY = (endValue - 1) % 10
        
        let from = Position(x: startX, y: startY)
        let to = Position(x: endX, y: endY)
        
        let move = Move(from: from, to: to)
        
        return move
    }

    func convertIntegerOffsetsToMovements(integerOffsetsList: [[Int]]) {
        for integerOffsets in integerOffsetsList {
            guard integerOffsets.count >= 2 else {
                // Each integerOffsets array should have at least 2 values
                continue
            }
            
            let startValue = integerOffsets[0]
            let endValue = integerOffsets[1]
            
            let startX = (startValue - 1) / 10
            let startY = (startValue - 1) % 10
            let endX = (endValue - 1) / 10
            let endY = (endValue - 1) % 10
            
            let newMovement = Movement(context: viewContext)
            newMovement.start = Int16(startX * 10 + startY)
            newMovement.end = Int16(endX * 10 + endY)
            if let currentUsername = currentUser.username {
                if let currentUserr = getUserWithUsername(currentUsername) {
                    currentUserr.savedGame?.addToHistory(newMovement)
                }
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            // Handle the error
            print("Error saving movements to Core Data: \(error)")
        }
    }

    
}

// Result
enum GameResult {
    case checkmate
    case stalemate
    case insufficientMaterial
    case fiftyMoveRule
    case outOfMove
    case outOfTime
    case ongoing
}
