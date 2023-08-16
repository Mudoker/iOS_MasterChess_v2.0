

import Foundation
import Combine
import SwiftUI

struct ChessBoard {
    @Binding var currentUser: Users

    var piecePositions: CurrentValueSubject<[[ChessPiece?]], Never> = CurrentValueSubject([])

    let currentPlayer: CurrentValueSubject<Player, Never> = CurrentValueSubject(.white)
    let isChecked: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)

    let whiteTimeLeft: CurrentValueSubject<TimeInterval, Never>
    let blackTimeLeft: CurrentValueSubject<TimeInterval, Never>
    private var cancellables = Set<AnyCancellable>()
    private let gameSetting: Setting
    private var timer = Timer.publish(every: 1.0, on: .main, in: .common)
    private var history: [Move] = []
    private var kingPosition: Position = Position(x: 0, y: 0)
    private var isWhiteKingMoved = false
    private var isWhiteRookMoved = false
    private var isBlackKingMoved = false
    private var isBlackRookMoved = false
    init(player: Binding<Player>, user: Binding<Users>) {
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
            // Timer based on user ranking (Newbie: 60 mins, Master and GrandMaster: 15 mins)
            let initialTimeLimit: TimeInterval = user.wrappedValue.rating > 500 ? 15 * 60 : 60 * 60
            whiteTimeLeft = CurrentValueSubject(initialTimeLimit)
            blackTimeLeft = CurrentValueSubject(initialTimeLimit)
        }
        
    }
    
    // Start new game
    mutating func createInitialBoard() -> [[ChessPiece?]] {
        var piecePositions = Array(repeating: Array<ChessPiece?>(repeating: nil, count: Constant.boardSize), count: Constant.boardSize)
        for (rank, files) in Constant.initialBoardSetup.enumerated() {
            for (file, pieceCode) in files.enumerated() {
                if let pieceCode = pieceCode {
                    let piece = ChessPiece(stringLiteral: pieceCode)
                    if pieceCode == "bk0" || pieceCode == "wk0" {
                        kingPosition = Position(x: rank, y: file)
                    }
                    piecePositions[rank][file] = piece
                }
            }
        }

        return piecePositions
    }
    
    // Load game from saved
    mutating func createBoardFromLoad() -> [[ChessPiece?]] {
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
    
    func getPiece(at position: Position) -> ChessPiece? {
        guard (0 ..< Constant.boardSize).contains(position.y), (0 ..< Constant.boardSize).contains(position.x) else {
            return nil
        }
        return piecePositions.value[position.y][position.x]
    }
    
    mutating func movePiece(from: Position, to: Position) {
        var updatedPiecePositions = piecePositions.value  // Make a copy of the current piecePositions
        
        // Move the piece
        updatedPiecePositions[to.y][to.x] = getPiece(at: from)
        updatedPiecePositions[from.y][from.x] = nil
        
        // Update the piecePositions with the new value
        piecePositions.send(updatedPiecePositions)
    }
    
    mutating func removePiece(at position: Position) {
        var updatedPiecePositions = piecePositions.value
        updatedPiecePositions[position.y][position.x] = nil
        piecePositions.send(updatedPiecePositions)
    }

    mutating func promotePiece(at position: Position, to type: PieceType) {
        var updatedPiecePositions = piecePositions.value
        var piece = updatedPiecePositions[position.y][position.x]
        piece?.pieceType = type
        updatedPiecePositions[position.y][position.x] = piece
        piecePositions.send(updatedPiecePositions)
    }
    
    private func validPawnMove(board: [[ChessPiece?]], from start: Position, to end: Position, player: Player, history: [Move]) -> Bool {
        let deltaX = abs(start.x - end.x)
        let deltaY = end.y - start.y
        var tempBoard = board
            tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
            tempBoard[start.y][start.x] = nil
        // Check for diagonal move
        if deltaX == 1 {
            // Check if there is a piece at the destination and if it belongs to the same player
            if let destinationPiece = board[end.y][end.x], destinationPiece.side == player {
                return false
            }
            // Pawn can only move one step forward, with direction based on the player
            return deltaY == (player == .white ? -1 : 1) && !isKingInCheck(player: currentPlayer.value, board: tempBoard, history: history)
        }
        
        // Check for vertical move
        if deltaX == 0 {
            let middleY = start.y + (player == .white ? 1 : -1)
            
            if deltaY == (player == .white ? 1 : -1) {
                // Check if the destination is empty
                if board[end.y][end.x] == nil {
                    return !isKingInCheck(player: currentPlayer.value, board: tempBoard, history: history)
                }
            } else if deltaY == (player == .white ? 2 : -2) {
                // Check for the initial double move of the pawn
                if board[end.y][end.x] == nil && board[start.y][middleY] == nil {
                    // Make sure it's the initial move for the pawn
                    if (player == .white && start.y == 1) || (player == .black && start.y == 6) {
                        return !isKingInCheck(player: currentPlayer.value, board: tempBoard, history: history)
                    }
                }
            }
        }
        // Check for en passant
        if deltaX == 1 && deltaY == (player == .white ? -1 : 1) {
            if let lastMove = history.last, lastMove.to.x == end.x {
                if let piece = board[lastMove.to.y][lastMove.to.x], piece.pieceType == .pawn, piece.side != player {
                    if (player == .white && lastMove.from.y == end.y - 1 && lastMove.to.y == end.y + 1) ||
                       (player == .black && lastMove.from.y == end.y + 1 && lastMove.to.y == end.y - 1) {
                        return !isKingInCheck(player: currentPlayer.value, board: tempBoard, history: history)
                    }
                }
            }
        }
        return false
    }
    
    // L-shape movement for Knight
    private func validKnightMove(board: [[ChessPiece?]],from start: Position, to end: Position) -> Bool {
        let deltaX = start.x - end.x
        let deltaY = start.y - end.y
        
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
                
                if !isKingInCheck(player: currentPlayer.value, board: tempBoard, history: history) {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func validKingMove(board: [[ChessPiece?]], from start: Position, to end: Position) -> Bool {
        let deltaX = abs(start.x - end.x)
        let deltaY = abs(start.y - end.y)
        
        switch (deltaX, deltaY) {
        case (0...1, 0...1):
            var tempBoard = board
            tempBoard[end.y][end.x] = tempBoard[start.y][start.x]
            tempBoard[start.y][start.x] = nil
            
            return !isKingInCheck(player: currentPlayer.value, board: tempBoard, history: history)
        case (2, 0):
            if !isKingInCheck(player: currentPlayer.value, board: piecePositions.value, history: history) {
                let castlingDirection: Int
                let rookInitialX: Int
                let kingXAfterCastling: Int
                let emptySquaresX: [Int]

                if player == .white {
                    castlingDirection = end.x > start.x ? 1 : -1
                    rookInitialX = castlingDirection == 1 ? 7 : 0
                    kingXAfterCastling = start.x + (2 * castlingDirection)
                    emptySquaresX = [start.x + castlingDirection, kingXAfterCastling]
                } else { // player == .black
                    castlingDirection = end.x > start.x ? 1 : -1
                    rookInitialX = castlingDirection == 1 ? 7 : 0
                    kingXAfterCastling = start.x + (2 * castlingDirection)
                    emptySquaresX = [start.x + castlingDirection, kingXAfterCastling]
                }

                let rookPosition = Position(x: rookInitialX, y: start.y)

                // Check if the squares between the king and the rook are empty
                if emptySquaresX.allSatisfy({ board[start.y][$0] == nil }) {
                    // Create a temporary board with the king's move
                    var tempBoardAfterCastling = board
                    tempBoardAfterCastling[rookPosition.y][rookPosition.x] = tempBoardAfterCastling[start.y][start.x]
                    tempBoardAfterCastling[start.y][start.x] = nil

                    // Check if the king is in check after castling
                    if isKingInCheck(player: currentPlayer.value, board: tempBoardAfterCastling, history: history) {
                        return false
                    }

                    // Everything checks out, so allow castling
                    return true
                }
            }
            return false
        default:
            return false
        }
    }
    
    func isKingInCheck(player: Player, board: [[ChessPiece?]], history: [Move]) -> Bool {
        // Check if any opponent's piece threatens the king's position
        for row in 0..<Constant.boardSize {
            for col in 0..<Constant.boardSize {
                if let piece = board[row][col], piece.side != player {
                    let move = Move(from: Position(x: col, y: row), to: kingPosition)
                    if isValid(board: board, from: Position(x: col, y: row), to: kingPosition, player: piece.side) {
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
            
            if isKingInCheck(player: currentPlayer.value, board: tempBoard, history: history) {
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
        
        return !isKingInCheck(player: currentPlayer.value, board: tempBoard, history: history)
    }

    func isValid(board: [[ChessPiece?]], from start: Position, to end: Position, player: Player) -> Bool {
        let bounds = 0..<Constant.boardSize
        
        guard start != end,
              let piece = board[start.y][start.x],
              bounds.contains(end.x) && bounds.contains(end.y),
              piece.side == player else {
            return false
        }

        if let boardPlayer = board[end.y][end.x]?.side, boardPlayer == player {
            return false
        }

        switch piece.pieceType {
        case .pawn: return validPawnMove(board: board, from: start, to: end, player: player, history: [])
        case .knight: return validKnightMove(board: board,from: start, to: end)
        case .king: return validKingMove(board: board,from: start, to: end)
        case .rook: return validRookMove(board: board, from: start, to: end)
        case .bishop: return validBishopMove(board: board, from: start, to: end)
        case .queen: return validBishopMove(board: board, from: start, to: end) || validRookMove(board: board, from: start, to: end)
        }
    }
}
