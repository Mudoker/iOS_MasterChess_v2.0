import Foundation
import GameplayKit

class AIEngine: NSObject, GKGameModel {

    let chessBoard: ChessBoard
    var players: [GKGameModelPlayer]? {
        return AIPlayer.allPlayers
    }
    
    var activePlayer: GKGameModelPlayer? {
        return chessBoard.currentPlayer == .white ? AIPlayer.allPlayers[0] : AIPlayer.allPlayers[1]
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = AIEngine(chessBoard: chessBoard.copy() as! ChessBoard)
        copy.setGameModel(self)
        return copy
    }
    
    init(chessBoard: ChessBoard) {
        self.chessBoard = chessBoard
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? AIEngine {
            chessBoard.piecePositions.value = board.chessBoard.piecePositions.value
            chessBoard.currentPlayer = board.chessBoard.currentPlayer
            chessBoard.availableMoves = board.chessBoard.availableMoves
        }
    }

    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        guard let aiPlayer = player as? AIPlayer else {
            return nil
        }
        if shouldContinueGame(for: aiPlayer) {
            return generateAvailableMoves(for: aiPlayer)
        }
        return nil
    }
    
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
    
    // Implement the isLoss function
    func isLoss(for player: GKGameModelPlayer) -> Bool {
        if let aiPlayer = player as? AIPlayer {
            // Check if the AI's king is in a loss position (checkmate)
            return chessBoard.isCheckMate(player: aiPlayer.player)
        }
        return false
    }

    // check is black is loss -> check mate
    func isWin(for player: GKGameModelPlayer) -> Bool {
        if let aiPlayer = player as? AIPlayer {
            // Check if the opponent is in a loss position (checkmate)
            return isLoss(for: aiPlayer.opponent)
        }
        return false
    }
    
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
        
        let checkOpponentBonus = 500
        let checkPenalty = -500
        let checkedMatePenalty = -9999
        let checkmateOpponentBonus = 9999
        
        // Try to check the opponent
        if chessBoard.isKingInCheck(board: chessBoard.piecePositions.value, player: aiPlayer.player == .white ? .black : .white) {
            score += checkOpponentBonus
        }
        
        // Try to avoid being checked
        if chessBoard.isKingInCheck(board: chessBoard.piecePositions.value, player: aiPlayer.player) {
            score += checkPenalty
        }
        
        // Try to avoid moving into a checkmate position at all cost
        if chessBoard.isCheckMate(player: aiPlayer.player) {
            score += checkedMatePenalty
        }
        
        // Try to checkmate the opponent at all costs
        if chessBoard.isCheckMate(player: aiPlayer.player == .white ? .black : .white) {
            score += checkmateOpponentBonus
        }
        
        return score
    }
}
