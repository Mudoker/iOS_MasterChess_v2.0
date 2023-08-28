//
//  RatingCalculator.swift
//  Master Chess
//
//  Created by quoc on 28/08/2023.
// https://en.wikipedia.org/wiki/Elo_rating_system
//

import Foundation

class RatingCalculator {
    static let shared = RatingCalculator()
    
    private let kFactor = 200
    
    func calculateRatingChange(playerRating: Int, opponentRating: Int, result: GameResult, difficulty: String) -> Int {
        // Calculate the expected win probability for the player
        let expectedOutcome = expectedOutcome(playerRating: playerRating, opponentRating: opponentRating)
        
        // Get the actual outcome based on the game result
        let actualOutcome = actualOutcome(for: result)
        
        // Get the difficulty multiplier based on the selected difficulty
        let difficultyMultiplier = difficultyMultiplier(for: difficulty)
        
        // Calculate the rating change using the Elo formula
        let ratingChange = Int(Double(kFactor) * Double(difficultyMultiplier) * (actualOutcome - expectedOutcome))
        
        return ratingChange
    }
    
    // Calculate the expected outcome based on rating differences
    private func expectedOutcome(playerRating: Int, opponentRating: Int) -> Double {
        return 1.0 / (1.0 + pow(10, Double(opponentRating - playerRating) / 400.0))
    }
    
    // Compare with the actual out come
    private func actualOutcome(for result: GameResult) -> Double {
        switch result {
            case .checkmate, .outOfTime:
                return 1.0
            case .stalemate, .insufficientMaterial, .fiftyMoveRule, .outOfMove, .ongoing:
                return 0.5
        }
    }
    
    // The harder the AI, the more score will have when win
    private func difficultyMultiplier(for difficulty: String) -> Double {
        switch difficulty {
            case "easy":
                return 0.8
            case "medium":
                return 1.0
            case "hard":
                return 1.2
            default:
                return 1.0
        }
    }
}
