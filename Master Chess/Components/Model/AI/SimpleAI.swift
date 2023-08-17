//
//  SimpleAI.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 17/08/2023.
//

import Foundation
import GameplayKit

class SimpleAI {

    private let chessGame: ChessBoard
    private let minMaxStrategist: GKMinmaxStrategist
    var isThinking = false

    init(chessGame: ChessBoard) {
        self.chessGame = chessGame
        minMaxStrategist = GKMinmaxStrategist()
        minMaxStrategist.maxLookAheadDepth = 3
        minMaxStrategist.randomSource = nil
    }

    func bestMove(completion: @escaping (Move?) -> ())  {
        isThinking = true
        let copy = chessGame.copy()
        minMaxStrategist.gameModel = AIEngine(chessGame: copy)
        DispatchQueue.global(qos: .background).async {
            if let aiMove = self.minMaxStrategist.randomMove(for: AIPlayer.allPlayers[1], fromNumberOfBestMoves: 3) as? AIMove {
                DispatchQueue.main.async {
                    self.isThinking = false
                    completion(aiMove.move)
                }
            }
        }
        completion(nil)
    }
}
