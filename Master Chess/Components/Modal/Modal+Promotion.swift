/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 29/08/2023
 Last modified: 03/09/2023
 Acknowledgement:
 */

import SwiftUI

// Appear for pawn promotion
struct PromotionModal: View {
    // Watch the game model
    @StateObject var viewModel: GameViewModel
    
    // Selected Piece for promotion
    @State private var selectedPiece = ""
    
    // Shaking animation for queen
    @State private var isAnimating = false
    
    // Current user instance
    var currentUser = CurrentUser.shared
    
    // Dark and light mode
    var isDark = false
    
    var body: some View {
        GeometryReader { proxy in
            // Center vertically
            VStack {
                Spacer()
                
                // Center Horizontally
                HStack {
                    Spacer()
                    
                    // List of piece to promote
                    HStack (spacing: 10) {
                        if viewModel.chessGame.currentPlayer == .white {
                            Button(action: {
                                // Set selected piece
                                selectedPiece = "wq"
                                
                                // Animation
                                withAnimation(.easeIn) {
                                    // Update piece at position
                                    if viewModel.chessGame.history.value.count >= 2 {
                                            let nearLastMove = viewModel.chessGame.history.value[viewModel.chessGame.history.value.count - 2]
                                            viewModel.chessGame.piecePositions.value[nearLastMove.to.y][nearLastMove.to.x] = ChessPiece(stringLiteral: "wq")
                                    } else {
                                        print("There are not enough moves in the history to update piece positions.")
                                    }
                                    
                                    // Finish promotion -> set to false
                                    viewModel.chessGame.isPromotion = false
                                    
                                    // Promotion sound
                                    if currentUser.settingSoundEnabled {
                                        viewModel.playSound(sound: "promote", type: "mp3")
                                    }
                                    viewModel.didMove(move: Move(from: Position(x: -1, y: -1), to: Position(x: -1, y: -1)), piece: ChessPiece(stringLiteral: "wr"))
                                }
                            }) {
                                Image("wq")
                                    .resizable()
                                    .frame(width: proxy.size.width/7, height: proxy.size.width/7)
                                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                                    .animation(
                                        Animation.easeInOut(duration: 0.5)
                                            .repeatForever(autoreverses: true),value: isAnimating // Pulsating effect
                                    )
                            }
                            .onAppear {
                                withAnimation(.easeInOut) {
                                    isAnimating.toggle()
                                }
                            }
                            
                            Button(action: {
                                // Set selected piece
                                selectedPiece = "wn"
                                
                                // Animation
                                withAnimation(.easeIn) {
                                    // Update piece at position
                                    if viewModel.chessGame.history.value.count >= 2 {
                                            let nearLastMove = viewModel.chessGame.history.value[viewModel.chessGame.history.value.count - 2]
                                            viewModel.chessGame.piecePositions.value[nearLastMove.to.y][nearLastMove.to.x] = ChessPiece(stringLiteral: "wn")
                                    } else {
                                        print("There are not enough moves in the history to update piece positions.")
                                    }
                                    // Promotion sound
                                    if currentUser.settingSoundEnabled {
                                        viewModel.playSound(sound: "promote", type: "mp3")
                                    }
                                    
                                    // Finish promotion -> set to false
                                    viewModel.chessGame.isPromotion = false
                                    viewModel.didMove(move: Move(from: Position(x: -1, y: -1), to: Position(x: -1, y: -1)), piece: ChessPiece(stringLiteral: "wr"))
                                }
                            }) {
                                Image("wn")
                                    .resizable()
                                    .frame(width: proxy.size.width/7, height: proxy.size.width/7)
                            }
                            
                            Button(action: {
                                // Set selected piece
                                selectedPiece = "wb"
                                
                                // Animation
                                withAnimation(.easeIn) {
                                    // Update piece at position
                                    if viewModel.chessGame.history.value.count >= 2 {
                                            let nearLastMove = viewModel.chessGame.history.value[viewModel.chessGame.history.value.count - 2]
                                            viewModel.chessGame.piecePositions.value[nearLastMove.to.y][nearLastMove.to.x] = ChessPiece(stringLiteral: "wb")
                                    } else {
                                        print("There are not enough moves in the history to update piece positions.")
                                    }
                                    
                                    // Promotion sound
                                    if currentUser.settingSoundEnabled {
                                        viewModel.playSound(sound: "promote", type: "mp3")
                                    }
                                    // Finish promotion -> set to false
                                    viewModel.chessGame.isPromotion = false
                                    viewModel.didMove(move: Move(from: Position(x: -1, y: -1), to: Position(x: -1, y: -1)), piece: ChessPiece(stringLiteral: "wr"))
                                }
                            }) {
                                Image("wb")
                                    .resizable()
                                    .frame(width: proxy.size.width/7, height: proxy.size.width/7)
                            }
                            
                            Button(action: {
                                // Set selected piece
                                selectedPiece = "wr"
                                
                                // Animation
                                withAnimation(.easeIn) {
                                    // Update piece at position
                                    if viewModel.chessGame.history.value.count >= 2 {
                                            let nearLastMove = viewModel.chessGame.history.value[viewModel.chessGame.history.value.count - 2]
                                            viewModel.chessGame.piecePositions.value[nearLastMove.to.y][nearLastMove.to.x] = ChessPiece(stringLiteral: "wr")
                                    } else {
                                        print("There are not enough moves in the history to update piece positions.")
                                    }
                                    // Promotion sound
                                    if currentUser.settingSoundEnabled {
                                        viewModel.playSound(sound: "promote", type: "mp3")
                                    }
                                    // Finish promotion -> set to false
                                    viewModel.chessGame.isPromotion = false
                                    viewModel.didMove(move: Move(from: Position(x: -1, y: -1), to: Position(x: -1, y: -1)), piece: ChessPiece(stringLiteral: "wr"))
                                }
                            }) {
                                Image("wr")
                                    .resizable()
                                    .frame(width: proxy.size.width/7, height: proxy.size.width/7)
                            }
                        }
                    }
                    .frame(width: proxy.size.width/1.3, height: proxy.size.height/8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.4))
                    )
                    
                    Spacer()
                }
                
                Spacer()
            }
            .background(Modal_BackGround())
        }
    }
}

struct Test_Promotion_Previews: PreviewProvider {
    static var previews: some View {
        PromotionModal(viewModel: GameViewModel())
    }
}
