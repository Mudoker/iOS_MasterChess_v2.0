/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2023B
  Assessment: Assignment 1
  Author: Doan Huu Quoc
  ID: 3927776
  Created  date: 18/07/2023
  Last modified: 26/07/2023
  Acknowledgement:
    Q.Doan, "app logo light" unpublished, Jul. 2023.
    T.Huynh. "Week 3 - Intro to SwiftUI, Xcode & Layouts (I'm Rich App)" rmit.instructure.com.https://rmit.instructure.com/courses/121597/pages/w3-whats-happening-this-week?module_item_id=5219563
      (accessed Jul. 20, 2023).
 Account (both should all be in lowercased):
    username: admin
    password: admin
*/

import SwiftUI
struct LoginView: View {
    @State var accountInput: String = ""
    @State var passwordInput: String = ""
    @State var isShowPassword: Bool = false
    @State private var isMenuView = false
    @State private var isRegister = false

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Users.username, ascending: true)],
        animation: .default)
    private var users: FetchedResults<Users>
    @State var loginStatus: String = ""
    @State var isAlert = false
    @State var isShowHint = false
    @AppStorage("userIndex") var userIndex = 0
    @AppStorage("userName") var username = ""
    @EnvironmentObject var currentUser: CurrentUser

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.12, blue: 0.18)
                .edgesIgnoringSafeArea(.all)
                VStack (alignment: .center) {
                    VStack {
                        Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300,height: 100)
                        Text("𝗟𝗼𝗴𝗶𝗻")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        Text("Please sign in to continue")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                    VStack(alignment: .leading) {
                        Text("Account")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .frame(height: 15)
                        RoundedRectangle(cornerRadius: 15)
                        .frame(height: 50)
                        .overlay(
                            HStack {
                                Image(systemName: "person")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.leading, 12)
                                .foregroundColor(.gray)
                                TextField("Username or email", text: $accountInput)
                                .padding(.leading, 8)
                                .foregroundColor(.black)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)

                            })
                        .padding(.horizontal)
                        .foregroundColor(.white)
                        .padding(.bottom)
                        HStack {
                            Text("Password")
                                .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                            
                            Text("(Optional)")
                                .opacity(0.7)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(height: 15)
                        RoundedRectangle(cornerRadius: 15)
                        .frame(height: 50)
                        .overlay(
                            HStack {
                                Image(systemName: "lock")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.leading, 12)
                                .foregroundColor(.gray)
                                if isShowPassword {
                                    TextField("Password", text: $passwordInput)
                                    .padding(.leading, 8)
                                    .foregroundColor(.black)
                                    .disableAutocorrection(true)
                                    .textInputAutocapitalization(.never)


                                }
                                else {
                                    SecureField("Password", text: $passwordInput)
                                    .padding(.leading, 8)
                                    .foregroundColor(.black)
                                    .disableAutocorrection(true)
                                    .textInputAutocapitalization(.never)


                                }
                                if passwordInput.count > 0 {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            isShowPassword.toggle()
                                        }
                                    })
                                    {
                                        Image(systemName: isShowPassword ?  "eye.fill" : "eye.slash.fill")
                                        .resizable()
                                        .frame(width: 30, height: 20)
                                        .padding(.trailing, 12)
                                        .foregroundColor(.gray)
                                    }
                                }
                            })
                        .padding(.horizontal)
                        .foregroundColor(.white)
                        Button {
                            for index in users.indices {
                                if users[index].username == accountInput && users[index].password == passwordInput {
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
                                    CurrentUser.shared.settingIsDarkMode = users[index].userSettings?.isDarkMode ?? false
                                    CurrentUser.shared.settingLanguage = users[index].userSettings?.language ?? ""
                                    CurrentUser.shared.settingMusicEnabled = users[index].userSettings?.musicEnabled ?? false
                                    CurrentUser.shared.settingSoundEnabled = users[index].userSettings?.soundEnabled ?? false
                                    CurrentUser.shared.settingDifficulty = users[index].userSettings?.difficulty ?? ""

                                    // Properties from SavedGame
                                    CurrentUser.shared.savedGameAutoPromotionEnabled = users[index].savedGame?.autoPromotionEnabled ?? false
                                    CurrentUser.shared.savedGameBlackTimeLeft = users[index].savedGame?.blackTimeLeft ?? 0
                                    CurrentUser.shared.savedGameBoardSetup = users[index].savedGame?.boardSetup ?? []
                                    CurrentUser.shared.savedGameCurrentPlayer = users[index].savedGame?.currentPlayer ?? ""
                                    CurrentUser.shared.savedGameDifficulty = users[index].savedGame?.difficulty ?? ""
                                    CurrentUser.shared.savedGameIsCheck = users[index].savedGame?.isCheck ?? false
                                    CurrentUser.shared.savedGameLanguage = users[index].savedGame?.language ?? ""
                                    CurrentUser.shared.savedGameMoveAvailable = users[index].savedGame?.moveAvailable ?? 0
                                    CurrentUser.shared.savedGameWhiteTimeLeft = users[index].savedGame?.whiteTimeLeft ?? 0
                                    CurrentUser.shared.savedGameIsWhiteKingMoved = users[index].savedGame?.isWhiteKingMoved ?? false
                                    CurrentUser.shared.savedGameIsBlackKingMoved = users[index].savedGame?.isBlackKingMoved ?? false
                                    CurrentUser.shared.savedGameIsWhiteLeftRookMoved = users[index].savedGame?.isWhiteLeftRookMoved ?? false
                                    CurrentUser.shared.savedGameIsWhiteRightRookMoved = users[index].savedGame?.isWhiteRightRookMoved ?? false
                                    CurrentUser.shared.savedGameIsBlackLeftRookMoved = users[index].savedGame?.isBlackLeftRookMoved ?? false
                                    CurrentUser.shared.savedGameIsBlackRightRookMoved = users[index].savedGame?.isBlackRightRookMoved ?? false
                                    CurrentUser.shared.savedGameKingPosition = users[index].savedGame?.kingPosition ?? 0
                                    
                                    loginStatus = "Login Successfully!"
                                    isMenuView = true
                                    userIndex = index
                                    username = users[index].unwrappedUsername
                                    break
                                }
                                else {
                                    loginStatus = "Wrong username or password"
                                }
                            }
                            print(isMenuView)
                            isAlert.toggle()
                        }
                        label: {
                            HStack {
                                Text("Login")
                                .bold()
                                .font(.title3)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal,25)
                            .frame(width: 340, height: 60)
                            .background(Color(red: 1.00, green: 0.30, blue: 0.00))
                            .clipShape(Capsule())
                            .padding(.top)
                            .padding(.horizontal)
                        }
                        .navigationDestination(
                            isPresented: $isMenuView) {
                                GameView()
                                    .navigationBarBackButtonHidden(true)
                        }
                            
                        HStack {
                            Button {
                                isShowHint = true
                            }
                            label: {
                                HStack {
                                    Spacer()
                                    Text("Forgot password?")
                                    .bold()
                                    .underline()
                                    Spacer()
                                }
                                .foregroundColor(Color(red: 1.00, green: 0.30, blue: 0.00))
                            }
                            Text("or")
                            .foregroundColor(.white)
                            Button {
                                userIndex = 1
                                isRegister = true
                            }
                            label: {
                                HStack {
                                    Spacer()
                                    Text("Create new account")
                                    .bold()
                                    .underline()
                                    Spacer()
                                }
                                .foregroundColor(Color(red: 1.00, green: 0.30, blue: 0.00))
                            }
                            .navigationDestination(
                                isPresented: $isRegister) {
                                    SignUpScreen().navigationBarBackButtonHidden(true)
                            }
                        }
                        .padding(.top, 5)
                    }
                    .frame(maxWidth: 370)
                    .edgesIgnoringSafeArea(.all)
                    Spacer()
                }
                .padding(.top, 50)
                if isAlert {
                    Rectangle()
                    .foregroundColor(Color.white)
                    .frame(width: 300, height: 200)
                    .overlay(
                        VStack (alignment: .center) {
                            Text("System alert")
                            .font(.title2)
                            .foregroundColor(.black)
                            .bold()
                            .padding(.top)
                            Spacer()
                            Text(loginStatus)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.black)
                            if loginStatus != "Login Successfully!" {
                                Text("Please try again")
                                .foregroundColor(.black)
                            }
                            Spacer()
                            Divider()
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    isAlert.toggle()
                                }
                            }
                            label: {
                                HStack {
                                    Spacer()
                                    Text("Close")
                                    .font(.title3)
                                    .foregroundColor(.red)
                                    Spacer()
                                }
                            }
                            .frame(width: 300)
                            .padding(.bottom)
                        })
                    .cornerRadius(10)
                    .padding()
                    .onAppear {
                        isAlert = true
                    }
                }
                if isShowHint {
                    Rectangle()
                    .foregroundColor(Color.white)
                    .frame(width: 300, height: 200)
                    .overlay(
                        VStack (alignment: .center) {
                            Text("Password Recovery")
                            .font(.title2)
                            .foregroundColor(.black)
                            .bold()
                            .padding(.top)
                            Spacer()
                            Text("Contact technical support")
                            .foregroundColor(.black)
                            .padding(.vertical, 5)
                            Text("masterChess@thebestgame.com")
                            .foregroundColor(.black)
                            Spacer()
                            Divider()
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    isShowHint.toggle()
                                }
                            }
                            label: {
                                HStack {
                                    Spacer()
                                    Text("Close")
                                    .font(.title3)
                                    .foregroundColor(.red)
                                    Spacer()
                                }
                            }
                            .frame(width: 300)
                            .padding(.bottom)
                        })
                    .cornerRadius(10)
                    .padding()
                    .onAppear {
                        isShowHint = true
                    }
                }
            }
        }
    }
}
struct Login_screen_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(accountInput: "", passwordInput: "", isShowPassword: false, loginStatus: "huhu")
    }

}
