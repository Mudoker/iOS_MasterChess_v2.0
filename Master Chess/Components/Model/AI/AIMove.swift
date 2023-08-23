//
//  AIMove.swift
//  Chess
//
//  Created by Ivan Ruiz Monjo on 09/05/2020.
//  Copyright © 2020 Ivan Ruiz Monjo. All rights reserved.
//

import GameplayKit

// Game model update is the move
class AIMove: NSObject, GKGameModelUpdate {
    let move: Move
    var value: Int = 0

    init(move: Move) {
        self.move = move
    }
}

