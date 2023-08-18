//
//  GameView.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 18/08/2023.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var currentUser: CurrentUser
    @State private var currentPiece: (ChessPiece?, CGSize) = (nil, .zero)
    @ObservedObject var viewModel = GameViewModel()
    @State private var isRotatingWhite = true
    var body: some View {
        ZStack {
            
        }
        
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
