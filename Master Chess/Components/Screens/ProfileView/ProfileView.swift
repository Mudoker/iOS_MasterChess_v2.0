//
//  ProfileView.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 12/08/2023.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Users.username, ascending: true)], animation: .default) private var users: FetchedResults<Users>
    @EnvironmentObject var currentUserr: CurrentUser

    @State private var selectedLanguage = "English"
    @State private var selectedSound = false
    @State private var selectedSFX = false
    @State private var selectedAP = false
    @State private var selectedTheme = false
    @State var isConfirmLogOut: Bool = false
    @State var isLogOut: Bool = false
    @State private var newPassword = ""
    @State private var newUsername = ""
    @State private var isConfirmButtonEnabled = false
    @State private var isChangesMade = false
    @State var selectedDifficulty = "easy"
    @AppStorage("userName") var username = "Mudoker"
    @State private var isUsernameTakenAlertPresented = false

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
            VStack {
                let currentUser = getUserWithUsername(username)
                HStack {
                    Image(currentUser?.unwrappedProfilePicture ?? "chess")
                        .background(.gray.opacity(0.4))
                        .clipShape(Circle())
                    Spacer()
                    VStack(spacing: 5) {
                        Text(currentUser?.unwrappedUsername ?? "ok")
                            .font(.custom("OpenSans", size: 40))

                        if let userID = currentUser?.unwrappedUserID {
                            Text("#\(userID)")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("#000")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        }

                        Text("Join date: \(formatDate(currentUser?.unwrappedJoinDate ?? Date()))")
                            .font(.caption)

                        if let userRating = currentUser?.rating {
                            Text("Rating: \(String(userRating))")
                                .font(.caption)
                        } else {
                            Text("Rating: 0")
                                .font(.caption)
                        }
                    }
                }
                ScrollView (showsIndicators: false) {
                    HStack(spacing: 20) {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.gray.opacity(0.5))
                            .frame(width: proxy.size.width / 4, height: proxy.size.height / 8)
                            .overlay(
                                VStack {
                                    if let totalGames = currentUser?.unwrappedUserStats.totalGames {
                                        Text(String(totalGames))
                                            .foregroundColor(.white)
                                            .bold()
                                            .font(.title2)
                                    } else {
                                        Text("0")
                                            .foregroundColor(.white)
                                            .bold()
                                            .font(.title2)
                                    }

                                    Text("Games")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                }
                            )

                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.gray.opacity(0.5))
                            .frame(width: proxy.size.width / 4, height: proxy.size.height / 8)
                            .overlay(
                                VStack {
                                    if let winrate = currentUser?.unwrappedUserStats.winRate {
                                        Text("\(String(winrate))%")
                                            .foregroundColor(.white)
                                            .bold()
                                            .font(.title2)
                                    } else {
                                        Text("0%")
                                            .foregroundColor(.white)
                                            .bold()
                                            .font(.title2)
                                    }
                                    Text("Win rate")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                }
                            )

                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.gray.opacity(0.5))
                            .frame(width: proxy.size.width / 4, height: proxy.size.height / 8)
                            .overlay(
                                VStack {
                                    if let rank = currentUser?.ranking {
                                        Text(String(rank))
                                            .foregroundColor(.white)
                                            .bold()
                                            .font(.title2)
                                    } else {
                                        Text("0")
                                            .foregroundColor(.white)
                                            .bold()
                                            .font(.title2)
                                    }

                                    Text("Rank")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                }
                            )
                    }
                    
                    Section(header: Text("Achievements").font(.title2.bold())) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 10) {
                                ForEach(0..<20, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(index % 2 == 0 ? Color.blue : Color.green)
                                        .frame(width: proxy.size.width / 4, height: proxy.size.height / 8)
                                        .overlay(
                                            Text("Win: \(index * 5)")
                                                .foregroundColor(.white)
                                                .font(.headline)
                                        )
                                }
                            }
                        }
                        .frame(height: proxy.size.height / 8)
                        Spacer()
                        Section(header: Text("User settings").font(.title2.bold())) {
                            VStack(spacing: 20) {
                                VStack(spacing: 10) {
                                    RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.gray.opacity(0.2))
                                    .overlay(
                                        TextField("New Username", text: $newUsername)
                                            .foregroundColor(.white)
                                            .padding()
                                            .disableAutocorrection(true)
                                            .textInputAutocapitalization(.never)

                                            .onChange(of: newUsername) { _ in
                                                isChangesMade = true
                                                updateConfirmButtonState()
                                            }
                                    )
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.gray.opacity(0.2))
                                    .overlay(
                                        TextField("New Password", text: $newPassword)
                                            .foregroundColor(.white)
                                            .padding()
                                            .disableAutocorrection(true)
                                            .textInputAutocapitalization(.never)

                                            .onChange(of: newPassword) { _ in
                                                isChangesMade = true
                                                updateConfirmButtonState()
                                            }
                                    )
                                }
                                .preferredColorScheme(.dark)
                                .frame(height: proxy.size.height / 8)
                                
                                Toggle("Auto Promotion Enabled", isOn: $selectedAP)
                                    .foregroundColor(.white)
                                    .onChange(of: selectedAP) { _ in
                                        isChangesMade = true
                                        updateConfirmButtonState()
                                    }
                                    .onAppear {
                                        let autoPromotionEnabled = currentUser?.unwrappedUserSetting.unwrappedAutoPromotionEnabled ?? false
                                            selectedAP = autoPromotionEnabled
                                    }
                                
                                Toggle("Dark Mode", isOn: $selectedTheme)
                                    .foregroundColor(.white)
                                    .onChange(of: selectedTheme) { _ in
                                        isChangesMade = true
                                        updateConfirmButtonState()
                                    }
                                    .onAppear {
                                        let isDarkMode = currentUser?.unwrappedUserSetting.unwrappedIsDarkMode ?? false

                                        selectedTheme = isDarkMode
                                    }
                                
                                Toggle("Music Enabled", isOn: $selectedSound)
                                    .foregroundColor(.white)
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
                                    .onChange(of: selectedSFX) { _ in
                                        isChangesMade = true
                                        updateConfirmButtonState()
                                    }
                                    .onAppear {
                                        let isSoundOn = currentUser?.unwrappedUserSetting.unwrappedSoundEnabled ?? false

                                        selectedSFX = isSoundOn
                                    }
                                
                                Text("Language").bold()
                                Picker("Language", selection: $selectedLanguage) {
                                    Text("English").tag("English")
                                    Text("Vietnamese").tag("Vietnamese")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .preferredColorScheme(.dark)
                                .onAppear {
                                    let language = currentUser?.unwrappedUserSetting.unwrappedLanguage ?? ""

                                    selectedLanguage = language
                                }
                                
                                Text("Difficulty").bold()
                                Picker("Difficulty", selection: $selectedDifficulty) {
                                    Text("Newbie").tag("easy")
                                    Text("Intermediate").tag("normal")
                                    Text("Advanced").tag("hard")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .preferredColorScheme(.dark)
                                .onAppear {
                                    let difficulty = currentUser?.unwrappedUserSetting.unwrappedDifficulty ?? ""

                                    selectedDifficulty = difficulty
                                }
                                
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
                                        currentUser?.userSettings?.isDarkMode = selectedTheme
                                        currentUser?.userSettings?.soundEnabled = selectedSFX
                                        currentUser?.userSettings?.musicEnabled = selectedSound
                                        currentUser?.userSettings?.difficulty = selectedDifficulty
                                        currentUser?.userSettings?.difficulty = selectedDifficulty

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
                                }
                                .padding(.top)
                            }
                            .padding()
                        }
                    }
             }
                    VStack {
                    }.frame(height: 30)
                
            }
            .padding(.horizontal)
        }
        .foregroundColor(.white)
        .background(Color(red: 0.00, green: 0.09, blue: 0.18))
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
