//
//  Test+GameModel.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 18/08/2023.
//

import SwiftUI

struct Test_GameModel: View {
    var chessGame = ChessBoard()
    var body: some View {
        VStack {
            let x = chessGame.activePieces.count
            Text(String(x))
            
            let positions = chessGame.createInitialBoard()
            var activePieces: [ChessPiece] { positions.flatMap { $0 }.compactMap { $0 } }
            Text(String(activePieces.count))
        }
        .onAppear {
            chessGame.start()
            print("ok")
        }
        
    }
}

struct Test_GameModel_Previews: PreviewProvider {
    static var previews: some View {
        Test_GameModel()
    }
}
	
