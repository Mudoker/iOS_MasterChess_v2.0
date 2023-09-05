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
 Pinterest. "" pinterest.com https://www.pinterest.com/pin/225672631319564242/ (accessed 11/08/2023)
 Pinterest. "" pinterest.com https://www.pinterest.com/pin/164170348907500351/ (accessed 11/08/2023)
 TeePublic. "Panda by Khatii" pinterest.com https://www.pinterest.com/pin/439663982384708870/ (accessed 11/08/2023)
 Freepik. "Cute cat eat ramen noodle carton" pinterest.com https://www.pinterest.com/pin/622411611024331684/ (accessed 11/08/2023)
 Freepik. "Sol en estilo pixel art" pinterest.com https://www.pinterest.com/pin/662732901469338929/ (accessed 11/08/2023)
 Freepik. "" pinterest.com https://www.pinterest.com/pin/232498399506736782/ (accessed 11/08/2023)
 Shutterstock. "" shutterstock.com https://www.shutterstock.com/image-vector/pixel-art-illustration-gear-icon-pixelated-2286959667 (accessed 11/08/2023)
 */
import SwiftUI

struct SignUpScreen: View {
    // Managing screen states + save to user setting
    @State var currentStep = 1
    @State var selectedProfile = 1
    @State var selectedTheme = 1
    @State var isNavigation = false
    @State var username: String = ""
    @State var password: String = ""
    @State var isValidUsername: Bool = false
    @State var showAlertFalseUsername: Bool = false
    @State var selectedDifficulty = "easy"
    @State var selectedSound = false
    @State var selectedSFX = false
    @State var selectedAP = false
    @State var isSkipRegister = false
    @AppStorage("selectedLanguage") var selectedLanguage = "en" // Localization
    
    // Fetch all users
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Users.username, ascending: true)],
        animation: .default)
    private var users: FetchedResults<Users>
    
    //Responsive
    @State var textFont: Font = .title3
    @State var buttonSizeWidth: CGFloat = 0
    @State var buttonSizeHeight: CGFloat = 0
    @State var alertTitleFont: Font = .title
    @State var alertCloseFont: Font = .title3
    @State var alertSizeWidth: CGFloat = 0
    @State var alertSizeHeight: CGFloat = 0
    @State var alertContent2Font: Font = .body
    @State var alertContentFont: Font = .body
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    // Push the view down if ipad
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        VStack {
                            Text("")
                        }
                        .frame(width: proxy.size.width/2)
                    }
                    
                    // Current page
                    HStack {
                        Text ("Step")
                            .opacity(0.6)
                            .font(textFont)
                        
                        Text ("\(currentStep) of 2")
                            .bold()
                            .font(textFont)
                        
                        // Push to 2 sides
                        Spacer()
                        
                        NavigationLink(destination: LoginView()
                            .navigationBarBackButtonHidden(true)) {
                                // Push to 2 sides
                                // Center
                                Text("Skip")
                                    .font(textFont)
                            }
                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded {
                                        isSkipRegister.toggle()
                                    }
                            )
                        
                    }
                    .padding(.horizontal)
                    
                    // Indicators
                    HStack {
                        Capsule()
                            .foregroundColor(currentStep == 1 ? .green : .gray)
                            .opacity(currentStep == 1 ? 1 : 0.5)
                            .frame(width: proxy.size.width/3, height: proxy.size.width/60)
                        
                        Capsule()
                            .foregroundColor(currentStep == 2 ? .green : .gray)
                            .opacity(currentStep == 2 ? 1 : 0.5)
                            .frame(width: proxy.size.width/3, height: proxy.size.width/60)
                    }
                    .padding(.bottom, proxy.size.width/40)
                    
                    // Render page
                    if (currentStep == 1) {
                        Register1(selectedProfile: $selectedProfile, username: $username, isValidUsername: $isValidUsername, password: $password)
                    } else {
                        Register2(selectedTheme: $selectedTheme, selectedLanguage: $selectedLanguage, selectedDifficulty: $selectedDifficulty, selectedSound: $selectedSound, selectedSFX: $selectedSFX, selectedAP: $selectedAP )
                    }
                    
                    // push to top
                    Spacer()
                    
                    // Continue button
                    Button {
                        // Only allow to next page if username is valid
                        if (isValidUsername) {
                            // If end of step
                            if (currentStep == 2) {
                                // Load data to users setting
                                let setting = Setting(context: viewContext)
                                setting.autoPromotionEnabled = selectedAP
                                setting.isDarkMode = selectedTheme == 1 ? false : true
                                setting.language = selectedLanguage
                                setting.musicEnabled = selectedSound
                                setting.soundEnabled = selectedSFX
                                setting.difficulty = selectedDifficulty
                                setting.isSystemTheme = selectedTheme == 3 ? true : false
                                
                                // Default values
                                let gameStats = GameStats(context: viewContext)
                                let gameHistory = GameHistory(context: viewContext)
                                let gameAchievement = Achievement(context: viewContext)
                                
                                let user = Users(context: viewContext)
                                user.username = username
                                user.userID = UUID()
                                user.userSettings = setting
                                user.joinDate = Date()
                                user.password = password
                                user.profilePicture = selectedProfile == 1 ? "profile1" : selectedProfile == 2 ? "profile2" : selectedProfile == 3 ? "profile3" : "profile4"
                                user.userAchievement?.adding(gameAchievement)
                                user.userHistory?.adding(gameHistory)
                                user.userStats = gameStats
                                user.hasActiveGame = false
                                
                                // All users will have a list of achievement (unlocked = false)
                                let achivement1 = Achievement(context: viewContext)
                                achivement1.category = "Common"
                                achivement1.des = "First time login!"
                                achivement1.points = 20
                                achivement1.progress = 0
                                achivement1.targetProgress = 1
                                achivement1.title = "First Step"
                                achivement1.unlocked = false
                                achivement1.unlockDate = Date()
                                achivement1.id = UUID()
                                achivement1.icon = "firstLogin"
                                
                                let achivement2 = Achievement(context: viewContext)
                                achivement2.category = "Elite"
                                achivement2.des = "Top 1 on the leaderboard!"
                                achivement2.points = 2000
                                achivement2.progress = 0
                                achivement2.targetProgress = 1
                                achivement2.title = "Top 1"
                                achivement2.icon = "rank1"
                                achivement2.unlocked = false
                                achivement2.unlockDate = Date()
                                achivement2.id = UUID()
                                
                                let achivement3 = Achievement(context: viewContext)
                                achivement3.category = "Elite"
                                achivement3.des = "Top 2 on the leaderboard!"
                                achivement3.points = 1500
                                achivement3.progress = 0
                                achivement3.targetProgress = 1
                                achivement3.title = "Top 2"
                                achivement3.icon = "rank2"
                                achivement3.unlocked = false
                                achivement3.unlockDate = Date()
                                achivement3.id = UUID()
                                
                                let achivement4 = Achievement(context: viewContext)
                                achivement4.category = "Elite"
                                achivement4.des = "Top 3 on the leaderboard!"
                                achivement4.points = 1000
                                achivement4.progress = 0
                                achivement4.targetProgress = 1
                                achivement4.title = "Top 3"
                                achivement4.icon = "rank3"
                                achivement4.unlocked = false
                                achivement4.unlockDate = Date()
                                achivement4.id = UUID()
                                
                                let achivement5 = Achievement(context: viewContext)
                                achivement5.category = "Common"
                                achivement5.des = "Play 1 game!"
                                achivement5.points = 10
                                achivement5.progress = 0
                                achivement5.targetProgress = 1
                                achivement5.title = "Get's started"
                                achivement5.icon = "play1"
                                achivement5.unlocked = false
                                achivement5.unlockDate = Date()
                                achivement5.id = UUID()
                                
                                let achivement6 = Achievement(context: viewContext)
                                achivement6.category = "Common"
                                achivement6.des = "Play 5 game!"
                                achivement6.points = 30
                                achivement6.progress = 0
                                achivement6.targetProgress = 5
                                achivement6.title = "Game Lover"
                                achivement6.icon = "play5"
                                achivement6.unlocked = false
                                achivement6.unlockDate = Date()
                                achivement6.id = UUID()
                                
                                let achivement7 = Achievement(context: viewContext)
                                achivement7.category = "Common"
                                achivement7.des = "Play 10 game!"
                                achivement7.points = 150
                                achivement7.progress = 0
                                achivement7.targetProgress = 10
                                achivement7.title = "Friend with AI"
                                achivement7.icon = "play10"
                                achivement7.unlocked = false
                                achivement7.unlockDate = Date()
                                achivement7.id = UUID()
                                
                                let achivement8 = Achievement(context: viewContext)
                                achivement8.category = "Uncommon"
                                achivement8.des = "Play 20 game!"
                                achivement8.points = 250
                                achivement8.progress = 0
                                achivement8.targetProgress = 20
                                achivement8.title = "The Challenger"
                                achivement8.icon = "play20"
                                achivement8.unlocked = false
                                achivement8.unlockDate = Date()
                                achivement8.id = UUID()
                                
                                let achivement9 = Achievement(context: viewContext)
                                achivement9.category = "Rare"
                                achivement9.des = "Play 50 game!"
                                achivement9.points = 150
                                achivement9.progress = 0
                                achivement9.targetProgress = 50
                                achivement9.title = "AI Killer"
                                achivement9.icon = "play50"
                                achivement9.unlocked = false
                                achivement9.unlockDate = Date()
                                achivement9.id = UUID()
                                
                                let achivement10 = Achievement(context: viewContext)
                                achivement10.category = "Common"
                                achivement10.des = "Reach Newbie ranking"
                                achivement10.points = 100
                                achivement10.progress = 0
                                achivement10.targetProgress = 800
                                achivement10.title = "Newbie"
                                achivement10.icon = "newbie"
                                achivement10.unlocked = false
                                achivement10.unlockDate = Date()
                                achivement10.id = UUID()
                                
                                let achivement11 = Achievement(context: viewContext)
                                achivement11.category = "Uncommon"
                                achivement11.des = "Reach Pro ranking"
                                achivement11.points = 500
                                achivement11.progress = 0
                                achivement11.targetProgress = 1300
                                achivement11.title = "Pro Player"
                                achivement11.icon = "pro"
                                achivement11.unlocked = false
                                achivement11.unlockDate = Date()
                                achivement11.id = UUID()
                                
                                let achivement12 = Achievement(context: viewContext)
                                achivement12.category = "Rare"
                                achivement12.des = "Reach Master ranking"
                                achivement12.points = 1000
                                achivement12.progress = 0
                                achivement12.targetProgress = 1600
                                achivement12.title = "Master"
                                achivement12.icon = "master"
                                achivement12.unlocked = false
                                achivement12.unlockDate = Date()
                                achivement12.id = UUID()
                                
                                let achivement13 = Achievement(context: viewContext)
                                achivement13.category = "Rare"
                                achivement13.des = "Reach Grand Master ranking"
                                achivement13.points = 1000
                                achivement13.progress = 0
                                achivement13.targetProgress = 1600
                                achivement13.title = "Grand Master"
                                achivement13.icon = "gmaster"
                                achivement13.unlocked = false
                                achivement13.unlockDate = Date()
                                achivement13.id = UUID()
                                
                                let achivement14 = Achievement(context: viewContext)
                                achivement14.category = "Rare"
                                achivement14.des = "Win in 5 minutes"
                                achivement14.points = 1000
                                achivement14.progress = 0
                                achivement14.targetProgress = 1
                                achivement14.title = "The Flash"
                                achivement14.icon = "winfast"
                                achivement14.unlocked = false
                                achivement14.unlockDate = Date()
                                achivement14.id = UUID()
                                
                                let achivement15 = Achievement(context: viewContext)
                                achivement15.category = "Rare"
                                achivement15.des = "Win in the last 1 minutes"
                                achivement15.points = 1000
                                achivement15.progress = 0
                                achivement15.targetProgress = 1
                                achivement15.title = "Turn the Tables"
                                achivement15.icon = "winlong"
                                achivement15.unlocked = false
                                achivement15.unlockDate = Date()
                                achivement15.id = UUID()
                                
                                user.addToUserAchievement(achivement1)
                                user.addToUserAchievement(achivement2)
                                user.addToUserAchievement(achivement3)
                                user.addToUserAchievement(achivement4)
                                user.addToUserAchievement(achivement5)
                                user.addToUserAchievement(achivement6)
                                user.addToUserAchievement(achivement7)
                                user.addToUserAchievement(achivement8)
                                user.addToUserAchievement(achivement9)
                                user.addToUserAchievement(achivement10)
                                user.addToUserAchievement(achivement11)
                                user.addToUserAchievement(achivement12)
                                user.addToUserAchievement(achivement13)
                                user.addToUserAchievement(achivement14)
                                user.addToUserAchievement(achivement15)
                                
                                try? viewContext.save()
                                isNavigation = true
                            } else {
                                // Next page
                                currentStep += 1
                            }
                        } else {
                            // Invalid name
                            showAlertFalseUsername = true
                        }
                    } label: {
                        HStack {
                            if (currentStep < 2) {
                                Text("Continue")
                                    .font(textFont)
                                    .bold()
                            } else {
                                Text("Sign in")
                                    .font(textFont)
                                    .bold()
                            }
                            
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .frame(width: buttonSizeWidth, height: buttonSizeHeight)
                        .background(.green)
                        .clipShape(
                            RoundedRectangle(cornerRadius: proxy.size.width/30)
                        )
                        .padding(.bottom)
                    }
                    .navigationDestination(
                        isPresented: $isNavigation // trigger the navigation
                    ) {
                        LoginView()
                            .navigationBarBackButtonHidden(true)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.08, green: 0.12, blue: 0.18))
                
                // Custom alert
                if showAlertFalseUsername {
                    Rectangle()
                        .foregroundColor(Color.gray)
                        .frame(width: alertSizeWidth, height: alertSizeHeight)
                        .overlay(
                            VStack (alignment: .center) {
                                Text("System alert")
                                    .font(alertTitleFont)
                                    .bold()
                                    .padding(.top)
                                
                                // Push view
                                Spacer()
                                
                                Text("Invalid username")
                                    .font(alertContentFont)
                                
                                // Push view
                                Spacer()
                                
                                // Line separating sections
                                Divider()
                                
                                // Close button
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        showAlertFalseUsername.toggle()
                                    }
                                } label: {
                                    // Center
                                    HStack {
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
                                .foregroundColor(Color.black)
                        )
                        .cornerRadius(proxy.size.width/30)
                        .padding()
                        .onAppear {
                            showAlertFalseUsername = true
                        }
                }
            }
            .onAppear {
                // Responsive
                if UIDevice.current.userInterfaceIdiom == .phone {
                    buttonSizeWidth = proxy.size.width/1.1
                    buttonSizeHeight = proxy.size.width/6
                    alertTitleFont = .title
                    alertCloseFont = .title3
                    alertSizeWidth = proxy.size.width/1.2
                    alertSizeHeight = proxy.size.width/2.5
                    alertContentFont = .title2
                } else {
                    textFont = .title
                    buttonSizeWidth = proxy.size.width/1.05
                    buttonSizeHeight = proxy.size.width/8
                    alertTitleFont = .largeTitle
                    alertCloseFont = .title
                    alertSizeWidth = proxy.size.width/2.5
                    alertSizeHeight = proxy.size.width/3
                    alertContentFont = .largeTitle
                }
            }
        }
    }
}

struct Register1: View {
    // Manage user selection
    @Binding var selectedProfile: Int
    @Binding var username: String
    @Binding var isValidUsername: Bool
    @Binding var password: String
    @State var isShowPassword: Bool = false
    
    // Fetch users to validate username
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) var users: FetchedResults<Users>
    
    // Responsive
    @State var headerFontSize: CGFloat = 0
    @State var imageSizeWidth: CGFloat = 0
    @State var imageSizeHeight: CGFloat = 0
    @State var inputSizeWidth: CGFloat = 0
    @State var inputSizeHeight: CGFloat = 0
    @State var scaleInputField: CGFloat = 1
    @State var textFieldPaddingLeading: CGFloat = 16
    @State var textFont: Font = .body
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                // Choose Profile picture
                HStack {
                    Text ("Create a profile")
                        .font(.system(size: headerFontSize))
                        .bold()
                    
                    // Push view
                    Spacer()
                }
                
                HStack {
                    ForEach(1...2, id: \.self) { i in
                        Button(action: {
                            selectedProfile = i
                        })
                        {
                            Image("profile\(i)")
                                .resizable()
                                .frame(width: imageSizeWidth, height: imageSizeHeight)
                                .background(
                                    Rectangle()
                                        .foregroundColor(selectedProfile == i ? .green : .gray)
                                        .opacity(selectedProfile == i ? 1 : 0.5)
                                        .cornerRadius(proxy.size.width/30)
                                )
                        }
                    }
                }
                
                // List of picture
                HStack {
                    ForEach(3...4, id: \.self) { i in
                        Button(action: {
                            selectedProfile = i
                        })
                        {
                            Image("profile\(i)")
                                .resizable()
                                .frame(width: imageSizeWidth, height: imageSizeHeight)
                                .background(
                                    Rectangle()
                                        .foregroundColor(selectedProfile == i ? .green : .gray)
                                        .opacity(selectedProfile == i ? 1 : 0.5)
                                        .cornerRadius(proxy.size.width/30)
                                )
                        }
                    }
                }
                
                // Credentials
                VStack(alignment: .leading) {
                    Text("The username should be atleast 5 characters")
                        .opacity(0.5)
                        .font(textFont)
                        .bold()
                    
                    RoundedRectangle(cornerRadius: proxy.size.width/50)
                        .frame(height: inputSizeHeight)
                        .foregroundColor(.white)
                        .overlay(
                            HStack(spacing: 10) {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: proxy.size.width/15, height: proxy.size.width/15)
                                
                                TextField("", text: $username, prompt:  Text("Username or email").foregroundColor(.black.opacity(0.5))
                                )
                                .padding(.leading, textFieldPaddingLeading)
                                .font(.body)
                                .disableAutocorrection(true)
                                .textInputAutocapitalization(.never)
                                .foregroundColor((username.count > 1 && isUsernameValid) ? .black : .red)
                                .scaleEffect(scaleInputField)
                            }
                            .padding(.horizontal)
                        )
                    
                    RoundedRectangle(cornerRadius: proxy.size.width/50)
                        .frame(height: inputSizeHeight)
                        .overlay(
                            HStack {
                                Image(systemName: "lock")
                                    .resizable()
                                    .frame(width: proxy.size.width/15, height: proxy.size.width/15)
                                    .foregroundColor(.gray)
                                
                                // Show or hide password
                                if isShowPassword {
                                    TextField("", text: $password, prompt:  Text("Password").foregroundColor(.black.opacity(0.5))
                                    )
                                    .padding(.leading, textFieldPaddingLeading)
                                    .foregroundColor(.black)
                                    .disableAutocorrection(true)
                                    .textInputAutocapitalization(.never)
                                    .scaleEffect(scaleInputField)
                                } else {
                                    SecureField("", text: $password, prompt:  Text("Password").foregroundColor(.black.opacity(0.5))
                                    )
                                    .padding(.leading, textFieldPaddingLeading)
                                    .foregroundColor(.black)
                                    .disableAutocorrection(true)
                                    .textInputAutocapitalization(.never)
                                    .scaleEffect(scaleInputField)
                                }
                                
                                // Allow show if password has character
                                if password.count > 0 {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            isShowPassword.toggle()
                                        }
                                    })
                                    {
                                        Image(systemName: isShowPassword ?  "eye.fill" : "eye.slash.fill")
                                            .resizable()
                                            .frame(width: proxy.size.width/15, height: proxy.size.width/20)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        )
                }
                .padding(.top, 20)
            }
            .onAppear {
                // Responsive
                if UIDevice.current.userInterfaceIdiom == .phone {
                    headerFontSize = proxy.size.width/14
                    imageSizeWidth = proxy.size.width/2.3
                    imageSizeHeight = proxy.size.width/2.3
                    inputSizeHeight = proxy.size.width/7
                } else {
                    headerFontSize = proxy.size.width/24
                    imageSizeWidth = proxy.size.width/3.5
                    imageSizeHeight = proxy.size.width/3.5
                    inputSizeHeight = proxy.size.width/8
                    scaleInputField = 2
                    textFont = .title
                    textFieldPaddingLeading = proxy.size.width/4.5
                }
            }
            .onChange(of: username) { value in
                // Validate
                isValidUsername = value.count >= 5 && users.filter { $0.username == value }.count == 0
            }
            .onChange(of: isUsernameValid) {
                value in
                isValidUsername = value
            }
            .padding(.horizontal)
        }
    }
    var isUsernameValid: Bool {
        return username.count >= 5 && !users.contains { $0.username == username }
    }
}


struct Register2: View {
    // Manage user selection
    @Binding var selectedTheme: Int
    @Binding var selectedLanguage: String
    @Binding var selectedDifficulty: String
    @Binding var selectedSound:Bool
    @Binding var selectedSFX:Bool
    @Binding var selectedAP:Bool
    
    // Responsive
    @State var headerFontSize: CGFloat = 0
    @State var imageSizeWidth: CGFloat = 0
    @State var imageSizeHeight: CGFloat = 0
    @State var inputSizeWidth: CGFloat = 0
    @State var inputSizeHeight: CGFloat = 0
    @State var scalePicker: CGFloat = 1
    @State var textFieldPaddingLeading: CGFloat = 16
    @State var textFont: Font = .title2
    @State var paddingPicker: CGFloat = 16
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack (alignment: .center) {
                    // Setting theme
                    Text ("Theme preference")
                        .font(textFont)
                        .bold()
                    
                    // Push to middle
                    HStack {
                        // Push view
                        Spacer()
                        
                        ForEach(1...3, id: \.self) { i in
                            Button(action: {
                                selectedTheme = i
                            })
                            {
                                Image("bg\(i)")
                                    .resizable()
                                    .frame(width: imageSizeHeight, height: imageSizeHeight)
                                    .background(
                                        Rectangle()
                                            .foregroundColor(selectedTheme == i ? i == 1 ? .yellow : i == 2 ? .purple : .blue : .gray)
                                            .opacity(selectedTheme == i ? 1 : 0.5)
                                            .cornerRadius(10)
                                    )
                            }
                        }
                        
                        // Push view
                        Spacer()
                    }
                    
                    VStack (alignment: .center) {
                        // Language
                        Text ("Language")
                            .font(textFont)
                            .bold()
                        
                        Picker("Language", selection: $selectedLanguage) {
                            Text("Vietnamese").tag("vi")
                            Text("English").tag("en")
                        }
                        .scaleEffect(scalePicker)
                        .pickerStyle(SegmentedPickerStyle())
                        .preferredColorScheme(.dark)
                        .padding(.horizontal,paddingPicker)
                        
                        // Difficulty
                        Text ("Difficulty")
                            .font(textFont)
                            .bold()
                            .padding(.top)
                        
                        Picker("Difficulty", selection: $selectedDifficulty) {
                            Text("Easy").tag("easy")
                            Text("Normal").tag("normal")
                            Text("Hard").tag("hard")
                        }
                        .scaleEffect(scalePicker)
                        .pickerStyle(SegmentedPickerStyle())
                        .preferredColorScheme(.dark)
                        .padding(.horizontal,paddingPicker)
                        
                        // Background music
                        Text ("Music")
                            .font(textFont)
                            .bold()
                            .padding(.top)
                        
                        Picker("Sound", selection: $selectedSound) {
                            Text("Disabled").tag(false)
                            Text("Enabled").tag(true)
                        }
                        .scaleEffect(scalePicker)
                        .pickerStyle(SegmentedPickerStyle())
                        .preferredColorScheme(.dark)
                        .padding(.horizontal,paddingPicker)
                        
                        // Sound
                        Text ("SFX")
                            .font(textFont)
                            .bold()
                            .padding(.top)
                        
                        Picker("SFX", selection: $selectedSFX) {
                            Text("Disabled").tag(false)
                            Text("Enabled").tag(true)
                        }
                        .scaleEffect(scalePicker)
                        .pickerStyle(SegmentedPickerStyle())
                        .preferredColorScheme(.dark)
                        .padding(.horizontal,paddingPicker)
                        
                        // Auto promotion
                        Text ("Auto Promotion")
                            .bold()
                            .font(textFont)
                            .padding(.top)
                        
                        Picker("Auto promotion", selection: $selectedAP) {
                            Text("Disabled").tag(false)
                            Text("Enabled").tag(true)
                        }
                        .scaleEffect(scalePicker)
                        .pickerStyle(SegmentedPickerStyle())
                        .preferredColorScheme(.dark)
                        .padding(.horizontal,paddingPicker)
                    }
                    
                    // Separating view with button
                    VStack{
                    }
                    .frame(height: proxy.size.width/15)
                }
                .onAppear {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        headerFontSize = proxy.size.width/14
                        imageSizeWidth = proxy.size.width/2.3
                        imageSizeHeight = proxy.size.width/3.4
                    } else {
                        headerFontSize = proxy.size.width/24
                        imageSizeWidth = proxy.size.width/3.5
                        imageSizeHeight = proxy.size.width/3.5
                        inputSizeHeight = proxy.size.width/7
                        scalePicker = 1.5
                        textFont = .largeTitle
                        textFieldPaddingLeading = proxy.size.width/4.5
                        paddingPicker = 200
                    }
                }
            }
        }
    }
}

struct SignUpScreen_Previews: PreviewProvider {
    static var previews: some View {
        SignUpScreen()
    }
}
