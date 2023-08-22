import Foundation

import GameplayKit

class AIPlayer: NSObject, GKGameModelPlayer {
    var playerId: Int
    
    let player: Player
    
    static var allPlayers = [AIPlayer(player: .white), AIPlayer(player: .black)]
    
    // set the side for AI based on user side
    var opponent: AIPlayer {
        if player == .white {
            return AIPlayer.allPlayers[1]
        } else {
            return AIPlayer.allPlayers[0]
        }
    }
    
    init(player: Player) {
        self.player = player
        self.playerId = player == .white ? 1 : 0
        super.init()
    }
}
