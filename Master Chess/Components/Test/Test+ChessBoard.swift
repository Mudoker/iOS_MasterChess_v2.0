//
//  Test+ChessBoard.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 19/08/2023.
//

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
        guard piecePositions[to.y][to.x] == nil else {
            print("There's already a piece at the 'to' position")
            return
        }
        
        piecePositions[to.y][to.x] = piecePositions[from.y][from.x]
        piecePositions[from.y][from.x] = nil
    }
}
