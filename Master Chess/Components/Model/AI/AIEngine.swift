import Foundation
import GameplayKit

class AIEngine: NSObject, GKGameModel {

    let chessBoard: ChessBoard
    let allValidMoves: [Move] = []
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
        if player.player == .black {
            if isLoss(for: player) {
                return false
            }
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
    
    // check is black is loss -> check mate
    func isLoss(for player: GKGameModelPlayer) -> Bool {
        if player.playerId == 0 {
            return chessBoard.isCheckMate(player: .black)
        }
        return false
    }
    
    func score(for player: GKGameModelPlayer) -> Int {
        if let aiPlayer = player as? AIPlayer {
            let selfPieces = chessBoard.activePieces.filter { $0.side == aiPlayer.player }.map { $0.pieceType.weight }.reduce(0, +)

            let opponentPieces = chessBoard.activePieces.filter { $0.side != aiPlayer.player }.map { $0.pieceType.weight }.reduce(0, +)

            return selfPieces - opponentPieces
        }
        return 0
    }
}
