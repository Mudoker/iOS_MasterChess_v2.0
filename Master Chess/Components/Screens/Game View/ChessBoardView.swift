import SwiftUI

struct ChessBoardView: View {
    @State var currentUser = Users()
    let yourCapturedCount: Int = 7
    let theirCapturedCount: Int = 10
    let isAdmin = true // Set this to true or false based on admin status
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
                        VStack (spacing: proxy.size.width/15) {
                            HStack {
                                Text("04:03")
                                    .font(.callout)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.white.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/40))
                                Spacer()
                                Text("04:03")
                                    .font(.callout)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/40))
                            }
                            Text("Mudoker's Turn")
                                .font(.callout)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: proxy.size.width/40)
                                        .stroke(Color.blue, lineWidth: proxy.size.width/100) // Adding stroke color and width
                                )
                                .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/40))
                        }
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
                    .padding(.horizontal)
                    .padding(.bottom, proxy.size.width/20)
                    ForEach((0...7).reversed(), id: \.self) { y in
                        HStack(spacing: 0) {
                            ForEach(0...7, id: \.self) { x in
                                GlassMorphicCard(
                                    isDarkMode: .constant((x + y).isMultiple(of: 2)),
                                    width: proxy.size.width / 8,
                                    height: proxy.size.width / 8,
                                    cornerRadius: 0,
                                    color: .constant(UIBlurEffect.Style.regular),
                                    isCustomColor: !(x + y).isMultiple(of: 2)
                                )
                            }
                        }
                    }
                    
                    HStack {
                        if yourCapturedCount > 5 {
                            ForEach(0..<3, id: \.self) { _ in
                                Image("wr")
                                    .resizable()
                                    .frame(width: proxy.size.width/15, height: proxy.size.width/15)
                            }
                            Text("+\(+yourCapturedCount - 3)")
                        } else {
                            ForEach(0..<yourCapturedCount, id: \.self) { _ in
                                Image("wr")
                                    .resizable()
                                    .frame(width: proxy.size.width/15, height: proxy.size.width/15)
                            }
                        
                        }

                        Spacer()

                        if yourCapturedCount > 5 {
                            ForEach(0..<3, id: \.self) { _ in
                                Image("wr")
                                    .resizable()
                                    .frame(width: proxy.size.width/15, height: proxy.size.width/15)
                            }
                            Text("+\(+yourCapturedCount - 3)")
                        } else {
                            ForEach(0..<yourCapturedCount, id: \.self) { _ in
                                Image("wr")
                                    .resizable()
                                    .frame(width: proxy.size.width/15, height: proxy.size.width/15)
                            }
                        
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: proxy.size.width/30) {
                            ForEach(history.indices, id: \.self) { index in
                                let move = history[index]
                                Rectangle()
                                    .frame(width: proxy.size.width/6, height: proxy.size.width/12)
                                    .foregroundColor(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: proxy.size.width/40)
                                            .stroke(index % 2 == 0 ? Color.blue : Color.clear, lineWidth: proxy.size.width/100)
                                    )
                                    .overlay(
                                        Text("\(coordinateString(for: move.from))\(coordinateString(for: move.to))")
                                            .multilineTextAlignment(.center)
                                            .font(.caption)
                                            .foregroundColor(.black)
                                    )
                                    .cornerRadius(proxy.size.width/40)
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()

                    HStack (spacing: 20) {
                        Button(action: {
                            // Action for New Game
                        }) {
                            VStack {
                                Image(systemName: "plus.circle")
                                    .resizable()
                                .frame(width: proxy.size.width/16, height: proxy.size.width/16)
                                Text("New game")
                            }
                        }
                        
                        Button(action: {
                            // Action for New Game
                        }) {
                            VStack {
                                Image(systemName: "flag")
                                    .resizable()
                                .frame(width: proxy.size.width/16, height: proxy.size.width/16)
                                Text("Resign")
                            }
                        }
                    }
                    
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
                                        .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/80))
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
                                        .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/80))
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
                                        .clipShape(RoundedRectangle(cornerRadius: proxy.size.width/80))
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
        ChessBoardView()
    }
}