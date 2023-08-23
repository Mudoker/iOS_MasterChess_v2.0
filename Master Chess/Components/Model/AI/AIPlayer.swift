// https://www.youtube.com/watch?v=53uMIUUhLwk&t=176s
import Foundation

import GameplayKit

// Set up AI player
class AIPlayer: NSObject, GKGameModelPlayer {
    var playerId: Int
    let player: Player
    
    static var allPlayers = [AIPlayer(player: .white), AIPlayer(player: .black)]

    var opponent: AIPlayer {
        return player == .white ? AIPlayer.allPlayers[1] : AIPlayer.allPlayers[0]
    }
    
    init(player: Player) {
        self.player = player
        self.playerId = player == .white ? 1 : 0
        super.init()
    }
}
