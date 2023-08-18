//
//  Onboarding Screen.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 09/08/2023.
//

import SwiftUI

struct Welcome_Screen: View {
    // Show login screen
    @State var isLogin = false
    
    // Show help panel
    @State var showAlert = false
    @AppStorage("userName") var username = ""
    @EnvironmentObject var currentUser: CurrentUser

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Image("WelcomeBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width)
                
                VStack {
                    Image("RmitLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    .frame(width:150, height: 150)
                    
                    Spacer()
                }
                VStack {
                    Spacer()
                    HStack {
                        Text("𝐌𝐚𝐬𝐭𝐞𝐫 𝐂𝐡𝐞𝐬𝐬")
                            .font(.system(size: 50))
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 5)
                    HStack {
                        Text("Master Your Mind, Master Your Moves")
                            .font(.title3)
                            .bold()
                            .opacity(0.7)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                    
                    Button {
                        isLogin = true
                    } label: {
                        HStack {
                            Text("Let's explore")
                            
                            // Spacer is used for positioning items
                            Spacer()
                            
                            Image(systemName: "arrow.up.forward")
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 25)
                        .frame(width: 340, height: 70)
                        .background(.white)
                        .clipShape(Capsule())
                        .padding(.bottom)
                    }
                    .navigationDestination(
                        isPresented: $isLogin // trigger the navigation
                    ) {
//                        if username != "" {
//                            TabBar()
//                                .navigationBarBackButtonHidden(true)
//                        } else {
                            LoginView()
                                .environmentObject(currentUser)
                                .navigationBarBackButtonHidden(true)
//                        }
                    }
                    
                    Button {
                        showAlert.toggle()
                    } label: {
                        Text("Need help?")
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Technical Support"),
                            message: Text("Please contact: s3927776@rmit.edu.vn"),
                            dismissButton: .default(Text("Close"))
                        )
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 40)
                .foregroundColor(.white)
            }
            .ignoresSafeArea()
        }
    }
}

struct Welcome_Screen_Previews: PreviewProvider {
    static var previews: some View {
        Welcome_Screen()
    }
}
