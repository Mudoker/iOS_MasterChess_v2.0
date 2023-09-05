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

import GameplayKit

// Represents a move made by the AI player
class AIMove: NSObject, GKGameModelUpdate {
    let move: Move
    var value: Int = 0

    init(move: Move) {
        self.move = move
    }
}

