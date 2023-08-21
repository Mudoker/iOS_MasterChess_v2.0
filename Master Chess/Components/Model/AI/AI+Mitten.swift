//
//  SimpleAI.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 17/08/2023.
//

import Foundation
import GameplayKit // built in AI

class Mitten {
    private let chessGame: ChessBoard
    
    // use built-in AI in GamePlayKit
    private let minMaxStrategist: GKMinmaxStrategist
    
    // is the AI is analyzing
    var isThinking = false

    init(chessGame: ChessBoard) {
        self.chessGame = chessGame
        // built in AI
        minMaxStrategist = GKMinmaxStrategist()
        
        // The AI will calculate 8 moves ahead
        minMaxStrategist.maxLookAheadDepth = 1
        
        // Make the AI deterministic not random
        minMaxStrategist.randomSource = nil
    }

    // find best move
    func bestMove(completion: @escaping (Move?) -> ())  {
        // set to is thiking
        isThinking = true
        
        // copy the current state of the game
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
