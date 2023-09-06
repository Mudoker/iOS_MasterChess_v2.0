/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 30/08/2023
 Last modified: 03/09/2023
 Acknowledgement:
 */

import SwiftUI

struct SettingView: View {
    // Get list of users
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Users.username, ascending: true)], animation: .default) private var users: FetchedResults<Users>
    var currentUserr = CurrentUser.shared
    
    // Log out
    @State var isConfirmLogOut: Bool = false
    @State var isLogOut: Bool = false
    
    // Setting change
    @State private var newPassword = ""
    @State private var newUsername = ""
    @State private var selectedSound = false
    @State private var selectedSFX = false
    @State private var selectedAP = false
    @State private var selectedTheme = "Dark"
    @State private var selectedLanguage = "en"
    @State private var isConfirmButtonEnabled = false
    @State private var isChangesMade = false
    @State var selectedDifficulty = "easy"
    @State private var isUsernameTakenAlertPresented = false
    @State var isShowProfile = false
    @State var isValidUsername = false
    @State var isBackgroundMusic = false
    @State var isActiveGame = false
    @State var isShowAlert = false
    // Theme
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("theme") var theme = ""
    @State var lightBackground = Color(red: 0.70, green: 0.90, blue: 0.90)
    @State var darkBackground = Color(red: 0.00, green: 0.09, blue: 0.18)
    @State var buttonSizeHeight: CGFloat = 0
    
    // Localization
    @AppStorage("selectedLanguage") var localization = "vi"

    // Find user
    @AppStorage("userName") var username = "Mudoker"

    // Function to convert date to string
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM / dd / yyyy"
        return dateFormatter.string(from: date)
    }
    
    // control sate
    private func updateConfirmButtonState() {
        isConfirmButtonEnabled = isChangesMade
    }
    
    // get user
    func getUserWithUsername(_ username: String) -> Users? {
        return users.first { $0.username == username }
    }
    
    //Responsive
    @State var viewTitleFontSize: CGFloat = 35
    @State var profileBackgroundSize: CGFloat = 0
    @State var profileImageSizeHeight: CGFloat = 0
    @State var profileImageSizeWidth: CGFloat = 0
    @State var profileNameFont: Font = .title
    @State var profileTitleFont: Font = .body
    @State var navigationImageSizeHeight: CGFloat = 0
    @State var navigationImageSizeWidth: CGFloat = 0
    @State var profileFrameSizeHeight: CGFloat = 0
    @State var scaleSettingField: CGFloat = 1
    @State var textFieldPadding: CGFloat = 0
    @State var settingTitleFont: Font = .title3
    @State var buttonConfirmFont: Font = .body
    @State var buttonSignOutFont: Font = .title3
    
    var body: some View {
        GeometryReader { proxy in
            // get user
            let currentUser = getUserWithUsername(username)
            
            VStack (alignment: .center) {
                // Push view
                if UIDevice.current.userInterfaceIdiom == .pad {
                    VStack{
                    }
                    .frame(height: proxy.size.width/18)
                }
                
                HStack {
                    Text("Settings")
                        .font(.system(size: viewTitleFontSize))
                        .bold()
                        .padding(.horizontal)
                    
                    // push view
                    Spacer()
                }
                
                ScrollView(showsIndicators: false) {
                    // press will navigate to profile view
                    NavigationLink(destination: ProfileView(currentUser: currentUser ?? Users())
                    ) {
                        // Content
                        HStack {
                            Circle()
                                .fill(theme == "system" ? (colorScheme == .dark ? .gray.opacity(0.4) : .black.opacity(0.4)) : (theme == "light" ? .black.opacity(0.4) : .gray.opacity(0.4)))
                                .frame(width: profileBackgroundSize)
                                .overlay(
                                    Image(currentUser?.unwrappedProfilePicture ?? "profile1")
                                        .resizable()
                                        .frame(width: profileImageSizeWidth, height: profileImageSizeHeight)
                                )
                                .padding(.trailing)
                            
                            VStack (alignment: .leading) {
                                Text(currentUser?.unwrappedUsername ?? "Mudoker")
                                    .font(profileNameFont)
                                    .bold()
                                
                                if currentUser?.rating ?? 2000 < 1000 {
                                    Text("Newbie")
                                        .font(profileTitleFont)
                                } else if currentUser?.rating ?? 2000 < 1300 {
                                    Text("Pro")
                                        .font(profileTitleFont)
                                } else if currentUser?.rating ?? 2000 < 1600 {
                                    Text("Master")
                                        .font(profileTitleFont)
                                } else {
                                    Text("Grand Master")
                                        .font(profileTitleFont)
                                }
                            }
                            
                            // Push view
                            Spacer()
                            
                            Image(systemName: "arrow.forward.square")
                                .resizable()
                                .frame(width: navigationImageSizeWidth, height: navigationImageSizeHeight)
                        }
                        .padding(.horizontal)
                        .frame(height: profileFrameSizeHeight)
                        .background(.gray.opacity(0.2))
                        .padding(.bottom)
                    }
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded {
                                isShowProfile = true
                            }
                    )
                    
                    // Update infor
                    VStack(spacing: 20) {
                        VStack {
                            TextField("", text: $newPassword, prompt:  Text("New Password").foregroundColor(.gray)
                            )
                            .padding()
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .onChange(of: newPassword) { _ in
                                if isActiveGame {
                                    isShowAlert = true
                                    newPassword = ""
                                } else {
                                    isChangesMade = true
                                    updateConfirmButtonState()
                                }
                            }
                            .scaleEffect(scaleSettingField)
                            .padding(.leading, textFieldPadding)
                        }
                        .padding(.vertical)
                        .frame(width: proxy.size.width)
                        .background(.gray.opacity(0.2))
                        
                        // Setting
                        VStack (spacing: 0) {
                            Toggle("Auto Promotion Enabled", isOn: $selectedAP)
                                .padding()
                                .onChange(of: selectedAP) { _ in
                                    if isActiveGame {
                                        isShowAlert = true
                                        let autoPromotionEnabled = currentUser?.unwrappedUserSetting.unwrappedAutoPromotionEnabled ?? false
                                        selectedAP = autoPromotionEnabled
                                    } else {
                                        isChangesMade = true
                                        updateConfirmButtonState()
                                    }
                                }
                                .onAppear {
                                    let autoPromotionEnabled = currentUser?.unwrappedUserSetting.unwrappedAutoPromotionEnabled ?? false
                                    selectedAP = autoPromotionEnabled
                                }
                                .padding(.horizontal, textFieldPadding/1.35)
                                .scaleEffect(scaleSettingField)

                            // Line separator
                            Divider()
                            
                            Toggle("Music Enabled", isOn: $selectedSound)
                                .padding()
                                .onChange(of: selectedSound) { _ in
                                    if isActiveGame {
                                        isShowAlert = true
                                        let isMusicOn = currentUser?.unwrappedUserSetting.unwrappedMusicEnabled ?? false
                                        selectedSound = isMusicOn
                                    } else {
                                        isChangesMade = true
                                        isBackgroundMusic = true
                                        updateConfirmButtonState()
                                    }
                                }
                                .onAppear {
                                    let isMusicOn = currentUser?.unwrappedUserSetting.unwrappedMusicEnabled ?? false
                                    selectedSound = isMusicOn
                                }
                                .padding(.horizontal, textFieldPadding/1.35)
                                .scaleEffect(scaleSettingField)
                            
                            // Line separator
                            Divider()
                            
                            Toggle("Sound Enabled", isOn: $selectedSFX)
                                .padding()
                                .onChange(of: selectedSFX) { _ in
                                    if isActiveGame {
                                        isShowAlert = true
                                        let isSoundOn = currentUser?.unwrappedUserSetting.unwrappedSoundEnabled ?? false
                                        selectedSFX = isSoundOn
                                    } else {
                                        isChangesMade = true
                                        updateConfirmButtonState()
                                    }
                                }
                                .onAppear {
                                    let isSoundOn = currentUser?.unwrappedUserSetting.unwrappedSoundEnabled ?? false
                                    selectedSFX = isSoundOn
                                }
                                .padding(.horizontal, textFieldPadding/1.35)
                                .scaleEffect(scaleSettingField)
                        }
                        .background(.gray.opacity(0.2))
                        
                        VStack {
                            Text("Theme")
                                .font(settingTitleFont)
                                .padding(.top)
                            if selectedTheme == "system" {
                                Text("Ensure system theme has been updated!")
                                    .opacity(0.7)
                                    .font(profileTitleFont)
                                    .italic()
                            }

                            Picker("Theme", selection: $selectedTheme) {
                                Text("Light").tag("light")
                                Text("Dark").tag("dark")
                                Text("System").tag("system")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .preferredColorScheme(.dark)
                            .padding(.horizontal, textFieldPadding/1.35)
                            .scaleEffect(scaleSettingField)
                            .onAppear {
                                let isSystem = currentUser?.unwrappedUserSetting.isSystemTheme ?? false
                                
                                if isSystem {
                                    selectedTheme = "system"
                                } else {
                                    let theme = currentUser?.unwrappedUserSetting.isDarkMode
                                    selectedTheme = theme == true ? "dark" : "light"
                                }
                            }
                            .onChange(of: selectedTheme) { _ in
                                if isActiveGame {
                                    isShowAlert = true
                                    let isSystem = currentUser?.unwrappedUserSetting.isSystemTheme ?? false
                                    
                                    if isSystem {
                                        selectedTheme = "system"
                                    } else {
                                        let theme = currentUser?.unwrappedUserSetting.isDarkMode
                                        selectedTheme = theme == true ? "dark" : "light"
                                    }
                                } else {
                                    isChangesMade = true
                                    updateConfirmButtonState()
                                }
                            }
                            .padding([.bottom, .horizontal])
                            
                            Text("Language")
                                .font(settingTitleFont)
                                .padding(.top)
                            
                            Picker("Language", selection: $selectedLanguage) {
                                Text("English").tag("en")
                                Text("Vietnamese").tag("vi")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .preferredColorScheme(.dark)
                            .padding(.horizontal, textFieldPadding/1.35)
                            .scaleEffect(scaleSettingField)
                            .onAppear {
                                let language = currentUser?.unwrappedUserSetting.unwrappedLanguage ?? "en"
                                selectedLanguage = language
                            }
                            .onChange(of: selectedLanguage) { _ in
                                if isActiveGame {
                                    isShowAlert = true
                                    let language = currentUser?.unwrappedUserSetting.unwrappedLanguage ?? "en"
                                    selectedLanguage = language
                                } else {
                                    isChangesMade = true
                                    updateConfirmButtonState()
                                }
                            }
                            .padding([.bottom, .horizontal])
                            
                            VStack{
                                Text("Difficulty")
                                    .padding(.top)
                                    .font(settingTitleFont)
                                if !(currentUser?.hasActiveGame ?? false) {
                                    if selectedDifficulty == "easy" {
                                        Text("The AI will plan at most 2 moves ahead")
                                            .opacity(0.7)
                                            .font(profileTitleFont)
                                            .italic()
                                    } else if selectedDifficulty == "normal" {
                                        Text("The AI will plan at most 3 moves ahead")
                                            .opacity(0.7)
                                            .font(profileTitleFont)
                                            .italic()
                                    } else {
                                        Text("The AI will always plan 3 moves ahead")
                                            .opacity(0.7)
                                            .font(profileTitleFont)
                                            .italic()
                                    }
                                } else {
                                    Text("Please finish your game first!")
                                        .opacity(0.7)
                                        .font(profileTitleFont)
                                        .italic()
                                }
                            }
                            
                            Picker("Difficulty", selection: $selectedDifficulty) {
                                Text("Easy").tag("easy")
                                Text("Normal").tag("normal")
                                Text("Hard").tag("hard")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .preferredColorScheme(.dark)
                            .padding(.horizontal, textFieldPadding/1.35)
                            .scaleEffect(scaleSettingField)
                            .onAppear {
                                let difficulty = currentUser?.unwrappedUserSetting.unwrappedDifficulty ?? "easy"
                                selectedDifficulty = difficulty
                            }
                            .onChange(of: selectedDifficulty) { _ in
                                if isActiveGame {
                                    isShowAlert = true
                                    let difficulty = currentUser?.unwrappedUserSetting.unwrappedDifficulty ?? "easy"
                                    selectedDifficulty = difficulty
                                } else {
                                    isChangesMade = true
                                    updateConfirmButtonState()
                                }
                            }
                            .padding([.bottom, .horizontal])
                        }
                        .background(.gray.opacity(0.2))
                        
                        // Confirm button
                        VStack {
                            Button {
                                if !isActiveGame {
                                    if newPassword != "" {
                                        currentUser?.password = newPassword
                                        newPassword = ""
                                    }
                                    
                                    localization = selectedLanguage
                                    
                                    // Core Data
                                    currentUser?.userSettings?.autoPromotionEnabled = selectedAP
                                    currentUser?.userSettings?.isSystemTheme = selectedTheme == "system" ? true : false
                                    currentUser?.userSettings?.isDarkMode = selectedTheme == "light" ? false : true
                                    currentUser?.userSettings?.soundEnabled = selectedSFX
                                    currentUser?.userSettings?.musicEnabled = selectedSound
                                    currentUser?.userSettings?.difficulty = selectedDifficulty
                                    currentUser?.userSettings?.language = selectedLanguage
                                    
                                    theme = selectedTheme
                                    
                                    // CurrentUser stores setting
                                    currentUserr.settingAutoPromotionEnabled = selectedAP
                                    
                                    currentUserr.settingIsSystemTheme = selectedTheme == "system" ? true : false
                                    
                                    currentUserr.settingIsDarkMode = selectedTheme == "light" ? false : true
                                    
                                    currentUserr.settingSoundEnabled = selectedSFX
                                    currentUserr.settingMusicEnabled = selectedSound
                                    currentUserr.settingDifficulty = selectedDifficulty
                                    
                                    currentUserr.settingLanguage = selectedLanguage
                                    
                                    if isBackgroundMusic {
                                        // Background music
                                        if !selectedSound {
                                            SoundPlayer.stopBackgroundMusic()
                                        } else {
                                            SoundPlayer.startBackgroundMusic()
                                        }
                                    }
                                    
                                    // Save
                                    try? viewContext.save()

                                    // Update state
                                    isConfirmButtonEnabled = false
                                    isChangesMade = false
                                    isBackgroundMusic = false
                                }
                            } label: {
                                Text("Confirm Change")
                                    .font(buttonConfirmFont)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: proxy.size.height/28)
                            .padding()
                            .background(isConfirmButtonEnabled ? Color.blue : Color.gray)
                            .font(.headline)
                            .cornerRadius(10)
                            .disabled(!isConfirmButtonEnabled)
                            .alert(isPresented: $isUsernameTakenAlertPresented) {
                                Alert(
                                    title: Text("Username Taken"),
                                    message: Text("The selected username is already taken. Please choose a different username."),
                                    dismissButton: .default(Text("OK"))
                                )
                            }

                            // Log out
                            Button {
                                isLogOut = true
                            } label: {
                                ZStack {
                                    Text("Sign out")
                                        .foregroundColor(.red)
                                        .bold()
                                        .font(buttonSignOutFont)
                                }
                            }
                            .navigationDestination(isPresented: $isLogOut) {
                                LoginView()
                                    .navigationBarBackButtonHidden(true)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }
                if UIDevice.current.userInterfaceIdiom == .pad {
                    VStack{}
                        .frame(height: proxy.size.height / 12)
                } else {
                    VStack {}
                        .frame(height: proxy.size.height/12)
                }
            }
            //Theme
            .foregroundColor(theme == "system" ? colorScheme == .dark ? .white : Color.black : theme == "light" ? Color.black : Color.white)
            .background(theme == "system" ? colorScheme == .dark ? darkBackground : lightBackground : theme == "light" ? lightBackground : darkBackground)
            .onAppear {
                // Do not allow setting change when has game -> may create bug
                isActiveGame = currentUserr.hasActiveGame
                // Responsive
                if UIDevice.current.userInterfaceIdiom == .phone {
                    viewTitleFontSize = 35
                    profileBackgroundSize = proxy.size.width/4
                    profileImageSizeHeight = proxy.size.width/4.5
                    profileImageSizeWidth = proxy.size.width/4.5
                    profileNameFont = .title
                    profileTitleFont = .body
                    navigationImageSizeWidth = proxy.size.width/10
                    navigationImageSizeHeight = proxy.size.width/10
                    profileFrameSizeHeight = proxy.size.width/3.5
                } else {
                    viewTitleFontSize = 70
                    profileBackgroundSize = proxy.size.width/5
                    profileImageSizeHeight = proxy.size.width/5.5
                    profileImageSizeWidth = proxy.size.width/5.5
                    profileNameFont = .largeTitle
                    profileTitleFont = .title
                    navigationImageSizeWidth = proxy.size.width/14
                    navigationImageSizeHeight = proxy.size.width/14
                    profileFrameSizeHeight = proxy.size.width/4.5
                    scaleSettingField = 1.5
                    textFieldPadding = proxy.size.width/4.5
                    settingTitleFont = .title
                    buttonConfirmFont = .title
                    buttonSignOutFont = .title
                }
            }
        }
        .alert(isPresented: $isShowAlert) {
            Alert(
                title: Text("Game In Play"),
                message: Text("To avoid system conflict. Please finish your game first!"),
                dismissButton: .default(Text("OK"))
            )
        }
        .edgesIgnoringSafeArea(.all)
        .preferredColorScheme(theme == "system" ? .init(colorScheme) : theme == "light" ? .light : .dark)
        .environment(\.locale, Locale(identifier: localization))
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
