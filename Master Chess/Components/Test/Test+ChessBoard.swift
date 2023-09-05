/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 19/08/2023
 Last modified: 19/08/2023
 Acknowledgement:
 */

import Foundation

extension ChessBoard {
    func forceMove(start from: Position, end to: Position) {
        guard from.isValid && to.isValid else {
            print("Invalid positions provided for forceMove")
            return
        }
        
        let fromPiece = getPiece(at: from)

        guard fromPiece != nil else {
            print("No piece found at the 'from' position")
            return
        }

        // If you also want to check if there's already a piece at the 'to' position
        guard piecePositions.value[to.y][to.x] == nil else {
            print("There's already a piece at the 'to' position")
            return
        }
        
        piecePositions.value[to.y][to.x] = piecePositions.value[from.y][from.x]
        piecePositions.value[from.y][from.x] = nil
    }
}
