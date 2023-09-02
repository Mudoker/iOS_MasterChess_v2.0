//
//  SettingView.swift
//  Master Chess
//
//  Created by quoc on 30/08/2023.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Users.username, ascending: true)], animation: .default) private var users: FetchedResults<Users>
    var currentUserr = CurrentUser.shared
    @State private var selectedLanguage = "English"
    @State private var selectedSound = false
    @State private var selectedSFX = false
    @State private var selectedAP = false
    @State private var selectedTheme = "Dark"
    @State var isConfirmLogOut: Bool = false
    @State var isLogOut: Bool = false
    @State private var newPassword = ""
    @State private var newUsername = ""
    @State private var isConfirmButtonEnabled = false
    @State private var isChangesMade = false
    @State var selectedDifficulty = "easy"
    @AppStorage("userName") var username = "Mudoker"
    @State private var isUsernameTakenAlertPresented = false
    @State var isShowProfile = false
    func isUsernameAvailable(_ newUsername: String) -> Bool {
        let isTaken = users.contains { user in
            user.unwrappedUsername == newUsername
        }
        return !isTaken
    }
    // Function to convert date to string
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM / dd / yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func updateConfirmButtonState() {
        isConfirmButtonEnabled = isChangesMade
    }
    func getUserWithUsername(_ username: String) -> Users? {
        return users.first { $0.username == username }
    }
    
    var body: some View {
        GeometryReader { proxy in
            
            NavigationView {
                
                let currentUser = getUserWithUsername(username)
                VStack (alignment: .center) {
                    HStack {
                        Text("Settings")
                            .font(.largeTitle)
                            .bold()
                            .padding(.horizontal)
                        Spacer()
                    }
                    ScrollView(showsIndicators: false) {
                        
                        NavigationLink(destination: ProfileView(currentUser: currentUser ?? Users())) {
                            VStack {
                                HStack {
                                    Circle()
                                        .fill(.white.opacity(0.4))
                                        .frame(width: proxy.size.width/4)
                                        .overlay(
                                            Image(currentUser?.unwrappedProfilePicture ?? "profile1")
                                                .resizable()
                                                .frame(width: proxy.size.width/4.5, height: proxy.size.width/4.5)
                                        )
                                        .padding(.trailing)
                                    
                                    VStack (alignment: .leading) {
                                        Text(currentUser?.unwrappedUsername ?? "Mudoker")
                                            .font(.title)
                                            .bold()
                                        if currentUser?.rating ?? 2000 < 800 {
                                            Text("Newbie")
                                        } else if currentUser?.rating ?? 2000 < 1300 {
                                            Text("Pro")
                                        } else if currentUser?.rating ?? 2000 < 1600 {
                                            Text("Master")
                                        } else {
                                            Text("Grand Master")
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.forward.square")
                                        .resizable()
                                        .frame(width: proxy.size.width/10, height: proxy.size.width/10)
                                }
                                .padding(.horizontal)
                                .frame(height: proxy.size.width/3.5)
                                .background(.gray.opacity(0.2))
                                .padding(.bottom)
                            }
                        }
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded {
                                    isShowProfile = true
                                }
                        )
                        
                        
                        VStack(spacing: 20) {
                            VStack {
                                TextField("New Username", text: $newUsername)
                                    .foregroundColor(.white)
                                    .padding()
                                    .disableAutocorrection(true)
                                    .textInputAutocapitalization(.never)
                                    .onChange(of: newUsername) { _ in
                                        isChangesMade = true
                                        updateConfirmButtonState()
                                    }
                                
                                TextField("New Password", text: $newPassword)
                                    .foregroundColor(.white)
                                    .padding()
                                    .disableAutocorrection(true)
                                    .textInputAutocapitalization(.never)
                                
                                    .onChange(of: newPassword) { _ in
                                        isChangesMade = true
                                        updateConfirmButtonState()
                                    }
                            }
                            .frame(width: proxy.size.width)
                            .background(.gray.opacity(0.2))
                            
                            VStack (spacing: 20) {
                                Toggle("Auto Promotion Enabled", isOn: $selectedAP)
                                    .padding()
                                    .foregroundColor(.white)
                                    .onChange(of: selectedAP) { _ in
                                        isChangesMade = true
                                        updateConfirmButtonState()
                                    }
                                    .onAppear {
                                        let autoPromotionEnabled = currentUser?.unwrappedUserSetting.unwrappedAutoPromotionEnabled ?? false
                                        selectedAP = autoPromotionEnabled
                                    }
                                
                                Toggle("Music Enabled", isOn: $selectedSound)
                                    .foregroundColor(.white)
                                    .padding()
                                    .onChange(of: selectedSound) { _ in
                                        isChangesMade = true
                                        updateConfirmButtonState()
                                    }
                                    .onAppear {
                                        let isMusicOn = currentUser?.unwrappedUserSetting.unwrappedMusicEnabled ?? false
                                        
                                        selectedSound = isMusicOn
                                    }
                                
                                Toggle("Sound Enabled", isOn: $selectedSFX)
                                    .foregroundColor(.white)
                                    .padding()
                                    .onChange(of: selectedSFX) { _ in
                                        isChangesMade = true
                                        updateConfirmButtonState()
                                    }
                                    .onAppear {
                                        let isSoundOn = currentUser?.unwrappedUserSetting.unwrappedSoundEnabled ?? false
                                        
                                        selectedSFX = isSoundOn
                                    }
                            }
                            .background(.gray.opacity(0.2))
                            
                            VStack {
                                Text("Theme")
                                    .padding(.top)
                                Picker("Language", selection: $selectedTheme) {
                                    Text("Light").tag("light")
                                    Text("Dark").tag("dark")
                                    Text("System").tag("system")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .preferredColorScheme(.dark)
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
                                    isChangesMade = true
                                    updateConfirmButtonState()
                                }
                                
                                .padding([.bottom, .horizontal])
                                Text("Language")
                                    .padding(.top)
                                
                                Picker("Language", selection: $selectedLanguage) {
                                    Text("English").tag("English")
                                    Text("Vietnamese").tag("Vietnamese")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .preferredColorScheme(.dark)
                                .onAppear {
                                    let language = currentUser?.unwrappedUserSetting.unwrappedLanguage ?? "English"
                                    
                                    selectedLanguage = language
                                }
                                .onChange(of: selectedLanguage) { _ in
                                    isChangesMade = true
                                    updateConfirmButtonState()
                                }
                                .padding([.bottom, .horizontal])
                                
                                VStack{
                                    Text("Difficulty")
                                        .padding(.top)
                                    
                                    if selectedDifficulty == "easy" {
                                        Text("The AI will plan at most 2 moves a head")
                                            .opacity(0.7)
                                            .italic()
                                    } else if selectedDifficulty == "normal" {
                                        Text("The AI will plan at most 3 moves a head")
                                            .opacity(0.7)
                                            .italic()
                                    } else {
                                        Text("The AI will always plan 3 moves a head")
                                            .opacity(0.7)
                                            .italic()
                                    }
                                }
                                
                                
                                Picker("Difficulty", selection: $selectedDifficulty) {
                                    Text("Newbie").tag("easy")
                                    Text("Intermediate").tag("normal")
                                    Text("Advanced").tag("hard")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .preferredColorScheme(.dark)
                                .onAppear {
                                    let difficulty = currentUser?.unwrappedUserSetting.unwrappedDifficulty ?? "easy"
                                    
                                    selectedDifficulty = difficulty
                                }
                                .onChange(of: selectedDifficulty) { _ in
                                    isChangesMade = true
                                    updateConfirmButtonState()
                                }
                                .padding([.bottom, .horizontal])
                                
                            }
                            .background(.gray.opacity(0.2))
                            
                            VStack {
                                Button("Confirm Change") {
                                    if newUsername != "" {
                                        if isUsernameAvailable(newUsername) {
                                            isUsernameTakenAlertPresented = false
                                            currentUser?.username = newUsername
                                            newUsername = ""
                                        } else {
                                            isUsernameTakenAlertPresented = true
                                        }
                                    }
                                    if newPassword != "" {
                                        currentUser?.password = newPassword
                                        newPassword = ""
                                        
                                    }
                                    currentUser?.userSettings?.autoPromotionEnabled = selectedAP
                                    currentUser?.userSettings?.isSystemTheme = selectedTheme == "system" ? true : false
                                    currentUser?.userSettings?.isDarkMode = selectedTheme == "light" ? false : true
                                    currentUser?.userSettings?.soundEnabled = selectedSFX
                                    currentUser?.userSettings?.musicEnabled = selectedSound
                                    currentUser?.userSettings?.difficulty = selectedDifficulty
                                    
                                    currentUserr.settingAutoPromotionEnabled = selectedAP
                                    currentUserr.settingIsSystemTheme = selectedTheme == "system" ? true : false
                                    currentUserr.settingIsDarkMode = selectedTheme == "light" ? false : true
                                    currentUserr.settingSoundEnabled = selectedSFX
                                    currentUserr.settingMusicEnabled = selectedSound
                                    currentUserr.settingDifficulty = selectedDifficulty
                                    
                                    if !selectedSound {
                                        SoundPlayer.stopBackgroundMusic()
                                        
                                    } else {
                                        SoundPlayer.startBackgroundMusic()
                                    }
                                    try? viewContext.save()
                                    isConfirmButtonEnabled = false
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isConfirmButtonEnabled ? Color.blue : Color.gray)
                                .foregroundColor(.white)
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
                                
                                Button {
                                    isConfirmLogOut.toggle()
                                } label: {
                                    ZStack {
                                        Text("Sign out")
                                            .foregroundColor(.red)
                                            .bold()
                                            .font(.title3)
                                    }
                                    
                                }
                                .alert(isPresented: $isConfirmLogOut) {
                                    Alert(
                                        title: Text("Confirmation"),
                                        message: Text("Are you sure you want to sign out?"),
                                        primaryButton: .destructive(Text("Sign out")) {
                                            isLogOut = true
                                            username = ""
                                        },
                                        secondaryButton: .cancel(Text("Cancel"))
                                    )
                                }
                                .navigationDestination(isPresented: $isLogOut) {
                                    LoginView()
                                        .navigationBarBackButtonHidden(true)
                                }
                                .padding(.top, 6)
                            }
                            .padding(.top)
                        }
                    }
                }
                .foregroundColor(.white)
                .background(Color(red: 0.00, green: 0.09, blue: 0.18))
            }
            
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
