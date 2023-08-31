//
//  LeaderBoard.swift
//  Master Chess
//
//  Created by quoc on 30/08/2023.
//

import SwiftUI

struct LeaderBoard: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Users.username, ascending: true)], animation: .default) private var users: FetchedResults<Users>
    @EnvironmentObject var currentUserr: CurrentUser
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                
                VStack {
                    ZStack {
                        HStack {
                            Spacer()
                            VStack {
                                Image("first")
                                    .resizable()
                                    .frame(width: proxy.size.width/5, height: proxy.size.width/5)
                                Circle()
                                    .fill(Color(red: 0.47, green: 0.87, blue: 0.47))
                                    .frame(width: proxy.size.width/3.5)
                                    .overlay(
                                        Image("profile1")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: proxy.size.width/4)
                                    )
                                Text("Mudoker")
                                    .font(.title2)
                                Text("2680")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.yellow)
                                
                                
                            }
                            Spacer()
                        }
                        
                        
                        HStack {
                            VStack {
                                Image("second")
                                    .resizable()
                                    .frame(width: proxy.size.width/5.5, height: proxy.size.width/5.5)
                                Circle()
                                    .fill(.gray)
                                    .frame(width: proxy.size.width/4)
                                    .overlay(
                                        Image("profile2")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: proxy.size.width/4)
                                    )
                                Text("Mudoker")
                                    .font(.title3)
                                Text("2620")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            VStack {
                                Image("third")
                                    .resizable()
                                    .frame(width: proxy.size.width/5.5, height: proxy.size.width/5.5)
                                Circle()
                                    .fill(.brown)
                                    .frame(width: proxy.size.width/4)
                                    .overlay(
                                        Image("profile3")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: proxy.size.width/4)
                                    )
                                Text("Mudoker")
                                    .font(.title3)
                                
                                Text("2560")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.brown)
                            }
                        }
                        .padding(.top, proxy.size.width / 3)
                        
                    }
                    .padding(.horizontal)
                    
                    
                    ScrollView {
                        ForEach(3..<10) { index in
                            HStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: proxy.size.width / CGFloat(10))
                                    .overlay(
                                        Text("\(index + 1)")
                                            .font(.title3)
                                            .bold()
                                            .foregroundColor(.black)
                                    )
                                
                                Image("profile1")
                                    .resizable()
                                    .frame(width: proxy.size.width / 6, height: proxy.size.width / 6)
                                
                                Text("Player \(index + 1)")
                                    .font(.title2)
                                
                                Spacer()
                                
                                Text("2560")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.brown)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                            .padding(.horizontal)
                        }
                    }
                }
                
                
            }
            .foregroundColor(.white)
            .background(Color(red: 0.00, green: 0.09, blue: 0.18))
        }
        
        .navigationTitle("Leaderboard")
    }
}

struct LeaderBoard_Previews: PreviewProvider {
    static var previews: some View {
        LeaderBoard()
    }
}
