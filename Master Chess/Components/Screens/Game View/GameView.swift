//
//  GameView.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 17/08/2023.
//

import SwiftUI

struct GameView: View {
    @State var currentUser: Users = Users()
    @State private var currentPiece: (Piece?, CGSize) = (nil, .zero)
    @ObservedObject var viewModel: GameViewModel
    @State var isRotatingWhite = true

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Users.username, ascending: true)], animation: .default) private var users: FetchedResults<Users>
    @State var isRotatingWhite = true

    @AppStorage("userName") var username = "Mudoker"
    
    init(user: Users) {
            viewModel = GameViewModel(user: user)
    }
    func getUserWithUsername(_ username: String) -> Users? {
        return users.first { $0.username == username }
    }
    var board = ChessBoard().createInitialBoard()
    var body: some View {
        ZStack {
            ChessBoardView()
            ForEach(viewModel.pieces) { piece in
                Image(piece.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(viewModel.currentPiece.0 == piece ? 1.3 : 1)
                    .offset(viewModel.currentPiece.0 == piece ? viewModel.currentPiece.1 : viewModel.indexOf(piece).size)
                    .frame(width: UIScreen.main.bounds.width / 8, height: UIScreen.main.bounds.width / 8)
                    .gesture(viewModel.dragGesture(piece))
                    .animation(.easeInOut(duration: 0.2))
            }
        }
        .onAppear {
            currentUser = getUserWithUsername(username) ?? Users()
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(viewModel: GameViewModel()) // Provide an instance of your GameViewModel here
    }
}
