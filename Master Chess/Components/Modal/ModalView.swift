//
//  Modal+Win.swift
//  Master Chess
//
//  Created by quoc on 29/08/2023.
//

import SwiftUI

struct ModalView: View {
    @StateObject var viewModel: GameViewModel
    @State var isShowMenuView = false
    @State var isShowProfileView = false
    @State var isExpanded = false
    @State var isConfetti = false

    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                if isShowMenuView {
                    MenuView()
                } else if isShowProfileView {
                    ProfileView()
                } else {
                    ZStack {
                        Modal_BackGround()
                        VStack {
                            Spacer()
                                .frame(height: proxy.size.width/12)
                            
                            HStack {
                                Image("trumpet")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: proxy.size.width/7)
                                    .scaleEffect(x: -1, y: 1)
                                    .rotationEffect(viewModel.chessGame.winner == .white ? .degrees(25) : .degrees(-25))

                                VStack {
                                    if viewModel.chessGame.outcome == .checkmate ||  viewModel.chessGame.outcome == .outOfMove || viewModel.chessGame.outcome == .outOfTime{
                                        if viewModel.chessGame.winner == .white {
                                            Text("YOU WON")
                                                .font(.largeTitle)
                                                .bold()
                                                .scaleEffect(isExpanded ? 1.1 : 1) // Apply scale effect
                                                .animation(
                                                    Animation.easeInOut(duration: 2) // Use easeInOut animation curve
                                                        .repeatForever(autoreverses: true)
                                                    ,value: isExpanded
                                                )
                                                .onAppear {
                                                    withAnimation {
                                                        isExpanded.toggle() // Toggle the state to start the animation
                                                    }
                                                }
                                                .particleEffect(status: isConfetti)
                                                .onAppear {
                                                    isConfetti = true
                                                }
                                            
                                            Text("Checkmate")
                                                .font(.title3)
                                                .opacity(0.7)
                                        }
                                        else {
                                            Text("YOU LOSS")
                                                .font(.largeTitle)
                                                .bold()
                                                .scaleEffect(isExpanded ? 1.1 : 1) // Apply scale effect
                                                .animation(
                                                    Animation.easeInOut(duration: 2) // Use easeInOut animation curve
                                                        .repeatForever(autoreverses: true)
                                                    ,value: isExpanded
                                                )
                                                .onAppear {
                                                    withAnimation {
                                                        isExpanded.toggle() // Toggle the state to start the animation
                                                    }
                                                }
                                            Text("Checkmate")
                                                .font(.title3)
                                                .opacity(0.7)
                                        }
                                    } else {
                                        Text("DRAW")
                                            .font(.largeTitle)
                                            .bold()
                                            .scaleEffect(isExpanded ? 1.1 : 1) // Apply scale effect
                                            .animation(
                                                Animation.easeInOut(duration: 2) // Use easeInOut animation curve
                                                    .repeatForever(autoreverses: true)
                                                ,value: isExpanded
                                            )
                                            .onAppear {
                                                withAnimation {
                                                    isExpanded.toggle() // Toggle the state to start the animation
                                                }
                                            }
                                            .particleEffect(status: isConfetti)
                                            .onAppear {
                                                isConfetti = true
                                            }
                                        
                                        if viewModel.chessGame.outcome == .insufficientMaterial {
                                            Text("Insufficient Material")
                                                .font(.title3)
                                                .opacity(0.7)
                                        } else if viewModel.chessGame.outcome == .stalemate {
                                            Text("Stale Mate")
                                                .font(.title3)
                                                .opacity(0.7)
                                        }
                                        Text("Stale Mate")
                                            .font(.title3)
                                            .opacity(0.7)
                                    }
                                }
                                Image("trumpet")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: proxy.size.width/7)
                                    .rotationEffect(viewModel.chessGame.winner == .white ? .degrees(-25) : .degrees(25))
                            }
                            
                            
                            ZStack {
                                HStack {
                                    VStack (alignment: .leading) {
                                        Image(CurrentUser.shared.profilePicture ?? "profile1")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: proxy.size.width/3.5, height: proxy.size.width/3.5)
                                        
                                        
                                        Text(viewModel.whitePlayerName)
                                            .font(.title2)
                                            .padding(.leading)
                                        
                                        if CurrentUser.shared.rating < 800 {
                                            Text("Newbie")
                                                .padding(.leading)
                                        } else if CurrentUser.shared.rating < 1300 {
                                            Text("Pro")
                                                .padding(.leading)
                                        } else if CurrentUser.shared.rating < 1600 {
                                            Text("Master")
                                                .padding(.leading)
                                        } else {
                                            Text("Grand Master")
                                                .padding(.leading)
                                        }
                                        
                                    }
                                    Spacer()
                                        .frame(width: proxy.size.width / 4)
                                    
                                    VStack (alignment: .trailing) {
                                        Image(viewModel.blackPlayerProfile)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: proxy.size.width/3.5, height: proxy.size.width/3.5)
                                        Text(viewModel.blackPlayerName)
                                            .font(.title2)
                                            .padding(.trailing)
                                        
                                        
                                        Text(viewModel.blackTitle)
                                            .padding(.trailing)

                                    }
                                }
                                .frame(width: proxy.size.width)
                                Image ("versus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: proxy.size.width/3, height: proxy.size.width/3)
                                    .vibratingShaking(deadline: 4)
                            }
                            
                            Text ("Current Rating")
                                .font(.title2)
                                .padding(.top)
                            if viewModel.chessGame.winner == .white {
                                HStack {
                                    Text ("\(String(CurrentUser.shared.rating))")
                                        .font(.largeTitle)
                                        .bold()
                                    Text ( "+ \(String(CurrentUser.shared.rating - viewModel.chessGame.currentRating))")
                                }
                                
                            } else {
                                Text ("\(String(CurrentUser.shared.rating)) - \(String(CurrentUser.shared.rating - viewModel.chessGame.currentRating))")
                            }
                            
                            VStack (spacing: 10) {
                                Button(action: {
                                    withAnimation {
                                        isShowMenuView.toggle()
                                    }
                                    
                                }) {
                                    Text("Main Menu")
                                        .padding()
                                        .bold()
                                        .foregroundColor(.white)
                                        .frame(width: proxy.size.width/1.5)
                                        .background(Color.green.opacity(0.95))
                                        .cornerRadius(proxy.size.width/40)
                                    
                                    
                                }
                                Button(action: {
                                    withAnimation {
                                        isShowProfileView.toggle()
                                    }
                                }) {
                                    Text("See Profile")
                                    
                                        .padding()
                                        .bold()
                                        .foregroundColor(.white)
                                        .frame(width: proxy.size.width/1.5)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: proxy.size.width/40)
                                                .stroke(Color.blue, lineWidth: 2)
                                        )
                                }
                            }
                            
                            Spacer()
                                .frame(height: proxy.size.width/8)
                        }
                        .frame(width: proxy.size.width / 1.1)
                        .background(Color(red: 0.00, green: 0.09, blue: 0.18)
                            .ignoresSafeArea())
                        .cornerRadius(proxy.size.width / 20)
                    }
                    .foregroundColor(.white)
                }
                
            }
        }
        .onAppear {
            if viewModel.chessGame.outcome == .checkmate {
                if viewModel.chessGame.winner == .white {
                    viewModel.playSound(sound: "gameWin", type: "mp3")
                } else {
                    viewModel.playSound(sound: "gameLoss", type: "mp3")
                }
            } else {
//                viewModel.playSound(sound: "gameDraw", type: "mp3")
            }
        }
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ModalView(viewModel: GameViewModel())
    }
}
