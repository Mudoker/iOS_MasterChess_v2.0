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
    @State private var pulsingScale: CGFloat = 1.0

    private func startPulsingAnimation() {
        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulsingScale = 1.1
        }
    }

    private func resetPulsingAnimation() {
        pulsingScale = 1.0
    }


    var body: some View {
        ZStack {
            ChessBoardView(viewModel: viewModel)
            GeometryReader { proxy in
                VStack {
                    Spacer().frame(height: proxy.size.width / 2.60)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 8), spacing: 0) {
                        ForEach(0..<8) { y in
                            ForEach(0..<8) { x in
                                let currentPosition = Position(x: x, y: y)
                                let isMoveValid = viewModel.allValidMoves.contains { move in
                                   return move.to == currentPosition
                               }
                                if let piece = viewModel.getPiece(at: currentPosition) {
                                    Image(piece.imageView)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: proxy.size.width / 9, height: proxy.size.width / 8)
                                        .overlay(
                                            Circle()
                                                .fill(isMoveValid ? Color.blue.opacity(0.8) : .clear)
                                                .frame(width: isMoveValid ? 16 : 0, height: isMoveValid ? 16 : 0)  // Adjust the size of the inner circle
                                        )
                                        .offset(self.currentPiece.0 == piece ? self.currentPiece.1 : .zero)
                                        .onTapGesture {
                                            if piece.side == viewModel.currentPlayer {  // Check if the piece's side is white
                                                if self.currentPiece.0 == piece {
                                                    self.currentPiece.0 = nil
                                                    viewModel.allValidMoves = [] // Clear available moves when tapping again
                                                } else {
                                                    self.currentPiece = (piece, .zero)
                                                    viewModel.allMove(from: Position(x: x, y: y), piece: piece)
                                                }
                                            } else {
                                                if let selectedPiece = currentPiece.0 {
                                                    let move = Move(from: viewModel.indexOf(selectedPiece), to: currentPosition)
                                                    if viewModel.allValidMoves.contains(where: { $0 == move }) {
                                                        viewModel.didMove(move: move, piece: selectedPiece)
                                                        currentPiece.0 = nil
                                                        self.resetPulsingAnimation()
                                                    }
                                                }
                                            }
                                        }
                                        .gesture(self.dragGesture(piece))
                                        .zIndex(self.currentPiece.0 == piece ? 1 : 0) // Higher zIndex for the current piece
                                        
                                } else {
                                    let currentPosition = Position(x: x, y: y)
                                    let isMoveValid = viewModel.allValidMoves.contains { move in
                                       return move.to == currentPosition
                                   }
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .overlay(
                                            Circle()
                                                .fill(isMoveValid ? Color.blue.opacity(0.8) : .clear)
                                                .frame(width: isMoveValid ? 16 : 0, height: isMoveValid ? 16 : 0)  // Adjust the size of the inner circle
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            if let selectedPiece = currentPiece.0 {
                                                let move = Move(from: viewModel.indexOf(selectedPiece), to: currentPosition)
                                                if viewModel.allValidMoves.contains(where: { $0 == move }) {
                                                    viewModel.didMove(move: move, piece: selectedPiece)
                                                    currentPiece.0 = nil
                                                    self.resetPulsingAnimation()
                                                }
                                            }
                                        }
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
                .onEnded { dragValue in
                    let finalPosition = self.viewModel.indexOf(piece) + Position(dragValue.translation)
                    let move = Move(from: self.viewModel.indexOf(piece), to: finalPosition)
                    viewModel.allMove(from: move.from, piece: piece)
                    self.viewModel.didMove(move: move, piece: currentPiece.0 ?? ChessPiece(stringLiteral: ""))
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
