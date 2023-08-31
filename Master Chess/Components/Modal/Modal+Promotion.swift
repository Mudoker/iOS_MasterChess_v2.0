import SwiftUI

struct PromotionModal: View {
    @StateObject var viewModel: GameViewModel
    @State private var selectedPiece = ""
    @State private var isAnimating = false
    var isDark = false
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HStack (spacing: 10) {
                        if viewModel.chessGame.currentPlayer == .black {
                            Button(action: {
                                selectedPiece = "wq"
                                withAnimation(.easeIn) {
                                    viewModel.chessGame.isPromotion = false
                                    viewModel.chessGame.piecePositions.value[viewModel.chessGame.history.value.last?.to.y ?? 0][viewModel.chessGame.history.value.last?.to.x ?? 0] = ChessPiece(stringLiteral: "wq")
                                    viewModel.playSound(sound: "promote", type: "mp3")
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
                                selectedPiece = "wn"
                                withAnimation(.easeIn) {
                                    viewModel.chessGame.isPromotion = false
                                    viewModel.chessGame.piecePositions.value[viewModel.chessGame.history.value.last?.to.y ?? 0][viewModel.chessGame.history.value.last?.to.x ?? 0] = ChessPiece(stringLiteral: "wn")
                                    viewModel.playSound(sound: "promote", type: "mp3")
                                }
                            }) {
                                    Image("wn")
                                        .resizable()
                                        .frame(width: proxy.size.width/7, height: proxy.size.width/7)
                                    
                                }
                            
                            Button(action: {
                                selectedPiece = "wb"
                                withAnimation(.easeIn) {
                                    viewModel.chessGame.isPromotion = false
                                    viewModel.chessGame.piecePositions.value[viewModel.chessGame.history.value.last?.to.y ?? 0][viewModel.chessGame.history.value.last?.to.x ?? 0] = ChessPiece(stringLiteral: "wb")
                                    viewModel.playSound(sound: "promote", type: "mp3")
                                    
                                }
                            }) {
                                Image("wb")
                                    .resizable()
                                    .frame(width: proxy.size.width/7, height: proxy.size.width/7)
                                
                            }
                            
                            Button(action: {
                                selectedPiece = "wr"
                                withAnimation(.easeIn) {
                                    viewModel.chessGame.isPromotion = false
                                    viewModel.chessGame.piecePositions.value[viewModel.chessGame.history.value.last?.to.y ?? 0][viewModel.chessGame.history.value.last?.to.x ?? 0] = ChessPiece(stringLiteral: "wr")
                                    viewModel.playSound(sound: "promote", type: "mp3")
                                    
                                }
                            }) {
                                Image("wr")
                                    .resizable()
                                    .frame(width: proxy.size.width/7, height: proxy.size.width/7)
                                
                            }
                        }
                    }
                    .frame(width: 280, height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
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
