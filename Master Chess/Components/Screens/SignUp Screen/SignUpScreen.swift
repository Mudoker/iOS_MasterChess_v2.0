//
//  SignUpScreen.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 11/08/2023.
//

import SwiftUI

struct SignUpScreen: View {

    @State var currentStep = 1
    @State var selectedProfile = 1
    @State var selectedTheme = 1
    @State var isNavigation = false
    @State  var username: String = ""
    @State  var password: String = ""
    @State var isValidUsername: Bool = false
    @State var showAlertFalseUsername: Bool = false
    @State  var selectedLanguage = "English"
    @State  var selectedDifficulty = "easy"
    @State  var selectedSound = false
    @State  var selectedSFX = false
    @State  var selectedAP = false
    @State var isSkipRegister = false
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Users.username, ascending: true)],
        animation: .default)
    
    private var users: FetchedResults<Users>
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text ("Step")
                        .opacity(0.6)
                    Text ("\(currentStep) of 2")
                        .bold()
                    
                    Spacer()
                    
                    Button ("Skip") {
                        isSkipRegister = true
                    }.navigationDestination(
                        isPresented: $isSkipRegister // trigger the navigation
                    ) {
                        LoginView()
                            .navigationBarBackButtonHidden(true)
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Capsule()
                        .foregroundColor(currentStep == 1 ? .green : .gray)
                        .opacity(currentStep == 1 ? 1 : 0.5)
                        .frame(width: 120, height: 7)
                    Capsule()
                        .foregroundColor(currentStep == 2 ? .green : .gray)
                        .opacity(currentStep == 2 ? 1 : 0.5)
                        .frame(width: 120, height: 7)
                }
                .padding(.bottom, 30)
                
                if (currentStep == 1) {
                    Register1(selectedProfile: $selectedProfile, username: $username, isValidUsername: $isValidUsername, password: $password)
                } else {
                    Register2(selectedTheme: $selectedTheme, selectedLanguage: $selectedLanguage, selectedDifficulty: $selectedDifficulty, selectedSound: $selectedSound, selectedSFX: $selectedSFX, selectedAP: $selectedAP )
                }
                
                Spacer()
                
                Button {
                    if (isValidUsername) {
                        if (currentStep == 2) {
                            let setting = Setting(context: viewContext)
                            setting.autoPromotionEnabled = selectedAP
                            setting.isDarkMode = selectedTheme == 1 ? false : true
                            setting.language = selectedLanguage
                            setting.musicEnabled = selectedSound
                            setting.soundEnabled = selectedSFX
                            setting.difficulty = selectedDifficulty
                            
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
                            print(selectedProfile)

                            try? viewContext.save()

                            isNavigation = true
                        } else {
                            currentStep += 1
                        }
                    } else {
                        showAlertFalseUsername = true
                    }
                    
                } label: {
                    HStack {
                        if (currentStep < 2) {
                            Text("Continue")
                                .bold()
                        } else {
                            Text("Sign in")
                                .bold()
                        }
                        
                        
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                    .frame(width: 340, height: 60)
                    .background(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.bottom)
                }
                .navigationDestination(
                    isPresented: $isNavigation // trigger the navigation
                ) {
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                }
                .alert(isPresented: $showAlertFalseUsername) {
                    Alert(
                        title: Text("Invalid username"),
                        message: Text("Invalid password and it has been used"),
                        dismissButton: .default(Text("Close"))
                    )
                }
                .padding(.horizontal, 30)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .background(.black)
        }
        
    }
}

struct SignUpScreen_Previews: PreviewProvider {
    static var previews: some View {
        SignUpScreen()
    }
}

struct Register1: View {
    @Binding var selectedProfile: Int
    @Binding var username: String
    @Binding var isValidUsername: Bool
    @Binding var password: String
    @State var isShowPassword: Bool = false

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: []) var users: FetchedResults<Users>
    
    var body: some View {
        VStack {
            HStack {
                Text ("Create a profile")
                    .font(.system(size: 33))
                    .bold()
                
                Spacer()
            }
            
            HStack (spacing: 20) {
                ForEach(1...2, id: \.self) { i in
                    Button(action: {
                        selectedProfile = i
                    })
                    {
                        Image("profile\(i)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background(
                                Rectangle()
                                    .foregroundColor(selectedProfile == i ? .green : .gray)
                                    .opacity(selectedProfile == i ? 1 : 0.5)
                                    .cornerRadius(10)
                            )
                    }
                }
            }
            
            HStack (spacing: 20) {
                ForEach(3...4, id: \.self) { i in
                    Button(action: {
                        selectedProfile = i
                    })
                    {
                        Image("profile\(i)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background(
                                Rectangle()
                                    .foregroundColor(selectedProfile == i ? .green : .gray)
                                    .opacity(selectedProfile == i ? 1 : 0.5)
                                    .cornerRadius(10)
                            )
                    }
                }
            }
            
            VStack(alignment: .leading) {
                Text("The username should be atleast 5 characters")
                    .font(.caption)
                    .opacity(0.5)
                    .bold()
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .overlay(
                        HStack(spacing: 10) {
                            Image(systemName: "person.circle")
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 25, height: 25)
                            TextField("Username", text: $username)
                                .padding(.horizontal)
                                .font(.body)
                                .disableAutocorrection(true)
                                .textInputAutocapitalization(.never)
                                .foregroundColor((username.count > 1 && isUsernameValid) ? .black : .red)
                        }
                        .padding(.horizontal)
                    )
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 50)
                    .overlay(
                        HStack {
                            Image(systemName: "lock")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.gray)
                            if isShowPassword {
                                TextField("Password", text: $password)
                                    .padding(.horizontal)
                                    .foregroundColor(.black)
                                    .disableAutocorrection(true)
                                    .textInputAutocapitalization(.never)
                            }
                            else {
                                SecureField("Password", text: $password)
                                    .padding(.horizontal)
                                    .foregroundColor(.black)
                                    .disableAutocorrection(true)
                                    .textInputAutocapitalization(.never)
                            }
                            if password.count > 0 {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        isShowPassword.toggle()
                                    }
                                })
                                {
                                    Image(systemName: isShowPassword ?  "eye.fill" : "eye.slash.fill")
                                    .resizable()
                                    .frame(width: 30, height: 20)
                                    .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                    )
            }
            .padding(.top, 20)
            
        }
        .onChange(of: username) { value in
            isValidUsername = value.count >= 5 && users.filter { $0.username == value }.count == 0
        }
        .onChange(of: isUsernameValid) {
            value in
                        isValidUsername = value
        }
        .padding(.horizontal)
    }
    var isUsernameValid: Bool {
        return username.count >= 5 && !users.contains { $0.username == username }
    }
}


struct Register2: View {
    @Binding var selectedTheme: Int
    @Binding  var selectedLanguage: String
    @Binding  var selectedDifficulty: String
    @Binding  var selectedSound:Bool
    @Binding  var selectedSFX:Bool
    @Binding  var selectedAP:Bool

    
    var body: some View {
        VStack (alignment: .leading) {
            Text ("Choose a theme preference")
                .bold()
            HStack (spacing: 20) {
                ForEach(1...2, id: \.self) { i in
                    Button(action: {
                        selectedTheme = i
                    })
                    {
                        Image("bg\(i)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background(
                                Rectangle()
                                    .foregroundColor(selectedTheme == i ? i == 1 ? .yellow : .purple : .gray)
                                    .opacity(selectedTheme == i ? 1 : 0.5)
                                    .cornerRadius(10)
                            )
                    }
                }
            }
            .padding(.horizontal)
            
            VStack {
                Text ("Language")
                    .bold()
                Picker("Language", selection: $selectedLanguage) {
                                Text("Vietnamese").tag("Vietnamese")
                                Text("English").tag("English")
                            }
                    .pickerStyle(SegmentedPickerStyle())
                    .preferredColorScheme(.dark)
                
                Text ("Difficulty")
                    .bold()
                Picker("Difficulty", selection: $selectedDifficulty) {
                                Text("Newbie").tag("easy")
                                Text("Intermidiate").tag("normal")
                                Text("Advanced").tag("hard")
                            }
                    .pickerStyle(SegmentedPickerStyle())
                    .preferredColorScheme(.dark)
                
                Text ("Music")
                    .bold()
                Picker("Sound", selection: $selectedSound) {
                                Text("Disabled").tag(false)
                                Text("Enabled").tag(true)
                            }
                    .pickerStyle(SegmentedPickerStyle())
                    .preferredColorScheme(.dark)
                
                Text ("SFX")
                    .bold()
                Picker("SFX", selection: $selectedSFX) {
                                Text("Disabled").tag(false)
                                Text("Enabled").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .preferredColorScheme(.dark)
                
                Text ("Auto Promotion")
                    .bold()
                Picker("Auto promotion", selection: $selectedAP) {
                                Text("Disabled").tag(false)
                                Text("Enabled").tag(true)
                            }
                    .pickerStyle(SegmentedPickerStyle())
                    .preferredColorScheme(.dark)
            }
            
        }
        .padding(.horizontal)
    }
}
