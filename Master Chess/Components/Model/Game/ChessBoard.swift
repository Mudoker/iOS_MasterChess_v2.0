

import Foundation
import Combine
import SwiftUI

class ChessBoard: ObservableObject {
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
    @Published var isCastle = false
    @Published var isEnpassant = false
    @Published var winner: Player = .white
    @Published var allValidMoves: [Move] = []
    @Published var outcome: GameResult = .ongoing
    init() {
        // load from saved
        if currentUser.hasActiveGame {
            whiteTimeLeft = Int(currentUser.savedGameWhiteTimeLeft)
            blackTimeLeft = Int(currentUser.savedGameBlackTimeLeft)
        } else {
            let initialTimeLimit: TimeInterval = currentUser.rating > 500 ? 10 * 60 : 25 * 60
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
                    if pieceCode == "bk0"{
                        blackKingPosition = Position(x: rank, y: file)
                    } else if pieceCode == "wk0" {
                        whiteKingPosition = Position(x:rank, y: file)
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
                        if pieceCode == "bk0"{
                            blackKingPosition = Position(x: rank, y: file)
                        } else if pieceCode == "wk0" {
                            whiteKingPosition = Position(x:rank, y: file)
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
            piecePositions.value = createBoardFromLoad() // Populate piecePositions
            currentPlayer = currentUser.savedGameCurrentPlayer == "w" ? .white : .black
        } else {
            piecePositions.value = createInitialBoard() // Populate piecePositions
            currentUser.savedGameBoardSetup = Constant.initialBoardSetup
            currentPlayer = .white
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
                updatedPiecePositions.value[end.y][end.x] = movingPiece
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
                        isBlackKingMoved = true
                        blackKingPosition = Position(x: end.x, y: end.y)
                        kingPosition = blackKingPosition
                    }
                } else if movingPiece.pieceType == .rook {
                    if movingPiece.side == .white {
                        if start.x == 4 && end.x == 6 {
                            updatedPiecePositions.value[7][7] = nil
                            updatedPiecePositions.value[7][5] = ChessPiece(stringLiteral: "br")
                            isBlackRightRookMoved = true
                        } else if start.x == 4 && end.x == 2 {
                            // Castling to the right for white
                            updatedPiecePositions.value[7][0] = nil
                            updatedPiecePositions.value[7][3] = ChessPiece(stringLiteral: "br")
                            isBlackLeftRookMoved = true
                        }
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
                
                // Switch to the next player's turn
//                currentPlayer = (currentPlayer == .white) ? .black : .white
                currentPlayerIsInCheck = isKingInCheck(board: piecePositions.value)
                history.value.append(Move(from: Position(x: start.x, y: start.y), to: Position(x: end.x, y: end.y)))
                print(history.value)
            } else {
                print("No piece found at the starting position.")
            }
        } else {
            print("Invalid move.")
        }
    }




    func removePiece(at position: Position) {
        let updatedPiecePositions = piecePositions
        updatedPiecePositions.value[position.y][position.x] = nil
        piecePositions = updatedPiecePositions

    }

    func promotePiece(at position: Position, to type: PieceType) {
        let getCurrentSide = currentPlayer == .white ? "w" : "b"
        let pieceName = getCurrentSide + String(type.rawValue.first!)
        let promotedPiece = ChessPiece(stringLiteral: pieceName)
        
        var updatedPiecePositions = piecePositions.value
        removePiece(at: position)
        updatedPiecePositions[position.y][position.x] = promotedPiece
        piecePositions.value = updatedPiecePositions
        
        // Unwrap the boardSetup in SavedGame
        currentUser.savedGameBoardSetup[position.y][position.x] = getPiece(at: position)?.pieceName ?? ""
    }
    
    func validPawnMove(board: [[ChessPiece?]], from start: Position, to end: Position, history: [Move]) -> Bool {
        let deltaX = abs(start.x - end.x)
        let deltaY = end.y - start.y
        var tempBoard = board
            tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
            tempBoard[start.y][start.x] = nil
        // Check for diagonal move
        if deltaX == 1 {
            if !history.isEmpty {
                // Check for en passant
                if deltaY == (currentPlayer == .white ? -1 : 1) {
                    if let lastMove = history.last, lastMove.to.x == end.x {
                        if let piece = board[lastMove.to.y][lastMove.to.x], piece.pieceType == .pawn, piece.side != currentPlayer {
                            print("4")

                            if (currentPlayer == .white && lastMove.from.y == end.y - 1 && lastMove.to.y == end.y + 1) ||
                               (currentPlayer == .black && lastMove.from.y == end.y + 1 && lastMove.to.y == end.y - 1) {
                                return !isKingInCheck(board: tempBoard)
                            }
                        }
                    }
                }
            }
            
            if let destinationPiece = board[end.y][end.x] {
                // Check if the destination piece belongs to the same player
                if destinationPiece.side == currentPlayer {
                    return false
                }
                return deltaY == (currentPlayer == .white ? -1 : 1) && !isKingInCheck(board: tempBoard)
            }
        }
        
        // Check for vertical move
        if deltaX == 0 {
            let middleY = start.y + (currentPlayer == .white ? -1 : 1)
            
            if deltaY == (currentPlayer == .white ? -1 : 1) {
                // Check if the destination is empty
                if board[end.y][end.x] == nil {
                    return !isKingInCheck(board: tempBoard)
                }
            } else if deltaY == (currentPlayer == .white ? -2 : 2) {
                // Check for the initial double move of the pawn
                if board[end.y][end.x] == nil && board[middleY][start.x] == nil {
                    // Make sure it's the initial move for the pawn
                    if (currentPlayer == .white && start.y == 6) || (currentPlayer == .black && start.y == 1) {
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
            
            if validPawnMove(board: board, from: start, to: destination, history: history) {
                allValidMoves.append(Move(from: start, to: destination))
            }
        }
        return allValidMoves
    }

    // L-shape movement for Knight
    func validKnightMove(board: [[ChessPiece?]],from start: Position, to end: Position) -> Bool {
        let deltaX = abs(end.x - start.x)
        let deltaY = abs(end.y - start.y)


        if deltaX == 1 && deltaY == 2 {
            var tempBoard = board
            tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
            tempBoard[start.y][start.x] = nil
            
            if piecePositions.value[end.y][end.x]?.side == currentPlayer {
                return false
            }
            
            if !isKingInCheck(board: tempBoard) {
                return true
            }
        } else if deltaX == 2 && deltaY == 1 {
            var tempBoard = board
            tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
            tempBoard[start.y][start.x] = nil
            
            if piecePositions.value[end.y][end.x]?.side == currentPlayer {
                return false
            }

            if !isKingInCheck(board: tempBoard) {
                return true
            }
        }
        
        return false
    }
    
    // L-shape movement for Knight
    func allValidKnightMoves(board: [[ChessPiece?]], from start: Position) -> [Move] {
        allValidMoves.removeAll()
        print("Current pos: \(start.y)")
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
            if validKnightMove(board: board, from: start, to: move) {
                print("available moves: x = \(move.x) y = \(move.y)")
                allValidMoves.append(Move(from: start, to: move))
            }
        }
        return allValidMoves
    }

    private func validKingMove(board: [[ChessPiece?]], from start: Position, to end: Position) -> Bool {
        let deltaX = abs(start.x - end.x)
        let deltaY = abs(start.y - end.y)
    
        switch (deltaX, deltaY) {
        case (0...1, 0...1):
            // Check if the destination square is empty or occupied by an opponent's piece
            if let piece = board[end.y][end.x], piece.side == currentPlayer {
                return false
            }
            
            var tempBoard = board
            tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
            tempBoard[start.y][start.x] = nil
            
            return !isKingInCheck(board: tempBoard)
            
        case (2, 0):
            if !isKingInCheck(board: piecePositions.value) {
                let castlingDirection: Int
                let kingXAfterCastling: Int
                let emptySquaresX: [Int]
                
                if currentPlayer == .white {
                    castlingDirection = end.x > start.x ? 1 : -1
                    kingXAfterCastling = start.x + (2 * castlingDirection)
                    emptySquaresX = [start.x + castlingDirection, kingXAfterCastling]
                    
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
                    // Create a temporary board with the king's move
                    var tempBoardAfterCastling = board
                    tempBoardAfterCastling[start.y][kingXAfterCastling] = tempBoardAfterCastling[start.y][start.x]
                    tempBoardAfterCastling[start.y][start.x] = nil
                    
                    if isKingInCheck(board: tempBoardAfterCastling) {
                        return false
                    }
                               
                    return true
                }
            }
            return false
        default:
            return false
        }
    }
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
            
            if validKingMove(board: board, from: start, to: destination) {
                allValidMoves.append(Move(from: start, to: destination))
            }
        }
        
        // Check for castling moves
        if validKingMove(board: board, from: start, to: start + Position(x: 2, y: 0)) {
            allValidMoves.append(Move(from: start, to: start + Position(x: 2, y: 0)))
        }
        if validKingMove(board: board, from: start, to: start + Position(x: -2, y: 0)) {
            allValidMoves.append(Move(from: start, to: start + Position(x: -2, y: 0)))
        }
        return allValidMoves
    }

    func isKingInCheck(board: [[ChessPiece?]]) -> Bool {
        // Check if any opponent's piece threatens the king's position
        for row in 0..<Constant.boardSize {
            for col in 0..<Constant.boardSize {
                if let piece = board[row][col], piece.side != currentPlayer {
                    if isValid(board: board, from: Position(x: col, y: row), to: currentPlayer == .white ? whiteKingPosition : blackKingPosition) {
                        print("Trigger")
                        return true
                    }
                }
            }
        }
        return false
    }
    
    // if king in check and no available move
    func isCheckMate() -> Bool {
        if isKingInCheck(board: piecePositions.value) {
            if allValidKingMoves(board: piecePositions.value, from: currentPlayer == .white ? whiteKingPosition : blackKingPosition).isEmpty {
                outcome = .checkmate
                winner = currentPlayer == .white ? .black : .white
                return true
            }
        }
        return false
    }
    
    // if king is not in check but no available move
    func isStaleMate() -> Bool {
        if !isKingInCheck(board: piecePositions.value) {
            if allValidKingMoves(board: piecePositions.value, from: currentPlayer == .white ? whiteKingPosition : blackKingPosition).isEmpty {
                outcome = .stalemate
                return true
            }
        }
        return false
    }
    
    func isInsufficientMaterial() -> Bool {
        // Get the active pieces for both players
        let currentPlayerPieces = activePieces.filter { $0.side == currentPlayer }
        let opponentPieces = activePieces.filter { $0.side != currentPlayer }
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
    
    // check if out of move (for Grand Master rank - 50 moves in total)
    func isOutOfMove() -> Bool {
        if Int(currentUser.savedGameMoveAvailable) <= 0 {
            outcome = .outOfMove
            return true
        }
        return false
    }
    
    func isOutOfTime() -> Bool {
        if currentPlayer == .white {
            if whiteTimeLeft == 0 {
                winner = .black
                outcome = .outOfTime
                return true
            }
        } else {
            if blackTimeLeft == 0 {
                winner = .white
                outcome = .outOfTime
                return true
            }
        }
        return false
    }
    
    func validRookMove(board: [[ChessPiece?]], from start: Position, to end: Position) -> Bool {
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
            
            return true
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
                if validRookMove(board: board, from: start, to: currentPosition) {
                    allValidMoves.append(Move(from: start, to: currentPosition))
                }
                
                if let piece = board[currentPosition.y][currentPosition.x] {
                    if piece.side != currentPlayer {
                        allValidMoves.append(Move(from: start, to: currentPosition)) // Capture move
                    }
                    break // Stop moving in this direction if a piece is encountered
                }
                
                currentPosition += direction
            }
        }
        return allValidMoves
    }


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
                    if piece.side != currentPlayer {
                        allValidMoves.append(Move(from: start, to: currentPosition)) // Capture move
                    }
                    break // Stop moving in this direction if a piece is encountered
                }
                
                currentPosition += direction
            }
        }
        return allValidMoves
    }


    func isValid(board: [[ChessPiece?]], from start: Position, to end: Position) -> Bool {
        let bounds = 0..<Constant.boardSize
        
        guard start != end,
              let piece = board[start.y][start.x],
              bounds.contains(end.x) && bounds.contains(end.y),
              piece.side == currentPlayer else {
            return false
        }

        if let boardPlayer = board[end.y][end.x]?.side, boardPlayer == currentPlayer {
            return false
        }

        switch piece.pieceType {
            case .pawn: return validPawnMove(board: board, from: start, to: end, history: [])
            case .knight: return validKnightMove(board: board,from: start, to: end)
            case .king: return validKingMove(board: board,from: start, to: end)
            case .rook: return validRookMove(board: board, from: start, to: end)
            case .bishop: return validBishopMove(board: board, from: start, to: end)
            case .queen: return validBishopMove(board: board, from: start, to: end) || validRookMove(board: board, from: start, to: end)
        }
    }
    
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
    
    func copy() -> ChessBoard {
        let copiedBoard = ChessBoard()
        
        // Copy properties
        copiedBoard.piecePositions = piecePositions
        copiedBoard.isChecked = isChecked
        copiedBoard.kingPosition = kingPosition
        copiedBoard.whiteKingPosition = whiteKingPosition
        copiedBoard.blackKingPosition = blackKingPosition
        copiedBoard.isWhiteKingMoved = isWhiteKingMoved
        copiedBoard.isWhiteRightRookMoved = isWhiteRightRookMoved
        copiedBoard.isWhiteLeftRookMoved = isWhiteLeftRookMoved
        copiedBoard.isBlackKingMoved = isBlackKingMoved
        copiedBoard.isBlackRightRookMoved = isBlackRightRookMoved
        copiedBoard.isBlackLeftRookMoved = isBlackLeftRookMoved
        
        // Copy time left
        copiedBoard.whiteTimeLeft = whiteTimeLeft
        copiedBoard.blackTimeLeft = blackTimeLeft
        
        return copiedBoard
    }
}

enum GameResult {
    case checkmate
    case stalemate
    case insufficientMaterial
    case fiftyMoveRule
    case outOfMove
    case outOfTime
    case ongoing
}
