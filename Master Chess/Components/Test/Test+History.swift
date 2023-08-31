//
//  Test+History.swift
//  Master Chess
//
//  Created by quoc on 31/08/2023.
//

import SwiftUI

struct Test_History: View {
    var body: some View {
        GeometryReader { proxy in
            Capsule()
                .fill(.gray.opacity(0.3))
                .frame(width: proxy.size.width/1.2,height: proxy.size.width/5)
                .overlay(
                    HStack {
                        Text("31/08/2023")
                            .font(.callout)
                            .bold()
                        Spacer()
                        
                        Image("mitten")
                            .resizable()
                            .frame(width: proxy.size.width / 10, height: proxy.size.width / 12)
                            .background(
                                Circle()
                                    .foregroundColor(.white)
                            )
                        
                        
                        VStack(alignment: .leading) {
                            Text("Mitten")
                                .bold()
                            Text("Easy")
                        }
                        
                        Spacer()
                        VStack {
                            Text("Win")
                                .font(.title2)
                                .foregroundColor(.green)
                                .bold()
                            
                            Text("+275")
                                .bold()
                                .opacity(0.7)
                                .foregroundColor(.green)
                        }
                        
                    }
                        .padding(.horizontal)
                )
        }
    }
}

struct Test_History_Previews: PreviewProvider {
    static var previews: some View {
        Test_History()
    }
}
