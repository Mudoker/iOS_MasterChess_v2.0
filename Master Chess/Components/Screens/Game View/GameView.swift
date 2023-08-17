//
//  GameView.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 17/08/2023.
//

import SwiftUI

struct GameView: View {
    @State private var currentUser: Users = Users()
    @State private var currentPiece: (ChessPiece?, CGSize) = (nil, .zero)
    @ObservedObject var viewModel: GameViewModel
    @State private var isRotatingWhite = true

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Users.username, ascending: true)], animation: .default) private var users: FetchedResults<Users>
    @AppStorage("userName") private var username = "Mudoker"

    init(user: Users) {
        viewModel = GameViewModel(user: user)
    }

    func getUserWithUsername(_ username: String) -> Users? {
        return users.first { $0.username == username }
    }

    var body: some View {
        ZStack {
            ChessBoardView()
            ForEach(viewModel.pieces) { piece in
                Image(piece.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(currentPiece.0 == piece ? 1.3 : 1)
                    .offset(currentPiece.0 == piece ? currentPiece.1 : viewModel.indexOf(piece).size)
                    .frame(width: UIScreen.main.bounds.width / 8, height: UIScreen.main.bounds.width / 8)
                    .gesture(viewModel.dragGesture(piece))
                    .animation(.easeInOut(duration: 0.2))
            }
        }
        .onAppear {
            if let user = getUserWithUsername(username) {
                currentUser = user
                viewModel = GameViewModel(user: user)
            }
        }
    }

    private func dragGesture(_ piece: ChessPiece) -> _EndedGesture<_ChangedGesture<DragGesture>> {
        DragGesture()
            .onChanged { dragValue in
                self.currentPiece = (piece, self.viewModel.indexOf(piece).size + dragValue.translation)
                self.viewModel.objectWillChange.send()
        }
        .onEnded {
            self.currentPiece = (nil, .zero)
            let finalPosition = self.viewModel.indexOf(piece) + Position($0.translation)
            let move = Move(start: self.viewModel.indexOf(piece), end: finalPosition)
            self.viewModel.didMove(move: move)
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(user: Users())
    }
}
