import SwiftUI

struct Welcome_Screen: View {
    @AppStorage("selectedLanguage") var selectedLanguage = "en" // Default language is English
    @State private var isLogin = false
    @State private var showAlert = false
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
                        .frame(width: proxy.size.width/2, height: proxy.size.width/2)
                    
                    Spacer()
                }
                VStack {
                    Spacer()
                    HStack {
                        Text("𝐌𝐚𝐬𝐭𝐞𝐫 𝐂𝐡𝐞𝐬𝐬")
                            .font(.system(size: proxy.size.width/8))
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Master Your Mind, Master Your Moves")
                            .font(.title3)
                            .bold()
                            .opacity(0.7)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    Button {
                        isLogin = true
                    } label: {
                        HStack {
                            Text("Let's explore")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .frame(width: proxy.size.width/1.1, height: 70)
                        .background(.white)
                        .clipShape(Capsule())
                        .padding(.bottom)
                    }
                    .navigationDestination(
                        isPresented: $isLogin // trigger the navigation
                    ) {
//                        LoginView()
//                            .environmentObject(currentUser)
//                            .navigationBarBackButtonHidden(true)
                    }
                    
                    HStack (alignment: .firstTextBaseline) {
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
                        
                        Spacer()
                        
                        Picker(selection: $selectedLanguage, label: Text("Select Language")) {
                            Text("English")
                                .tag("en")
                            
                            Text("Vietnamese")
                                .tag("vi")
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    
                }
                .padding(.bottom)
                .padding(.bottom)
                .foregroundColor(.white)
            }
            .ignoresSafeArea()
        }
        .environment(\.locale, Locale(identifier: selectedLanguage)) // Apply the selected language
    }
}

struct Welcome_Screen_Previews: PreviewProvider {
    static var previews: some View {
        Welcome_Screen()
    }
}
