/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 11/08/2023
 Last modified: 21/08/2023
 Acknowledgement:
 */

import SwiftUI
struct LoginView: View {
    // Localization
    @AppStorage("selectedLanguage") var selectedLanguage = "vi"
    
    // Load data from CoreData
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch list of users
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Users.username, ascending: true)],
        animation: .default)
    
    // List of users
    private var users: FetchedResults<Users>
    
    // Current index of users
    @AppStorage("userIndex") var userIndex = 0
    
    // Current username of user
    @AppStorage("userName") var username = ""
    
    // Current user instance
    @EnvironmentObject var currentUser: CurrentUser
    
    // App theme
    @AppStorage("theme") var theme = ""
    
    // Store inputs
    @State var accountInput: String = ""
    @State var passwordInput: String = ""
    
    // Hide or show password
    @State var isShowPassword: Bool = false
    
    // Navigate to Menu View
    @State private var isMenuView = false
    
    // Navigate to Sign Up view
    @State private var isRegister = false
    
    // Login status
    @State var loginStatus: String = ""
    
    // Show alert for Login status
    @State var isAlert = false
    
    // Show alert for "Forgot password"
    @State var isShowHint = false
    
    // Responsive
    @State var logoWidth: CGFloat = 0
    @State var logoHeight: CGFloat = 0
    @State var loginFontSize: CGFloat = 0
    @State var credFontSize: Font = .title2
    @State var buttonWidth: CGFloat = 0
    @State var buttonHeight: CGFloat = 0
    @State var buttonPaddingTop: CGFloat = 0
    @State var helperButtonSize: Font = .title
    @State var scaleInputField: CGFloat = 1
    @State var textFieldPaddingLeading: CGFloat = 0
    @State var alertTitleFont: Font = .title
    @State var alertCloseFont: Font = .title3
    @State var alertSizeWidth: CGFloat = 0
    @State var alertSizeHeight: CGFloat = 0
    @State var alertContent2Font: Font = .body
    @State var alertContentFont: Font = .body
    @State var alertLoginSizeWidth: CGFloat = 0
    @State var alertLoginSizeHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Background
                Color(red: 0.08, green: 0.12, blue: 0.18)
                    .edgesIgnoringSafeArea(.all)
                
                // Content
                VStack (alignment: .center) {
                    VStack {
                        // push view
                        VStack{
                        }
                        .frame(height: proxy.size.width/10)
                        
                        Image("AppLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .padding(.bottom)
                            .frame(width: logoWidth,height: logoHeight)
                        
                        Text("𝗟𝗼𝗴𝗶𝗻")
                            .font(.system(size: loginFontSize, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        Text("Please sign in to continue")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                    
                    VStack(alignment: .leading) {
                        // Account
                        Text("Account")
                            .font(credFontSize)
                            .bold()
                            .foregroundColor(.white)
                            .frame(height: proxy.size.width/12)
                        
                        // Input field for account
                        RoundedRectangle(cornerRadius: proxy.size.width/40)
                            .frame(height: proxy.size.width/7)
                            .foregroundColor(.white)
                            .overlay(
                                HStack {
                                    Image(systemName: "person")
                                        .resizable()
                                        .frame(width: proxy.size.width/20, height: proxy.size.width/20)
                                        .padding(.leading, proxy.size.width/30)
                                        .foregroundColor(.gray)
                                    
                                    TextField("", text: $accountInput, prompt:  Text("Username or email").foregroundColor(.black.opacity(0.5))
                                    )
                                    .padding(.leading, textFieldPaddingLeading)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .scaleEffect(scaleInputField)
                                    .foregroundColor(.black)
                                    
                                }
                            )
                            .padding(.bottom)
                        
                        // Password
                        HStack {
                            Text("Password")
                                .foregroundColor(.white)
                                .font(credFontSize)
                                .bold()
                            
                            Text("(Optional)")
                                .opacity(0.7)
                                .font(credFontSize)
                                .foregroundColor(.gray)
                        }
                        .frame(height: proxy.size.width/12)
                        
                        // Password input field
                        RoundedRectangle(cornerRadius: proxy.size.width/40)
                            .frame(height: proxy.size.width/7)
                            .overlay(
                                HStack {
                                    Image(systemName: "lock")
                                        .resizable()
                                        .frame(width: proxy.size.width/20, height: proxy.size.width/20)
                                        .padding(.leading, proxy.size.width/30)
                                        .foregroundColor(.gray)
                                    
                                    // Show/hide password
                                    if isShowPassword {
                                        TextField("Password", text: $passwordInput)
                                            .padding(.leading, textFieldPaddingLeading)
                                            .disableAutocorrection(true)
                                            .textInputAutocapitalization(.never)
                                            .scaleEffect(scaleInputField)
                                            .foregroundColor(.black)
                                    } else {
                                        SecureField("", text: $passwordInput, prompt:  Text("Password").foregroundColor(.black.opacity(0.5))
                                        )
                                        .padding(.leading, textFieldPaddingLeading)
                                        .disableAutocorrection(true)
                                        .textInputAutocapitalization(.never)
                                        .scaleEffect(scaleInputField)
                                        .foregroundColor(.black)
                                    }
                                    
                                    // Only show password if >= 1 character
                                    if passwordInput.count > 0 {
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                isShowPassword.toggle()
                                            }
                                        })
                                        {
                                            Image(systemName: isShowPassword ?  "eye.fill" : "eye.slash.fill")
                                                .resizable()
                                                .frame(width: proxy.size.width/15, height: proxy.size.width/20)
                                                .padding(.trailing, proxy.size.width/40)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                })
                            .foregroundColor(.white)
                        
                        // Push the button down
                        VStack{
                        }
                        .frame(height: buttonPaddingTop)
                        
                        // Center button
                        HStack {
                            // push view
                            Spacer()
                            
                            // Login button
                            Button {
                                for index in users.indices {
                                    // If login successfully
                                    if users[index].username == accountInput && users[index].password == passwordInput {
                                        // Update language setting
                                        users[index].userSettings?.language = selectedLanguage
                                        
                                        // Load data to CurrentUser instance
                                        CurrentUser.shared.settingLanguage = selectedLanguage
                                        CurrentUser.shared.username = users[index].username
                                        CurrentUser.shared.joinDate = users[index].joinDate
                                        CurrentUser.shared.password = users[index].password
                                        CurrentUser.shared.profilePicture = users[index].profilePicture
                                        CurrentUser.shared.ranking = Int(users[index].ranking)
                                        CurrentUser.shared.rating = Int(users[index].rating)
                                        CurrentUser.shared.userID = users[index].userID
                                        CurrentUser.shared.hasActiveGame = users[index].hasActiveGame
                                        CurrentUser.shared.userAchievement = users[index].userAchievement
                                        CurrentUser.shared.userHistory = users[index].userHistory
                                        CurrentUser.shared.username = users[index].username
                                        CurrentUser.shared.joinDate = users[index].joinDate
                                        CurrentUser.shared.password = users[index].password
                                        CurrentUser.shared.profilePicture = users[index].profilePicture
                                        CurrentUser.shared.ranking = Int(users[index].ranking)
                                        CurrentUser.shared.rating = Int(users[index].rating)
                                        CurrentUser.shared.userID = users[index].userID
                                        CurrentUser.shared.hasActiveGame = users[index].hasActiveGame
                                        
                                        // Properties from Setting
                                        CurrentUser.shared.settingAutoPromotionEnabled = users[index].userSettings?.autoPromotionEnabled ?? false
                                        
                                        CurrentUser.shared.settingIsSystemTheme = users[index].userSettings?.isSystemTheme ?? false
                                        
                                        if CurrentUser.shared.settingIsSystemTheme {
                                            theme = "system"
                                        }
                                        
                                        CurrentUser.shared.settingIsDarkMode = users[index].userSettings?.isDarkMode ?? false
                                        
                                        if CurrentUser.shared.settingIsDarkMode {
                                            theme = "dark"
                                        } else {
                                            theme = "light"
                                        }
                                        
                                        CurrentUser.shared.settingLanguage = users[index].userSettings?.language ?? ""
                                        CurrentUser.shared.settingMusicEnabled = users[index].userSettings?.musicEnabled ?? false
                                        CurrentUser.shared.settingSoundEnabled = users[index].userSettings?.soundEnabled ?? false
                                        CurrentUser.shared.settingDifficulty = users[index].userSettings?.difficulty ?? ""
                                        
                                        // Play or turn off background music
                                        if !CurrentUser.shared.settingMusicEnabled {
                                            SoundPlayer.stopBackgroundMusic()
                                        } else {
                                            SoundPlayer.startBackgroundMusic()
                                        }
                                        
                                        // Properties from SavedGame
                                        CurrentUser.shared.savedGameAutoPromotionEnabled = users[index].savedGame?.autoPromotionEnabled ?? false
                                        CurrentUser.shared.savedGameBlackTimeLeft = users[index].savedGame?.blackTimeLeft ?? 0
                                        CurrentUser.shared.savedGameBoardSetup = users[index].savedGame?.boardSetup ?? []
                                        CurrentUser.shared.savedGameHistory = users[index].savedGame?.unwrappedHistory ?? []
                                        CurrentUser.shared.savedGameCapture = users[index].savedGame?.unwrappedCaptures ?? []
                                        CurrentUser.shared.savedGameCurrentPlayer = users[index].savedGame?.currentPlayer ?? ""
                                        CurrentUser.shared.savedGameDifficulty = users[index].savedGame?.difficulty ?? ""
                                        CurrentUser.shared.savedGameMoveAvailable = users[index].savedGame?.moveAvailable ?? 0
                                        CurrentUser.shared.savedGameWhiteTimeLeft = users[index].savedGame?.whiteTimeLeft ?? 0
                                        CurrentUser.shared.savedGameIsWhiteKingMoved = users[index].savedGame?.isWhiteKingMoved ?? false
                                        CurrentUser.shared.savedGameIsBlackKingMoved = users[index].savedGame?.isBlackKingMoved ?? false
                                        CurrentUser.shared.savedGameIsWhiteLeftRookMoved = users[index].savedGame?.isWhiteLeftRookMoved ?? false
                                        CurrentUser.shared.savedGameIsWhiteRightRookMoved = users[index].savedGame?.isWhiteRightRookMoved ?? false
                                        CurrentUser.shared.savedGameIsBlackLeftRookMoved = users[index].savedGame?.isBlackLeftRookMoved ?? false
                                        CurrentUser.shared.savedGameIsBlackRightRookMoved = users[index].savedGame?.isBlackRightRookMoved ?? false
                                        CurrentUser.shared.savedGameKingPosition = users[index].savedGame?.kingPosition ?? 0
                                        
                                        // Set login status
                                        loginStatus = "Login Successfully!"
                                        isMenuView = true
                                        userIndex = index
                                        username = users[index].unwrappedUsername
                                        break
                                    } else {
                                        loginStatus = "Wrong username or password"
                                    }
                                }
                                // Show login status
                                isAlert.toggle()
                            } label: {
                                HStack {
                                    Text("Login")
                                        .bold()
                                        .font(credFontSize)
                                }
                                .foregroundColor(.white)
                                .frame(width: buttonWidth, height: buttonHeight)
                                .background(Color(red: 1.00, green: 0.30, blue: 0.00))
                                .clipShape(Capsule())
                            }
                            .navigationDestination(
                                isPresented: $isMenuView) {
                                    TabBar()
                                        .environment(\.locale, Locale(identifier: CurrentUser.shared.settingLanguage)) // Localization
                                        .navigationBarBackButtonHidden(true)
                                }
                            
                            // push view
                            Spacer()
                        }
                        
                        // 2 buttons
                        HStack {
                            // Forgot password
                            Button {
                                isShowHint = true
                            } label: {
                                // Center
                                HStack {
                                    Spacer()
                                    
                                    Text("Forgot password?")
                                        .font(helperButtonSize)
                                        .bold()
                                        .underline()
                                    
                                    Spacer()
                                }
                                .foregroundColor(Color(red: 1.00, green: 0.30, blue: 0.00))
                            }
                            
                            Text("or")
                                .font(helperButtonSize)
                                .foregroundColor(.white)
                            
                            NavigationLink(destination: SignUpScreen()
                                .navigationBarBackButtonHidden(true)) {
                                    // Push to 2 sides
                                    // Center
                                    HStack {
                                        // Push view
                                        Spacer()
                                        
                                        Text("Create an account")
                                            .font(helperButtonSize)
                                            .bold()
                                            .underline()
                                        
                                        // Push view
                                        Spacer()
                                    }
                                    .foregroundColor(Color(red: 1.00, green: 0.30, blue: 0.00))
                                }
                                .simultaneousGesture(
                                    TapGesture()
                                        .onEnded {
                                            isRegister.toggle()
                                        }
                                )
                        }
                        .padding(.top)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: proxy.size.width)
                    .edgesIgnoringSafeArea(.all)
                    
                    // push view
                    Spacer()
                    
                }
                .padding(.top, 50)
                
                // Custom alert for login status
                if isAlert {
                    Rectangle()
                        .foregroundColor(Color.gray)
                        .frame(width: alertSizeWidth, height: alertLoginSizeHeight)
                        .overlay(
                            VStack (alignment: .center) {
                                Text("System alert")
                                    .font(alertTitleFont)
                                    .bold()
                                    .padding(.top)
                                
                                // push view
                                Spacer()
                                
                                if loginStatus != "Login Successfully!" {
                                    Text("Wrong Username or Password")
                                        .font(alertContentFont)
                                    
                                } else {
                                    Text(LocalizedStringKey(loginStatus))
                                        .font(alertContentFont)
                                        .bold()
                                }
                                
                                // push view
                                Spacer()
                                
                                // Line separating sections
                                Divider()
                                
                                // Close button
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        isAlert.toggle()
                                    }
                                } label: {
                                    // Center
                                    HStack {
                                        Spacer()
                                        
                                        Text("Close")
                                            .font(alertCloseFont)
                                            .foregroundColor(.red)
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.bottom)
                            }
                                .foregroundColor(Color.black)
                        )
                        .cornerRadius(proxy.size.width/30)
                        .padding()
                        .onAppear {
                            isAlert = true
                        }
                }
                
                // Custom alert for forgot password
                if isShowHint {
                    Rectangle()
                        .foregroundColor(Color.gray)
                        .frame(width: alertSizeWidth, height: alertSizeHeight)
                        .overlay(
                            VStack (alignment: .center) {
                                Text("Password Recovery")
                                    .font(alertTitleFont)
                                    .foregroundColor(.black)
                                    .bold()
                                    .padding(.top)
                                
                                // push view
                                Spacer()
                                
                                Text("Contact technical support")
                                    .font(alertContentFont)
                                    .foregroundColor(.black)
                                    .bold()
                                
                                Text("s3927776@rmit.edu.vn")
                                    .font(alertContentFont)
                                    .accentColor(.black)
                                
                                // push view
                                Spacer()
                                
                                // Line separing sections
                                Divider()
                                
                                // Close button
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        isShowHint.toggle()
                                    }
                                } label: {
                                    //Center
                                    HStack {
                                        Spacer()
                                        
                                        Text("Close")
                                            .font(alertCloseFont)
                                            .foregroundColor(.red)
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.bottom)
                            }
                        )
                        .cornerRadius(proxy.size.width/30)
                        .padding()
                        .onAppear {
                            isShowHint = true
                        }
                }
            }
            
            .onAppear {
                // Responsive
                if UIDevice.current.userInterfaceIdiom == .phone {
                    logoWidth = proxy.size.width/1.1
                    logoHeight = proxy.size.width/5
                    loginFontSize = proxy.size.width/10
                    buttonPaddingTop = proxy.size.width/20
                    buttonWidth = proxy.size.width/1.2
                    buttonHeight = proxy.size.width/6
                    helperButtonSize = .body
                    textFieldPaddingLeading = proxy.size.width/40
                    alertTitleFont = .title
                    alertCloseFont = .title3
                    alertSizeWidth = proxy.size.width/1.2
                    alertSizeHeight = proxy.size.width/2.5
                    alertContentFont = .title2
                    alertLoginSizeWidth = alertSizeWidth
                    alertLoginSizeHeight = alertSizeHeight
                } else {
                    logoWidth = proxy.size.width/2
                    logoHeight = proxy.size.width/6
                    loginFontSize = proxy.size.width/15
                    credFontSize = .largeTitle
                    buttonWidth = proxy.size.width/1.1
                    buttonHeight = proxy.size.width/7
                    buttonPaddingTop = proxy.size.width/15
                    helperButtonSize = .title
                    scaleInputField = 2
                    textFieldPaddingLeading = proxy.size.width/4
                    alertTitleFont = .largeTitle
                    alertCloseFont = .title
                    alertSizeWidth = proxy.size.width/1.5
                    alertSizeHeight = proxy.size.width/3
                    alertContentFont = .largeTitle
                    alertLoginSizeWidth = alertSizeWidth
                    alertLoginSizeHeight = proxy.size.width/4
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .environment(\.locale, Locale(identifier: selectedLanguage))
    }
}


struct Login_screen_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(accountInput: "", passwordInput: "", isShowPassword: false, loginStatus: "huhu")
    }
}
