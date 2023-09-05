/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 03/09/2023
 Last modified: 03/09/2023
 Acknowledgement:
 */

import SwiftUI

// Test leaderboard with fixed values
struct Test_LeaderBoard: View {
    // Control state
    @State private var isProfileViewActive = false
    @State private var selectedUser: Users?
    @State private var profileViewShown = false
    
    // Custom back buttom
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // Theme
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("theme") var theme = ""
    @State var lightBackground = Color(red: 0.70, green: 0.90, blue: 0.90)
    @State var darkBackground = Color(red: 0.00, green: 0.09, blue: 0.18)
    
    //Responsive
    @State var imageSizeWidth: CGFloat = 0
    @State var imageSizeHeight: CGFloat = 0
    @State var imageBackgroundSize: CGFloat = 0
    @State var scaleUpSize:CGFloat = 1.1
    @State var scaleDownSize:CGFloat = 0.9
    @State var usernameFont: Font = .title2
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "arrow.left.circle.fill")
                    .imageScale(.large)
                Text("Go Back")
            }
            .padding()
            .foregroundColor(.blue)
        }
    }
    var body: some View {
        GeometryReader { proxy in
            VStack {
                // Responsive
                if UIDevice.current.userInterfaceIdiom == .phone {
                    Spacer()
                        .frame(height: proxy.size.width/6)
                } else {
                    Spacer()
                        .frame(height: proxy.size.width/12)
                }
                
                ZStack {
                    HStack {
                        // Push view
                        Spacer()
                        
                        NavigationLink(
                            destination: ProfileView(currentUser: Users())
                        ) {
                            VStack {
                                Image("first")
                                    .resizable()
                                    .frame(width: imageSizeWidth, height: imageSizeHeight)
                                
                                Circle()
                                    .fill(Color(red: 0.47, green: 0.87, blue: 0.47))
                                    .scaleEffect(scaleUpSize)
                                    .frame(width: imageBackgroundSize)
                                    .overlay(
                                        Image("profile1")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: proxy.size.width/4)
                                            .scaleEffect(scaleUpSize)
                                    )
                                
                                Text("Test1")
                                    .font(usernameFont)
                                
                                Text(String(1000))
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.yellow)
                            }
                        }
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded {
                                    isProfileViewActive = true
                                }
                        )
                        
                        // Push view
                        Spacer()
                    }
                    
                    HStack {
                        NavigationLink(
                            destination: ProfileView(currentUser: Users())
                        ) {
                            VStack {
                                Image("first")
                                    .resizable()
                                    .frame(width: imageSizeWidth, height: imageSizeHeight)
                                
                                Circle()
                                    .fill(Color(red: 0.47, green: 0.87, blue: 0.47))
                                    .frame(width: imageBackgroundSize)
                                    .scaleEffect(scaleDownSize)
                                    .overlay(
                                        Image("profile1")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: proxy.size.width/4)
                                            .scaleEffect(scaleDownSize)
                                        
                                    )
                                
                                Text("Test1")
                                    .font(.title2)
                                
                                Text(String(1000))
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.yellow)
                            }
                        }
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded {
                                    isProfileViewActive = true
                                }
                        )
                        
                        // Push view
                        Spacer()
                        
                        NavigationLink(
                            destination: ProfileView(currentUser: Users())
                        ) {
                            VStack {
                                Image("first")
                                    .resizable()
                                    .frame(width: imageSizeWidth, height: imageSizeHeight)
                                    .scaleEffect(scaleDownSize)
                                
                                Circle()
                                    .fill(Color(red: 0.47, green: 0.87, blue: 0.47))
                                    .frame(width: imageBackgroundSize)
                                    .overlay(
                                        Image("profile1")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: proxy.size.width/4)
                                            .scaleEffect(scaleDownSize)
                                        
                                    )
                                
                                Text("Test1")
                                    .font(.title2)
                                
                                Text(String(1000))
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.yellow)
                            }
                        }
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded {
                                    isProfileViewActive = true
                                }
                        )
                    }
                    .padding(.top, proxy.size.width / 6)
                }
                .padding(.horizontal)
                
                ScrollView {
                    ForEach(1...3, id: \.self) { index in
                        NavigationLink(destination: ProfileView(currentUser: Users())) {
                            HStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: imageBackgroundSize/4)
                                    .overlay(
                                        Text("\(index)")
                                            .font(.title3)
                                            .bold()
                                            .foregroundColor(.black)
                                    )
                                
                                Image("profile2")
                                    .resizable()
                                    .frame(width: imageSizeWidth, height: imageSizeHeight)
                                
                                Text("teste")
                                    .font(.title2)
                                
                                // Push view
                                Spacer()
                                
                                Text(String(100))
                                    .font(.title3)
                                    .bold()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                            .padding(.horizontal)
                        }
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded {
                                    isProfileViewActive = true
                                }
                        )
                    }
                }
            }
            .onAppear {
                // Responsive
                if UIDevice.current.userInterfaceIdiom == .phone {
                    imageSizeWidth = proxy.size.width/5
                    imageSizeHeight = proxy.size.width/5
                    imageBackgroundSize = proxy.size.width/3.5
                } else {
                    imageSizeWidth = proxy.size.width/5.5
                    imageSizeHeight = proxy.size.width/5.5
                    imageBackgroundSize = proxy.size.width/4
                    scaleUpSize = 1
                    scaleDownSize = 1.1
                    usernameFont = .title
                }
            }
            .edgesIgnoringSafeArea(.all)
            // Theme
            .background(theme == "system" ? colorScheme == .dark ? darkBackground : lightBackground : theme == "light" ? lightBackground : darkBackground)
            .foregroundColor(theme == "system" ? colorScheme == .dark ? .white : Color.black : theme == "light" ? Color.black : Color.white)
            .preferredColorScheme(theme == "system" ? .init(colorScheme) : theme == "light" ? .light : .dark)
            
        }
        .navigationBarBackButtonHidden(true) // Hide the back button
        .navigationBarItems(leading: backButton) // Place the custom back button in the top-left corner
        .environment(\.locale, Locale(identifier: CurrentUser.shared.settingLanguage)) // Localization
    }
}

struct Test_LeaderBoard_Previews: PreviewProvider {
    static var previews: some View {
        Test_LeaderBoard()
    }
}
