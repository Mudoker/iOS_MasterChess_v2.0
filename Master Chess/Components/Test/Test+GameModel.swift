//
//  Test+GameModel.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 18/08/2023.
//

import SwiftUI

struct Test_GameModel: View {
    @StateObject private var chessGame = ChessBoard()
    var body: some View {
        VStack {
            let x = chessGame.activePieces.count
            Text("Active Pieces Count: \(x)")
            
            let positions = chessGame.createInitialBoard()
            var activePieces: [ChessPiece] { positions.flatMap { $0 }.compactMap { $0 } }
            Text("Initial Pieces Count: \(activePieces.count)")
            
            Text("Black Time Left: \(chessGame.blackTimeLeft)")
            
            Button("Print Piece Positions") {
                print(chessGame.piecePositions)
            }
        }
        .onAppear {
            chessGame.start()
            chessGame.removePiece(at: Position(x: 1, y: 1))
            print("ok")
        }
    }
}

struct Test_GameModel_Previews: PreviewProvider {
    static var previews: some View {
        Test_GameModel()
    }
}

