

import Foundation
import Combine
import SwiftUI

class ChessBoard: ObservableObject, NSCopying {
    var currentUser = CurrentUser.shared
    var piecePositions: CurrentValueSubject<[[ChessPiece?]], Never> = CurrentValueSubject([])
    
    @Published var currentPlayer = Player.white
    @Published var isChecked = false
    var activePieces: [ChessPiece] {
        piecePositions.value.flatMap { $0 }.compactMap { $0 }
    }
    @Published var currentPlayerIsInCheck = false
    
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
    init() {
        // load from saved
        if currentUser.hasActiveGame {
            whiteTimeLeft = Int(currentUser.savedGameWhiteTimeLeft)
            blackTimeLeft = Int(currentUser.savedGameBlackTimeLeft)
        } else {
            let initialTimeLimit: TimeInterval = currentUser.rating > 500 ? 10 * 60 : 20 * 60
            whiteTimeLeft = Int(initialTimeLimit)
            blackTimeLeft = Int(initialTimeLimit)
        }
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
            
            // find current player
            currentPlayer = currentUser.savedGameCurrentPlayer == "w" ? .white : .black
            
            // moves left for Grandmaster
            availableMoves = Int(currentUser.savedGameMoveAvailable)
            
        } else {
            // Create new board
            piecePositions.value = createInitialBoard() // Populate piecePositions
            
            // save current board to currentUser
            currentUser.savedGameBoardSetup = Constant.initialBoardSetup
            
            // White starts first
            currentPlayer = .white
            
            // Limit 30 moves for grandmaster and 50 for master
            availableMoves = currentUser.rating >= 2400 ? 30 : currentUser.rating >= 2000 ? 50 : 1000000
        }
        
        // Start the clocks to begin tracking time
        startClocks()
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
                updatedPiecePositions.value[end.y][end.x] = movingPiece
                
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
                
                // For every move of user then minus one (Not applicable for AI)
                availableMoves = currentPlayer == .white ? availableMoves - 1 : availableMoves
                
                // Switch to the next player's turn
                currentPlayer = (currentPlayer == .white) ? .black : .white
                
                // Store move history
                history.value.append(Move(from: Position(x: start.x, y: start.y), to: Position(x: end.x, y: end.y)))
                
            } else {
                print("No piece found at the starting position.")
            }
        } else {
            print("Invalid move.")
        }
    }
    
    func movePieceAI(from start: Position, to end: Position) {
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
            updatedPiecePositions.value[end.y][end.x] = movingPiece
            
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
            
        } else {
            print("No piece found at the starting position.")
        }
    }
    // Remove a piece at specific location
    func removePiece(at position: Position) {
        let updatedPiecePositions = piecePositions
        updatedPiecePositions.value[position.y][position.x] = nil
        piecePositions = updatedPiecePositions
        
    }
    
    // Promote a pawn when reach the end of board
    func promotePiece(at position: Position, to type: PieceType) {
        let getCurrentSide = currentPlayer == .white ? "b" : "w"
        let pieceName = getCurrentSide + String(type.rawValue.first!)
        let promotedPiece = ChessPiece(stringLiteral: pieceName)
        
        var updatedPiecePositions = piecePositions.value
        removePiece(at: position)
        updatedPiecePositions[position.y][position.x] = promotedPiece
        piecePositions.value = updatedPiecePositions
        
        // Unwrap the boardSetup in SavedGame
        currentUser.savedGameBoardSetup[position.y][position.x] = getPiece(at: position)?.pieceName ?? ""
    }
    
    // Check if a move from A to B of pawn is valid
    func validPawnMove(board: [[ChessPiece?]], from start: Position, to end: Position, history: [Move], player: Player) -> Bool {
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
                    // En passant
                    if let lastMove = history.last, lastMove.to.x == end.x {
                        if let piece = board[lastMove.to.y][lastMove.to.x], piece.pieceType == .pawn, piece.side != player {
                            if (player == .white && lastMove.from.y == end.y - 1 && lastMove.to.y == end.y + 1) ||
                                (player == .black && lastMove.from.y == end.y + 1 && lastMove.to.y == end.y - 1) {
                                return !isKingInCheck(board: tempBoard)
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
                
                return deltaY == (player == .white ? -1 : 1) && !isKingInCheck(board: tempBoard)
            }
        }
        
        // Check for vertical move
        if deltaX == 0 {
            let middleY = start.y + (player == .white ? -1 : 1)
            
            if deltaY == (player == .white ? -1 : 1) {
                // Check if the destination is empty
                if board[end.y][end.x] == nil {
                    return !isKingInCheck(board: tempBoard)
                }
            } else if deltaY == (player == .white ? -2 : 2) {
                // Check for the initial double move of the pawn
                if board[end.y][end.x] == nil && board[middleY][start.x] == nil {
                    // Make sure it's the initial move for the pawn
                    if (player == .white && start.y == 6) || (player == .black && start.y == 1) {
                        return !isKingInCheck(board: tempBoard)
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
            if !isKingInCheck(board: tempBoard) {
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
            
            if !isKingInCheck(board: tempBoard) {
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
        let deltaX = abs(start.x - end.x)
        let deltaY = abs(start.y - end.y)
        
        switch (deltaX, deltaY) {
        case (0...1, 0...1):
            // Check if the destination square is empty or occupied by an opponent's piece
            if let piece = board[end.y][end.x], piece.side == player {
                return false
            }
            
            // Simulate the movement
            var tempBoard = board
            tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
            tempBoard[start.y][start.x] = nil
            return !isKingInCheck(board: tempBoard)
            
        // Castling
        case (2, 0):
            // Do not allow castling if the king is in check
            if !isKingInCheck(board: piecePositions.value) {
                let castlingDirection: Int
                let kingXAfterCastling: Int
                let emptySquaresX: [Int]
                
                if player == .white {
                    castlingDirection = end.x > start.x ? 1 : -1
                    kingXAfterCastling = start.x + (2 * castlingDirection)
                    emptySquaresX = [start.x + castlingDirection, kingXAfterCastling]
                    
                    // Only allow castling when the king or corresponding rook has not moved
                    if castlingDirection == 1 {
                        if isWhiteKingMoved || isWhiteRightRookMoved {
                            return false
                        }
                    } else {
                        if isWhiteKingMoved || isWhiteLeftRookMoved {
                            return false
                        }
                    }
                } else { // currentPlayer.value == .black
                    castlingDirection = end.x > start.x ? 1 : -1
                    kingXAfterCastling = start.x + (2 * castlingDirection)
                    emptySquaresX = [start.x + castlingDirection, kingXAfterCastling]
                    
                    if castlingDirection == 1 {
                        if isBlackKingMoved || isBlackRightRookMoved {
                            return false
                        }
                    } else {
                        if isBlackKingMoved || isBlackLeftRookMoved {
                            return false
                        }
                    }
                }
                
                // Check if the squares between the king and the rook are empty
                if emptySquaresX.allSatisfy({ board[start.y][$0] == nil }) {
                    // Simulate the movement
                    var tempBoardAfterCastling = board
                    tempBoardAfterCastling[start.y][kingXAfterCastling] = tempBoardAfterCastling[start.y][start.x]
                    tempBoardAfterCastling[start.y][start.x] = nil
                    return !isKingInCheck(board: tempBoardAfterCastling)
                }
            }
            return false
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
    func isKingInCheck(board: [[ChessPiece?]]) -> Bool {
        // Find the opponent
        let opponentSide = currentPlayer == .white ? Player.black : Player.white
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
        
        // Diagonal threats (Bishops & Queen)
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
        if isKingInCheck(board: piecePositions.value) {
            if allValidKingMoves(board: piecePositions.value, from: player == .white ? whiteKingPosition : blackKingPosition).isEmpty {
                // finish the game, since this function is check on the current user, if true -> opponent wins
                outcome = .checkmate
                winner = player == .white ? .black : .white
                return true
            }
        }
        return false
    }
    
    // if king is not in check but no available move -> draw
    func isStaleMate(player: Player) -> Bool {
        if isKingInCheck(board: piecePositions.value) == false {
            if allValidKingMoves(board: piecePositions.value, from: player == .white ? whiteKingPosition : blackKingPosition).isEmpty {
                // If stalemate, the game is a draw
                outcome = .stalemate
                return true
            }
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
            print("Out Move")

            outcome = .outOfMove
            // User is white by default
            winner = .black
            return true
        }
        return false
    }
    
    // Out of time -> lose
    func isOutOfTime(player: Player) -> Bool {
        if currentPlayer == .white {
            print("Out Time")

            if whiteTimeLeft <= 0 {
                winner = .black
                outcome = .outOfTime
                return true
            }
        } else {
            if blackTimeLeft <= 0 {
                print("Out Time")

                winner = .white
                outcome = .outOfTime
                return true
            }
        }
        return false
    }
    
    func validRookMove(board: [[ChessPiece?]], from start: Position, to end: Position, player: Player) -> Bool {
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
            return !isKingInCheck(board: tempBoard)
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
                    if piece.side != currentPlayer && !isKingInCheck(board: tempBoard) {
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
            return !isKingInCheck(board: tempBoard)
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
                    if piece.side != currentPlayer && !isKingInCheck(board: tempBoard) {
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
