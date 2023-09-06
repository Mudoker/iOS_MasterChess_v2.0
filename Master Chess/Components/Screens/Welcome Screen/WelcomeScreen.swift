/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 09/08/2023
 Last modified: 09/08/2023
 Acknowledgement:
 wallspic. "750x1334 Huawei, Huawei Mate, Huawei Mate 10, Chess, Chessboard Wallpaper for IPhone 6, 6S, 7, 8." wallspic.com https://wallspic.com/image/159249-huawei-huawei_mate-huawei_mate_10-chess-chessboard/750x1334 (accsesed Aug. 09, 2023)
 */

import SwiftUI

struct Welcome_Screen: View {
    // Global variable for localization
    @AppStorage("selectedLanguage") var selectedLanguage = "en"
    
    // Navigate to login view
    @State private var isLogin = false
    
    // Show alert for need help
    @State private var showAlert = false
    
    // username of current user
    @AppStorage("userName") var username = ""
    
    // instance of currentUser
    @EnvironmentObject var currentUser: CurrentUser
    
    // Update and UI and store to selectedLanguage
    @State var language = "en"
    
    // Responsive for Iphone and Ipad
    @State var logoSize: CGFloat = 0.0
    @State var titleFontSize: CGFloat =  0.0
    @State var buttonWidth: CGFloat = 0
    @State var buttonHeight: CGFloat = 0
    @State var fontSubtitle: Font = .title
    @State var needHelpFont: Font = .body
    @State var arrowSize: CGFloat = 0
    @State var languageSelectionScale: CGFloat = 1
    @State var alertTitleFont: Font = .title
    @State var alertCloseFont: Font = .title3
    @State var alertSizeWidth: CGFloat = 0
    @State var alertSizeHeight: CGFloat = 0
    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                ZStack {
                    // Background
                    Image("WelcomeBackground")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                    
                    // Logo
                    VStack {
                        Image("RmitLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: logoSize, height: logoSize)
                        
                        // Push to top
                        Spacer()
                    }
                    
                    // Content
                    VStack {
                        // Push to bottom
                        Spacer()
                        
                        // Push to left
                        HStack {
                            Text("𝐌𝐚𝐬𝐭𝐞𝐫 𝐂𝐡𝐞𝐬𝐬")
                                .font(.system(size: titleFontSize))
                                .bold()
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Push to left
                        HStack {
                            Text("Master Your Mind, Master Your Moves")
                                .font(fontSubtitle)
                                .bold()
                                .opacity(0.7)
                            
                            // Push view
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        NavigationLink(destination: LoginView().navigationBarHidden(true)) {
                            // Push to 2 sides
                            HStack {
                                Text("Let's explore")
                                    .font(needHelpFont)
                                
                                // Push view
                                Spacer()
                                
                                Image(systemName: "arrow.up.forward")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: arrowSize)
                                
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .padding(.horizontal)
                            .frame(width: buttonWidth, height: buttonHeight)
                            .background(.white)
                            .clipShape(Capsule())
                            .padding(.bottom)
                        }
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded {
                                    isLogin = true
                                }
                        )
                        
                        // Push to 2 sides
                        HStack (alignment: .firstTextBaseline) {
                            // Show modal for need help
                            Button {
                                showAlert.toggle()
                            } label: {
                                Text("Need help?")
                                    .font(needHelpFont)
                            }
                            
                            // Push view
                            Spacer()
                            
                            // Picker for localization
                            Picker(selection: $language, label: Text("Select Language")) {
                                // 2 options for languages
                                Text("English")
                                    .tag("en")
                                
                                
                                Text("Vietnamese")
                                    .tag("vi")
                            }
                            .scaleEffect(languageSelectionScale) // Scaling for Ipad view
                            .padding(.bottom)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 16) // Only padding for ipad
                    .padding(.bottom)
                    .padding(.bottom)
                    .foregroundColor(.white)
                    
                    // Show alert view
                    if showAlert {
                        Rectangle()
                            .foregroundColor(Color.white)
                            .frame(width: alertSizeWidth, height: alertSizeHeight)
                            .overlay(
                                VStack (alignment: .center) {
                                    Text("Technical Support")
                                        .font(alertTitleFont)
                                        .foregroundColor(.black)
                                        .bold()
                                        .padding(.top)
                                    
                                    // Push view
                                    Spacer()
                                    
                                    Text("Please contact: s3927776@rmit.edu.vn")
                                        .foregroundColor(.black)
                                        .font(needHelpFont)
                                    
                                    // Push view
                                    Spacer()
                                    
                                    // Line separator
                                    Divider()
                                    
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            showAlert.toggle()
                                        }
                                    }
                                label: {
                                    HStack {
                                        // Push view
                                        Spacer()
                                        
                                        Text("Close")
                                            .font(alertCloseFont)
                                            .foregroundColor(.red)
                                        
                                        // Push view
                                        Spacer()
                                    }
                                }
                                .padding(.bottom)
                                }
                            )
                            .cornerRadius(proxy.size.width/30)
                            .padding()
                    }
                }
                .frame(height: proxy.size.height)
                .onChange(of: language) { newValue in
                    selectedLanguage = newValue
                }
                .onAppear {
                    // Localization
                    language = selectedLanguage
                    
                    // Asign value according to device type
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        logoSize = proxy.size.width/2
                        titleFontSize = proxy.size.width/8
                        buttonWidth = proxy.size.width/1.1
                        buttonHeight = proxy.size.width/6
                        fontSubtitle = .title3
                        needHelpFont = .body
                        arrowSize = proxy.size.width/25
                        languageSelectionScale = 1
                        alertTitleFont = .title
                        alertCloseFont = .title3
                        alertSizeWidth = proxy.size.width/1.2
                        alertSizeHeight = proxy.size.width/2.5
                    } else {
                        logoSize = proxy.size.width/3
                        titleFontSize = proxy.size.width/12
                        buttonWidth = proxy.size.width/1.05
                        buttonHeight = proxy.size.width/10
                        fontSubtitle = .largeTitle
                        needHelpFont = .largeTitle
                        arrowSize = proxy.size.width/28
                        languageSelectionScale = 1.7
                        alertTitleFont = .largeTitle
                        alertCloseFont = .title
                        alertSizeWidth = proxy.size.width/2
                        alertSizeHeight = proxy.size.width/3
                    }
                }
            }
        }
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.all)
        .environment(\.locale, Locale(identifier: selectedLanguage)) // Localization
    }
}

struct Welcome_Screen_Previews: PreviewProvider {
    static var previews: some View {
        Welcome_Screen()
    }
}
