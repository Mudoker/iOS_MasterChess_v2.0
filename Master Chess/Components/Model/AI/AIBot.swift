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
import GameplayKit // built-in AI

class AIBot {
    private let chessBoard: ChessBoard
    private var currentUser = CurrentUser.shared
    
    private let strategist: GKMinmaxStrategist = {
        let strategist = GKMinmaxStrategist()
        return strategist
    } ()
    var isCalculatingMove = false
    var player: Player = .white
    init(chessBoard: ChessBoard, player: Player) {
        self.chessBoard = chessBoard
        
        // Determine maxLookAheadDepth based on user's rank and preference
        let userRating = currentUser.rating
        let userGameDifficulty: String

        if currentUser.hasActiveGame {
            userGameDifficulty = currentUser.savedGameDifficulty
        } else {
            userGameDifficulty = currentUser.settingDifficulty
        }
        
        var maxDepth: Int = 1 // Default to the simplest AI
        
        /*
         AI will now has 3 levels,
         Beginner < 1000: max depth 1 -> Easy
         Novice < 1300: max depth 2 -> Easy
         Intermidiate < 1600: max depth 2 -> Medium
         Expert < 2000: Max depth 3 -> Medium
         From Master will be 3 by default
         */
        
        switch userGameDifficulty {
        case "easy":
            maxDepth = userRating < 1000 ? 1 : 2
        case "normal":
            maxDepth = userRating < 1600 ? 2 : 3
        case "hard":
            maxDepth = 3
        default:
            break
        }
        
        strategist.maxLookAheadDepth = maxDepth
        
        // The AI will not make any random move -> always choose the best move
        strategist.randomSource = nil
        
        self.player = player
    }
    
    // Calculate and return the best move
    func bestMove(completion: @escaping (Move?) -> ()) {
        // is thinking
        isCalculatingMove = true

        // Run asynchronously
        DispatchQueue.global(qos: .background).async {
            // Copy the board
            let boardCopy = self.chessBoard.copy() as! ChessBoard

            self.strategist.gameModel = AIEngine(chessBoard: boardCopy)
            
            // Caluclate best move
            if let aiMove = self.strategist.bestMove(for: self.player == .black ? AIPlayer.allPlayers[1] : AIPlayer.allPlayers[0]) as? AIMove {
                DispatchQueue.main.async {
                    self.isCalculatingMove = false
                    completion(aiMove.move)
                }
            }
        }
    }
}
