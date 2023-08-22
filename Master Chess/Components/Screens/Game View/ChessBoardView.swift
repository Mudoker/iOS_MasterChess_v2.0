import SwiftUI

struct ChessBoardView: View {
    var currentUser = CurrentUser.shared
    let isAdmin = true // Set this to true or false based on admin status
    @StateObject var viewModel: GameViewModel
    var history: [Move] = [
            Move(from: Position(x: 0, y: 1), to: Position(x: 2, y: 3)),
            Move(from: Position(x: 1, y: 2), to: Position(x: 2, y: 3)),
            Move(from: Position(x: 4, y: 4), to: Position(x: 5, y: 5)),
            Move(from: Position(x: 3, y: 0), to: Position(x: 4, y: 1)),
            Move(from: Position(x: 7, y: 6), to: Position(x: 6, y: 5)),
            Move(from: Position(x: 2, y: 1), to: Position(x: 0, y: 0)),
            Move(from: Position(x: 6, y: 0), to: Position(x: 7, y: 1)),
            Move(from: Position(x: 3, y: 7), to: Position(x: 4, y: 6)),
            Move(from: Position(x: 1, y: 5), to: Position(x: 3, y: 4)),
            Move(from: Position(x: 5, y: 2), to: Position(x: 4, y: 3))
        ]
    let columnLabels = "abcdefghijklmnopqrstuvwxyz"
    
    func coordinateString(for point: Position) -> String {
        let xCoordinate = String(columnLabels[columnLabels.index(columnLabels.startIndex, offsetBy: point.x)])
        let yCoordinate = "\(point.y + 1)"
        return "\(xCoordinate)\(yCoordinate)"
    }
    
    func formatTime(_ timeString: String) -> String {
        guard let totalSeconds = Int(timeString) else {
            return ""
        }

        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        let formattedTime = String(format: "%02d:%02d", minutes, seconds)
        return formattedTime
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(red: 0.00, green: 0.09, blue: 0.18)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            Image("profile1")
                                .resizable()
                                .frame(width: proxy.size.width/5, height: proxy.size.width/5)
                            VStack (alignment: .leading) {
                                Text("Mudoker")
                                Text("Grand Master")
                                    .opacity(0.7)
                            }
                            
                        }
                        Spacer()
                        VStack (spacing: proxy.size.width/15) {
                            HStack {
                                Text(formatTime(viewModel.whiteRemainigTime))
                                    .font(.callout)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(viewModel.currentPlayer == .white ?  Color.white.opacity(0.5) : Color.white.opacity(0.1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/40))
                                    .frame(width: proxy.size.width / 6.2)

                                Spacer()
                                Text(formatTime(viewModel.blackRemainigTime))
                                    .font(.callout)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(viewModel.currentPlayer == .white ?  Color.white.opacity(0.1) : Color.white.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/40))
                                    .frame(width: proxy.size.width / 6.2)

                            }
                            Text("\(viewModel.currentPlayer == .white ? (viewModel.chessGame.currentUser.username == "test" ? "Mudoker" : "White") : "Black")'s Turn")
                                .font(.callout)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: proxy.size.width/40)
                                        .stroke(Color.blue, lineWidth: proxy.size.width/100) // Adding stroke color and width
                                )
                                .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/40))
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Image("magnus")
                                .resizable()
                                .frame(width: proxy.size.width/5, height: proxy.size.width/5)
                            VStack (alignment: .trailing) {
                                Text("M.Carlsen")
                                Text("Grand Master")
                                    .opacity(0.7)
                            }
                            
                        }
                    }
                    .frame(height: proxy.size.width/3)
                    .padding(.horizontal)
                    .padding(.bottom, proxy.size.width/20)
                    ForEach((0...7).reversed(), id: \.self) { y in
                        HStack(spacing: 0) {
                            ForEach(0...7, id: \.self) { x in
                                let isAvailableMove = viewModel.allValidMoves.contains { move in
                                    move.to == Position(x: x, y: y)
                                }
                                GlassMorphicCard(
                                    isDarkMode: .constant(!(x + y).isMultiple(of: 2)),
                                    width: proxy.size.width / 8,
                                    height: proxy.size.width / 8,
                                    cornerRadius: 0,
                                    color: .constant(UIBlurEffect.Style.regular),
                                    isCustomColor: (x + y).isMultiple(of: 2)
                                )
                            }
                        }
                    }

                    HStack {
                        let whiteCaptures = viewModel.chessGame.captures.filter { $0.pieceName.starts(with: "b") }
                        let blackCaptures = viewModel.chessGame.captures.filter { $0.pieceName.starts(with: "w") }
                        
                        if whiteCaptures.count > 4 {
                            ForEach(0..<3, id: \.self) { index in
                                if index < whiteCaptures.count {
                                    let pieceName = whiteCaptures[index].pieceName
                                    if !pieceName.isEmpty {
                                        Image(pieceName)
                                            .resizable()
                                            .frame(width: proxy.size.width/15, height: proxy.size.width/15)
                                    }
                                }
                            }
                            Text("+\(whiteCaptures.count - 3)")
                        } else {
                            ForEach(whiteCaptures.indices, id: \.self) { index in
                                let pieceName = whiteCaptures[index].pieceName
                                if !pieceName.isEmpty {
                                    Image(pieceName)
                                        .resizable()
                                        .frame(width: proxy.size.width/15, height: proxy.size.width/15)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        if blackCaptures.count > 4 {
                            ForEach(0..<3, id: \.self) { index in
                                if index < blackCaptures.count {
                                    let pieceName = blackCaptures[index].pieceName
                                    if !pieceName.isEmpty {
                                        Image(pieceName)
                                            .resizable()
                                            .frame(width: proxy.size.width/15, height: proxy.size.width/15)
                                    }
                                }
                            }
                            Text("+\(blackCaptures.count - 3)")
                        } else {
                            ForEach(blackCaptures.indices, id: \.self) { index in
                                let pieceName = blackCaptures[index].pieceName
                                if !pieceName.isEmpty {
                                    Image(pieceName)
                                        .resizable()
                                        .frame(width: proxy.size.width/15, height: proxy.size.width/15)
                                }
                            }
                        }
                    }
                    .frame(height: proxy.size.height/22)
                    .padding(.horizontal)
                    .padding(.vertical)

                    
                    if viewModel.chessGame.history.value.isEmpty {
                        Text("Start a move!")
                            .font(.title2.bold())
                            .opacity(0.7)
                            .frame(height: proxy.size.height / 20)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: proxy.size.width/30) {
                                ForEach(viewModel.chessGame.history.value.indices, id: \.self) { index in
                                    let move = viewModel.chessGame.history.value[index]
                                    Rectangle()
                                        .frame(width: proxy.size.width/6, height: proxy.size.width/12)
                                        .foregroundColor(.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: proxy.size.width/40)
                                                .stroke(index % 2 == 0 ? Color.blue : Color.clear, lineWidth: proxy.size.width/100)
                                        )
                                        .overlay(
                                            Text("\(coordinateString(for: move.from))\(coordinateString(for: move.to))")
                                                .multilineTextAlignment(.center)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        )
                                        .cornerRadius(proxy.size.width/40)
                                }
                            }
                        }
                        .padding()
                        .frame(height: proxy.size.height / 20)
                    }

                    Spacer()

                    HStack (spacing: 20) {
                        Button(action: {
                            // Action for New Game
                        }) {
                            VStack {
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .frame(width: proxy.size.width/18, height: proxy.size.width/18)
                                Text("New game")
                            }
                        }
                        
                        Button(action: {
                            // Action for New Game
                            print(viewModel.chessGame.history.value)
                        }) {
                            VStack {
                                Image(systemName: "flag")
                                    .resizable()
                                    .frame(width: proxy.size.width/18, height: proxy.size.width/18)
                                Text("Resign")
                            }
                        }
                    }
                    Spacer()

                    if isAdmin {
                        HStack (spacing: 20) {
                            Button(action: {
                                // Action for New Game
                            }) {
                                VStack {
                                    Text("Force Win")
                                        .frame(width: proxy.size.width / 4, height: proxy.size.width / 10)
                                        .foregroundColor(.green)
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/50))
                                }
                            }
                            
                            Button(action: {
                                // Action for New Game
                            }) {
                                VStack {
                                    Text("Force Draw")
                                        .frame(width: proxy.size.width / 4, height: proxy.size.width / 10)
                                        .foregroundColor(.yellow)
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/50))
                                }
                            }
                            
                            Button(action: {
                                // Action for New Game
                            }) {
                                VStack {
                                    Text("Force Lose")
                                        .frame(width: proxy.size.width / 4, height: proxy.size.width / 10)
                                        .foregroundColor(.red)
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/50))
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
            }
            .foregroundColor(.white)
        }
    }
}


struct ChessBoardView_Previews: PreviewProvider {
    static var previews: some View {
        ChessBoardView(viewModel: GameViewModel())
    }
}
