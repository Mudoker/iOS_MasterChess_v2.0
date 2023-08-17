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
        return chessGame.currentPlayer.value == .white ? AIPlayer.allPlayers[0] : AIPlayer.allPlayers[1]
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = AIEngine(chessGame: chessGame.copy() )
        copy.setGameModel(self)
        return copy
    }

    init(chessGame: ChessBoard) {
        self.chessGame = chessGame
    }

    func setGameModel(_ gameModel: GKGameModel) {
        if let engine = gameModel as? AIEngine {
            chessGame.piecePositions.value = engine.chessGame.piecePositions.value
            chessGame.currentPlayer.value = engine.chessGame.currentPlayer.value
        }
    }

    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        if let playerObject = player as? AIPlayer {
            if isWin(for: playerObject) || isWin(for: playerObject.opponent) {
                return nil
            }
            var moves = [AIMove]()

            let playerPieces = chessGame.activePieces.filter { $0.side == playerObject.player }
            for piece in playerPieces {
                let pieceIndex = chessGame.getPiece(piece)
                let validMoves: [Move]
                
                switch piece.pieceType {
                case .pawn:
                    validMoves = chessGame.allValidPawnMoves(board: chessGame.piecePositions.value, from: pieceIndex, history: chessGame.history)
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
                
                moves.append(contentsOf: validMoves.map { AIMove(move: $0) })
            }
            return moves.shuffled()
        }
        return nil
    }

    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let aiMove = gameModelUpdate as? AIMove {
            chessGame.movePiece(from: aiMove.move.from, to: aiMove.move.to)
        }
    }

    func isWin(for player: GKGameModelPlayer) -> Bool {
        return false // TODO
    }

    func score(for player: GKGameModelPlayer) -> Int {
        if let player = player as? AIPlayer {
            let selfPieces = chessGame.activePieces.filter { $0.side == player.player }.map { $0.pieceType.weight }.reduce(0,+)
            let otherPieces = chessGame.activePieces.filter { $0.side != player.player }.map { $0.pieceType.weight }.reduce(0,+)
            return selfPieces - otherPieces
        }
        return 0
    }
}
