//
//  AIEngine.swift
//  Chess
//
//  Created by Ivan Ruiz Monjo on 09/05/2020.
//  Copyright © 2020 Ivan Ruiz Monjo. All rights reserved.
//

import Foundation
import GameplayKit

class AIEngine: NSObject, GKGameModel {

    let chessGame: ChessBoard

    var players: [GKGameModelPlayer]? {
        return AIPlayer.allPlayers
    }

    var activePlayer: GKGameModelPlayer? {
        return chessGame.currentPlayer == .white ? AIPlayer.allPlayers[0] : AIPlayer.allPlayers[1]
    }

    // return a copy of the current AI engine
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = AIEngine(chessGame: chessGame.copy())
        copy.setGameModel(self)
        return copy
    }

    init(chessGame: ChessBoard) {
        self.chessGame = chessGame
    }

    func setGameModel(_ gameModel: GKGameModel) {
        if let engine = gameModel as? AIEngine {
            chessGame.piecePositions = engine.chessGame.piecePositions
            chessGame.currentPlayer = engine.chessGame.currentPlayer
        }
    }

    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        // only generate move for AI
        if let playerObject = player as? AIPlayer {
            
            // stop if the game cannot proceded
            if isGameEnd() {
                return nil
            }
            
            // a list of all available moves for the AI
            var moves = [AIMove]()

            // get all active pieces on the board
            let playerPieces = chessGame.activePieces.filter { $0.side == playerObject.player }
            
            // calculate all possible move for each piece
            for piece in playerPieces {
                let pieceIndex = chessGame.getPiece(piece)
                let validMoves: [Move]
                
                // return all possible moves for each pieces at different locations
                switch piece.pieceType {
                    case .pawn:
                    validMoves = chessGame.allValidPawnMoves(board: chessGame.piecePositions.value, from: pieceIndex, history: chessGame.history.value)
                    case .knight:
                        validMoves = chessGame.allValidKnightMoves(board: chessGame.piecePositions.value, from: pieceIndex)
                    case .king:
                        validMoves = chessGame.allValidKingMoves(board: chessGame.piecePositions.value, from: pieceIndex)
                    case .rook:
                        validMoves = chessGame.allValidRookMoves(board: chessGame.piecePositions.value, from: pieceIndex)
                    case .bishop:
                        validMoves = chessGame.allValidBishopMoves(board: chessGame.piecePositions.value, from: pieceIndex)
                    case .queen:
                        let bishopMoves = chessGame.allValidBishopMoves(board: chessGame.piecePositions.value, from: pieceIndex)
                        let rookMoves = chessGame.allValidRookMoves(board: chessGame.piecePositions.value, from: pieceIndex)
                        validMoves = bishopMoves + rookMoves
                }
                
                // store to moves
                moves.append(contentsOf: validMoves.map { AIMove(move: $0) })
            }
            // if not shuffled, the AI can be easily predicted
            return moves.shuffled()
        }
        return nil
    }

    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let aiMove = gameModelUpdate as? AIMove {
            chessGame.movePiece(from: aiMove.move.from, to: aiMove.move.to)
        }
    }

    func isGameEnd() -> Bool {
        if chessGame.isOutOfTime() || chessGame.isCheckMate() || chessGame.isStaleMate() || chessGame.isInsufficientMaterial(){
            print(chessGame.outcome)
            return true
        }
        return false
    }

    // calculate the current score of each player (based on piece's weigtht)
    func score(for player: GKGameModelPlayer) -> Int {
        if let player = player as? AIPlayer {
            let selfPieces = chessGame.activePieces.filter { $0.side == player.player }.map { $0.pieceType.weight }.reduce(0,+)
            let otherPieces = chessGame.activePieces.filter { $0.side != player.player }.map { $0.pieceType.weight }.reduce(0,+)
            return selfPieces - otherPieces
        }
        return 0
    }
}
