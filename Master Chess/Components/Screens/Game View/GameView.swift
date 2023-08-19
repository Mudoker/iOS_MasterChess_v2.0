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
    @StateObject var viewModel = GameViewModel()
    @State private var isRotatingWhite = true
    @State var show = true
    
    // Replace this with your actual piecesPosition data
    let piecesPosition: [(ChessPiece, Position)] = [
        // Fill in your piecesPosition data here
    ]

    var body: some View {
        ZStack {
            ChessBoardView()
            GeometryReader { proxy in
                VStack {
                    Spacer().frame(height: proxy.size.width / 2.60)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 8), spacing: 0) {
                        ForEach(0..<8) { y in
                            ForEach(0..<8) { x in
                                let position = Position(x: x, y: y)
                                if (y < 2 || y > 5), let piece = viewModel.getPiece(at: position) {
                                    Image(piece.imageView)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: proxy.size.width / 9, height: proxy.size.width / 8)
                                        .offset(self.currentPiece.0 == piece ? self.currentPiece.1 : .zero)
                                        .gesture(self.dragGesture(piece))
                                        .onTapGesture {
                                            viewModel.removePiece(at: position)
                                        }
                                } else {
                                    Color.clear
                                        .frame(width: proxy.size.width / 8, height: proxy.size.width / 8)
                                }
                            }
                        }
                    }
                }
                
            }
        }
        .onAppear {
            self.viewModel.start()
        }
    }
    
    private func dragGesture(_ piece: ChessPiece) -> some Gesture {
        DragGesture()
            .onChanged { dragValue in
                self.currentPiece = (piece, dragValue.translation)
                self.viewModel.objectWillChange.send()
            }
            .onEnded {
                let finalPosition = self.viewModel.indexOf(piece) + Position($0.translation)
                let move = Move(from: self.viewModel.indexOf(piece), to: finalPosition)
                self.viewModel.didMove(move: move, piece: currentPiece.0 ?? ChessPiece(stringLiteral: ""))

                // Reset the currentPiece after the drag gesture ends
                self.currentPiece = (nil, .zero)
            }
    }
}

// overide + for adding with cgsize
func +(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
