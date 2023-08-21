//  Test+Pawn.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 19/08/2023.
//

import SwiftUI

struct Test_Pawn: View {
    @StateObject var chess = ChessBoard()
    @State private var isMoveDone = false

    var body: some View {
        VStack {
            let piecesLocations = chess.createInitialBoard()

            if isMoveDone {
                let move = [Move(from: Position(x: 0, y: 1), to:  Position(x: 0, y: 3))]  // Specify the actual move coordinates here
                let isValidPawnMove = chess.validPawnMove(board: piecesLocations, from: Position(x: 1, y: 1), to: Position(x:4, y: 7), history: move)
                let piece = chess.getPiece(at: Position(x: 0, y: 3))
                Text(piece?.pieceName ?? "ok")

                Text("Is Pawn Move Valid: \(isValidPawnMove ? "Yes" : "No")")
            } else {
                Text("Tap 'Move Piece' to start")
            }

            Button("Move Piece") {
                chess.forceMove(start: Position(x: 0, y: 1), end: Position(x: 0, y: 3))
                print("")
                isMoveDone = true
            }

        }
        .onAppear {
            chess.currentPlayer = .white
            chess.piecePositions.value = chess.createInitialBoard()
        }
    }
}


struct Test_Pawn_Previews: PreviewProvider {
    static var previews: some View {
        Test_Pawn()
    }
}