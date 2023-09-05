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

// Set up AI player
class AIPlayer: NSObject, GKGameModelPlayer {
    var playerId: Int
    let player: Player
    
    // Create an array of AI players
    static var allPlayers = [AIPlayer(player: .white), AIPlayer(player: .black)]

    // Compute the opponent player based on the current player
    var opponent: AIPlayer {
        return player == .white ? AIPlayer.allPlayers[1] : AIPlayer.allPlayers[0]
    }
    
    // Initialize the AI player
    init(player: Player) {
        self.player = player
        self.playerId = player == .white ? 1 : 0
        super.init()
    }
}
