

import Foundation
import Combine
import SwiftUI

class ChessBoard {
    @Binding var currentUser: Users

    var piecePositions: CurrentValueSubject<[[ChessPiece?]], Never> = CurrentValueSubject([])

    let currentPlayer: CurrentValueSubject<Player, Never> = CurrentValueSubject(.white)
    let isChecked: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    var activePieces: [ChessPiece] { piecePositions.value.flatMap { $0 }.compactMap { $0 } }

    let whiteTimeLeft: CurrentValueSubject<TimeInterval, Never>
    let blackTimeLeft: CurrentValueSubject<TimeInterval, Never>
     var cancellables = Set<AnyCancellable>()
     let gameSetting: Setting
     var timer = Timer.publish(every: 1.0, on: .main, in: .common)
     var history: [Move] = []
     var kingPosition: Position = Position(x: 0, y: 0)
     var isWhiteKingMoved = false
     var isWhiteRightRookMoved = false
     var isWhiteLeftRookMoved = false
     var isBlackKingMoved = false
     var isBlackRightRookMoved = false
     var isBlackLeftRookMoved = false
     var allValidMoves: [Move] = []
    init(user: Binding<Users>) {
        _currentUser = user
        gameSetting = user.wrappedValue.userSettings ?? Setting()

        // load from saved
        if user.wrappedValue.hasActiveGame, let savedGame = user.wrappedValue.savedGame {
            gameSetting.autoPromotionEnabled = savedGame.autoPromotionEnabled
            gameSetting.difficulty = savedGame.difficulty
            gameSetting.language = savedGame.language
            whiteTimeLeft = CurrentValueSubject(savedGame.whiteTimeLeft)
            blackTimeLeft = CurrentValueSubject(savedGame.blackTimeLeft)
        } else {
            // create new from user settings
            if let userSettings = user.wrappedValue.userSettings {
                gameSetting.autoPromotionEnabled = userSettings.autoPromotionEnabled
                gameSetting.difficulty = userSettings.difficulty
                gameSetting.language = userSettings.language
            }
            // Timer based on user ranking (Newbie: 25 mins, Master and GrandMaster: 10 mins)
            let initialTimeLimit: TimeInterval = user.wrappedValue.rating > 500 ? 10 * 60 : 25 * 60
            whiteTimeLeft = CurrentValueSubject(initialTimeLimit)
            blackTimeLeft = CurrentValueSubject(initialTimeLimit)
        }
        
    }
    
    // Start new game
    func createInitialBoard() -> [[ChessPiece?]] {
        var piecePositions = Array(repeating: Array<ChessPiece?>(repeating: nil, count: Constant.boardSize), count: Constant.boardSize)
        for (rank, files) in Constant.initialBoardSetup.enumerated() {
            for (file, pieceCode) in files.enumerated() {
                if pieceCode != "" {
                    let piece = ChessPiece(stringLiteral: pieceCode)
                    if pieceCode == "bk" || pieceCode == "wk" {
                        kingPosition = Position(x: rank, y: file)
                    }
                    piecePositions[rank][file] = piece
                }
            }
        }

        return piecePositions
    }
    
    // Load game from saved
    func createBoardFromLoad() -> [[ChessPiece?]] {
        var piecePositions = Array(repeating: Array<ChessPiece?>(repeating: nil, count: Constant.boardSize), count: Constant.boardSize)

        if let unwrappedBoardSetup = currentUser.savedGame?.unwrappedBoardSetup as? [[String?]] {
            for (rank, files) in unwrappedBoardSetup.enumerated() {
                for (file, pieceCode) in files.enumerated() {
                    if let pieceCode = pieceCode as String? {
                        let piece = ChessPiece(stringLiteral: pieceCode)
                        if pieceCode == "bk0" || pieceCode == "wk0" {
                            kingPosition = Position(x: rank, y: file)
                        }
                        piecePositions[rank][file] = piece
                    }
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
        piecePositions.value = createInitialBoard()
        currentPlayer.value = .white

        // Start the clocks to begin tracking time
        startClocks()
    }

    
    func getPiece(at position: Position) -> ChessPiece? {
        guard (0 ..< Constant.boardSize).contains(position.y), (0 ..< Constant.boardSize).contains(position.x) else {
            return nil
        }
        return piecePositions.value[position.y][position.x]
    }
    func getPiece(_ piece: ChessPiece) -> Position {
        if let index = piecePositions.value.flatMap({ $0 }).firstIndex (where: { $0?.id == piece.id }) {
            return Position(x: index / 8, y: index % 8)
        }
        fatalError()
    }
    func movePiece(from start: Position, to end: Position) {
        let validMove = allValidMoves.first { $0.from == start && $0.to == end }
        
        if let validMove = validMove {
            var updatedPiecePositions = piecePositions.value
            
            // Move the piece
            let movingPiece = updatedPiecePositions[start.y][start.x]
            updatedPiecePositions[end.y][end.x] = movingPiece
            updatedPiecePositions[start.y][start.x] = nil
            
            // Update the piecePositions with the new value
            piecePositions.send(updatedPiecePositions)
            
            // Update the boardSetup in SavedGame
            if var boardSetup = currentUser.savedGame?.boardSetup {
                if let movingPieceID = movingPiece?.id {
                    boardSetup[end.y][end.x] = movingPieceID
                }
                boardSetup[start.y][start.x] = ""
                currentUser.savedGame?.boardSetup = boardSetup
            }
            
            // Switch to the next player's turn
            currentPlayer.send(currentPlayer.value == .white ? .black : .white)
        }
    }


    func removePiece(at position: Position) {
        var updatedPiecePositions = piecePositions.value
        updatedPiecePositions[position.y][position.x] = nil
        piecePositions.send(updatedPiecePositions)
        
        // Update the boardSetup in SavedGame
        // Unwrap the boardSetup in SavedGame
        if var boardSetup = currentUser.savedGame?.boardSetup {
            boardSetup[position.y][position.x] = ""
            currentUser.savedGame?.boardSetup = boardSetup
        }
    }

    func promotePiece(at position: Position, to type: PieceType) {
        let getCurrentSide = currentPlayer.value == .white ? "w" : "b"
        let pieceName = getCurrentSide + String(type.rawValue.first!)
        let promotedPiece = ChessPiece(stringLiteral: pieceName)
        
        var updatedPiecePositions = piecePositions.value
        removePiece(at: position)
        updatedPiecePositions[position.y][position.x] = promotedPiece
        piecePositions.send(updatedPiecePositions)
        
        // Unwrap the boardSetup in SavedGame
        if var boardSetup = currentUser.savedGame?.boardSetup {
            boardSetup[position.y][position.x] = getPiece(at: position)?.pieceName ?? ""
            currentUser.savedGame?.boardSetup = boardSetup
        }
    }
    
    private func validPawnMove(board: [[ChessPiece?]], from start: Position, to end: Position, history: [Move]) -> Bool {
        let deltaX = abs(start.x - end.x)
        let deltaY = end.y - start.y
        var tempBoard = board
            tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
            tempBoard[start.y][start.x] = nil
        // Check for diagonal move
        if deltaX == 1 {
            // Check if there is a piece at the destination and if it belongs to the same player
            if let destinationPiece = board[end.y][end.x], destinationPiece.side == currentPlayer.value {
                return false
            }

            // Pawn can only move one step forward, with direction based on the player
            return deltaY == (currentPlayer.value == .white ? -1 : 1) && !isKingInCheck(board: tempBoard)
        }
        
        // Check for vertical move
        if deltaX == 0 {
            let middleY = start.y + (currentPlayer.value == .white ? 1 : -1)
            
            if deltaY == (currentPlayer.value == .white ? 1 : -1) {
                // Check if the destination is empty
                if board[end.y][end.x] == nil {
                    return !isKingInCheck(board: tempBoard)
                }
            } else if deltaY == (currentPlayer.value == .white ? 2 : -2) {
                // Check for the initial double move of the pawn
                if board[end.y][end.x] == nil && board[start.y][middleY] == nil {
                    // Make sure it's the initial move for the pawn
                    if (currentPlayer.value == .white && start.y == 1) || (currentPlayer.value == .black && start.y == 6) {
                        return !isKingInCheck(board: tempBoard)
                    }
                }
            }
        }
        // Check for en passant
        if deltaX == 1 && deltaY == (currentPlayer.value == .white ? -1 : 1) {
            if let lastMove = history.last, lastMove.to.x == end.x {
                if let piece = board[lastMove.to.y][lastMove.to.x], piece.pieceType == .pawn, piece.side != currentPlayer.value {
                    if (currentPlayer.value == .white && lastMove.from.y == end.y - 1 && lastMove.to.y == end.y + 1) ||
                       (currentPlayer.value == .black && lastMove.from.y == end.y + 1 && lastMove.to.y == end.y - 1) {
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
            Position(x: 0, y: currentPlayer.value == .white ? -1 : 1), // Forward move
            Position(x: 1, y: currentPlayer.value == .white ? -1 : 1), // Diagonal right capture
            Position(x: -1, y: currentPlayer.value == .white ? -1 : 1) // Diagonal left capture
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
    private func validKnightMove(board: [[ChessPiece?]],from start: Position, to end: Position) -> Bool {
        
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
            if move == end {
                var tempBoard = board
                tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
                tempBoard[start.y][start.x] = nil
                
                if piecePositions.value[end.y][end.x]?.side == currentPlayer.value {
                    return false
                }

                if !isKingInCheck(board: tempBoard) {
                    return true
                }
            }
        }
        
        return false
    }
    
    // L-shape movement for Knight
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
            let destination = start + move
            
            // Check if the destination is valid
            guard destination.isValid else {
                continue
            }
            
            if validKnightMove(board: board, from: start, to: destination) {
                allValidMoves.append(Move(from: start, to: destination))
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
            if let piece = board[end.y][end.x], piece.side == currentPlayer.value {
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
                
                if currentPlayer.value == .white {
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
                if let piece = board[row][col], piece.side != currentPlayer.value {
                    if isValid(board: board, from: Position(x: col, y: row), to: kingPosition) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private func validRookMove(board: [[ChessPiece?]], from start: Position, to end: Position) -> Bool {
        let deltaX = abs(start.x - end.x)
        let deltaY = abs(start.y - end.y)
        
        // Check if the move is along the same column (x) or same row (y)
        if deltaX == 0 || deltaY == 0 {
            var tempBoard = board
            tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
            tempBoard[start.y][start.x] = nil
            
            if isKingInCheck(board: tempBoard) {
                return false
            }
            
            // Check for one-square move or no obstacles
            if deltaX <= 1 && deltaY <= 1 {
                return true
            }
            
            let range = (deltaX == 0 ? Swift.min(start.y, end.y) : Swift.min(start.x, end.x)) + 1
                ..< (deltaX == 0 ? Swift.max(start.y, end.y) : Swift.max(start.x, end.x))
            
            // Check if there are obstacles in between
            return !range.contains { deltaX == 0 ? board[start.x][$0] != nil : board[$0][start.y] != nil }
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
                    if piece.side != currentPlayer.value {
                        allValidMoves.append(Move(from: start, to: currentPosition)) // Capture move
                    }
                    break // Stop moving in this direction if a piece is encountered
                }
                
                currentPosition += direction
            }
        }
        return allValidMoves
    }


    private func validBishopMove(board: [[ChessPiece?]], from start: Position, to end: Position) -> Bool {
        let deltaX = abs(start.x - end.x)
        let deltaY = abs(start.y - end.y)
        
        guard deltaX == deltaY else {
            return false
        }
        
        let dx = (end.x - start.x).signum()
        let dy = (end.y - start.y).signum()
        
        var x = start.x + dx
        var y = start.y + dy
        
        // Check for threats along the diagonal path
        while x != end.x {
            if board[x][y] != nil {
                return false
            }
            
            x += dx
            y += dy
        }
        
        var tempBoard = board
        tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
        tempBoard[start.y][start.x] = nil
        
        return !isKingInCheck(board: tempBoard)
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
                    if piece.side != currentPlayer.value {
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
              piece.side == currentPlayer.value else {
            return false
        }

        if let boardPlayer = board[end.y][end.x]?.side, boardPlayer == currentPlayer.value {
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
    
//    func validMovementFor(
    func startClocks() {
        timer.sink { [self] _ in
            let currentPlayer = self.currentPlayer.value
            let timeLeftKeyPath = currentPlayer == .white ? \ChessBoard.whiteTimeLeft : \ChessBoard.blackTimeLeft
            
            var newValue = self[keyPath: timeLeftKeyPath].value - 1
            newValue = max(newValue, 0) // Ensure the value doesn't go negative
            
            if currentPlayer == .white {
                self.whiteTimeLeft.send(newValue)
            } else {
                self.blackTimeLeft.send(newValue)
            }
        }
        .store(in: &cancellables)
    }
    
    func copy() -> ChessBoard {
        let copiedBoard = ChessBoard(user: $currentUser)
        
        // Copy properties
        copiedBoard.piecePositions.value = piecePositions.value
        copiedBoard.isChecked.value = isChecked.value
        copiedBoard.kingPosition = kingPosition
        copiedBoard.isWhiteKingMoved = isWhiteKingMoved
        copiedBoard.isWhiteRightRookMoved = isWhiteRightRookMoved
        copiedBoard.isWhiteLeftRookMoved = isWhiteLeftRookMoved
        copiedBoard.isBlackKingMoved = isBlackKingMoved
        copiedBoard.isBlackRightRookMoved = isBlackRightRookMoved
        copiedBoard.isBlackLeftRookMoved = isBlackLeftRookMoved
        // Copy other properties as needed
        
        // Copy time left
        copiedBoard.whiteTimeLeft.value = whiteTimeLeft.value
        copiedBoard.blackTimeLeft.value = blackTimeLeft.value
        
        return copiedBoard
    }
}
