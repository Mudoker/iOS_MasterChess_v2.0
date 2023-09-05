/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 25/08/2023
 Last modified: 30/08/2023
 Acknowledgement:
 ivangodfather. “Chess” Github.com. https://dribbble.com/shots/17726071/attachments/12888457?mode=media (accessed Aug 25, 2023).
 */

import Foundation
import GameplayKit

// Custom game engine conforming to GKGameModel
class AIEngine: NSObject, GKGameModel {
    let chessBoard: ChessBoard
    
    // Return the list of players (white and black)
    var players: [GKGameModelPlayer]? {
        return AIPlayer.allPlayers
    }
    
    // currently active player
    var activePlayer: GKGameModelPlayer? {
        return chessBoard.currentPlayer == .white ? AIPlayer.allPlayers[0] : AIPlayer.allPlayers[1]
    }
    
    // Create a copy of the game state
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = AIEngine(chessBoard: chessBoard.copy() as! ChessBoard)
        copy.setGameModel(self)
        return copy
    }
    
    // Initialize the game engine with a chessboard
    init(chessBoard: ChessBoard) {
        self.chessBoard = chessBoard
    }
    
    // Set the game state from another game model
    func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? AIEngine {
            chessBoard.piecePositions.value = board.chessBoard.piecePositions.value
            chessBoard.currentPlayer = board.chessBoard.currentPlayer
            chessBoard.availableMoves = board.chessBoard.availableMoves
        }
    }

    // Generate possible game model updates for the current player
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        guard let aiPlayer = player as? AIPlayer else {
            return nil
        }
        if shouldContinueGame(for: aiPlayer) {
            return generateAvailableMoves(for: aiPlayer)
        }
        return nil
    }
    
    // Apply a game model update (a move) to the game state
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let aiMove = gameModelUpdate as? AIMove {
            chessBoard.movePieceAI(from: aiMove.move.from, to: aiMove.move.to)
        }
    }
    
    func shouldContinueGame(for player: AIPlayer) -> Bool {
        if isWin(for: player) || isLoss(for: player) {
            return false //the game ends
        }
        return true
    }
    
    func generateAvailableMoves(for player: AIPlayer) -> [AIMove] {
        var moves: [AIMove] = []
        let playerPieces = chessBoard.activePieces.filter { $0.side == player.player }

        playerPieces.forEach { piece in
            let pieceIndex = chessBoard.getPiece(piece)
            let newMoves: [AIMove]

            switch piece.pieceType {
            case .pawn:
                let pawnMoves = chessBoard.allValidPawnMoves(board: chessBoard.piecePositions.value, from: pieceIndex, history: chessBoard.history.value)
                newMoves = pawnMoves.map { AIMove(move: $0) }
            case .knight:
                let knightMoves = chessBoard.allValidKnightMoves(board: chessBoard.piecePositions.value, from: pieceIndex)
                newMoves = knightMoves.map { AIMove(move: $0) }
            case .king:
                let kingMoves = chessBoard.allValidKingMoves(board: chessBoard.piecePositions.value, from: pieceIndex)
                newMoves = kingMoves.map { AIMove(move: $0) }
            case .rook:
                let rookMoves = chessBoard.allValidRookMoves(board: chessBoard.piecePositions.value, from: pieceIndex)
                newMoves = rookMoves.map { AIMove(move: $0) }
            case .bishop:
                let bishopMoves = chessBoard.allValidBishopMoves(board: chessBoard.piecePositions.value, from: pieceIndex)
                newMoves = bishopMoves.map { AIMove(move: $0) }
            case .queen:
                let bishopMoves = chessBoard.allValidBishopMoves(board: chessBoard.piecePositions.value, from: pieceIndex)
                let rookMoves = chessBoard.allValidRookMoves(board: chessBoard.piecePositions.value, from: pieceIndex)
                newMoves = (bishopMoves + rookMoves).map { AIMove(move: $0) }
            }
            moves.append(contentsOf: newMoves)
        }
        return moves.shuffled()
    }
    
    // Check if the current player (AI) has lost
    func isLoss(for player: GKGameModelPlayer) -> Bool {
        if let aiPlayer = player as? AIPlayer {
            // Check if the AI's king is in a loss position (checkmate)
            return chessBoard.isCheckMate(player: aiPlayer.player)
        }
        return false
    }

    // Check if the current player (AI) has won
    func isWin(for player: GKGameModelPlayer) -> Bool {
        if let aiPlayer = player as? AIPlayer {
            // Check if the opponent is in a loss position (checkmate)
            return chessBoard.isCheckMate(player: aiPlayer.player)
        }
        return false
    }
    
    // Assign a score to the current game state for the AI player
    func score(for player: GKGameModelPlayer) -> Int {
        guard let aiPlayer = player as? AIPlayer else {
            return 0
        }
        
        let selfPieces = chessBoard.activePieces.filter { $0.side == aiPlayer.player }
        let opponentPieces = chessBoard.activePieces.filter { $0.side != aiPlayer.player }
        
        var score = 0
        
        for piece in selfPieces {
            score += piece.pieceType.weight
        }
        
        for piece in opponentPieces {
            score -= piece.pieceType.weight
        }
        
        let checkmateOpponentBonus = 9999
        

        // Try to checkmate the opponent at all costs
        if chessBoard.isCheckMate(player: aiPlayer.player == .white ? .black : .white) {
            score += checkmateOpponentBonus
        }

        return score
    }
}
