import SwiftUI

struct LeaderBoard: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Users.rating, ascending: false)], animation: .default) private var users: FetchedResults<Users>
    var currentUserr = CurrentUser.shared
    @State private var isProfileViewActive = false
    @State private var selectedUser: Users?
    @State private var profileViewShown = false // This should be @State
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
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
    @State var rank1UsernameFont: Font = .title2
    @State var otherUsernameFont: Font = .title3
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
                Spacer()
                    .frame(height: proxy.size.width/6)
                ZStack {
                    HStack {
                        Spacer()
                        if users.count >= 1 {
                            NavigationLink(
                                destination: ProfileView(currentUser: users[0])
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
                                            Image(users[0].unwrappedProfilePicture)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: proxy.size.width/4)
                                                .scaleEffect(scaleUpSize)
                                        )
                                    
                                    Text(users[0].unwrappedUsername)
                                        .font(rank1UsernameFont)
                                    
                                    Text(String(users[0].rating))
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
                        } else {
                            Text("Not enough data!")
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        if users.count >= 2 {
                            NavigationLink(destination: ProfileView(currentUser: users[1])) {
                                VStack {
                                    Image("second")
                                        .resizable()
                                        .frame(width: imageSizeWidth, height: imageSizeHeight)
                                    
                                    Circle()
                                        .fill(.gray)
                                        .frame(width: imageBackgroundSize)
                                        .scaleEffect(scaleDownSize)
                                        .overlay(
                                            Image(users[1].unwrappedProfilePicture)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: proxy.size.width/4)
                                                .scaleEffect(scaleDownSize)
                                        )
                                    
                                    Text(users[1].unwrappedUsername)
                                        .font(otherUsernameFont)
                                    
                                    Text(String(users[1].rating))
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.gray)
                                }
                            }
                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded {
                                        isProfileViewActive = true
                                    }
                            )
                        }
                        
                        
                        
                        Spacer()
                        
                        if users.count >= 3 {
                            NavigationLink(destination: ProfileView(currentUser: users[2])) {
                                VStack {
                                    Image("third")
                                        .resizable()
                                        .frame(width: imageSizeWidth, height: imageSizeHeight)
                                    
                                    Circle()
                                        .fill(.brown)
                                        .frame(width: proxy.size.width/4)
                                        .overlay(
                                            Image(users[2].unwrappedProfilePicture)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: proxy.size.width/4)
                                                .scaleEffect(scaleDownSize)
                                        )
                                    
                                    Text(users[2].unwrappedUsername)
                                        .font(otherUsernameFont)
                                    
                                    Text(String(users[2].rating))
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.brown)
                                }
                                
                            }
                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded {
                                        isProfileViewActive = true
                                    }
                            )
                        }
                    }
                    .padding(.top, proxy.size.width / 3)
                }
                .padding(.horizontal)
                
                if users.count >= 4 {
                    ScrollView {
                        ForEach(3..<users.count, id: \.self) { index in
                            NavigationLink(destination: ProfileView(currentUser: users[index])) {
                                HStack {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: imageBackgroundSize/4)
                                        .overlay(
                                            Text("\(index + 1)")
                                                .font(otherUsernameFont)
                                                .bold()
                                                .foregroundColor(.black)
                                        )
                                    
                                    Image(users[index].unwrappedProfilePicture)
                                        .resizable()
                                        .frame(width: imageSizeWidth, height: imageSizeHeight)
                                    
                                    Text(users[index].unwrappedUsername)
                                        .font(otherUsernameFont)
                                    
                                    Spacer()
                                    
                                    Text(String(users[index].rating))
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
                
            }
            .frame(maxHeight: .infinity)
            .onAppear {
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
                    rank1UsernameFont = .title
                    otherUsernameFont = .title2
                }
            }
            .edgesIgnoringSafeArea(.all)
            .background(theme == "system" ? colorScheme == .dark ? darkBackground : lightBackground : theme == "light" ? lightBackground : darkBackground)
            .foregroundColor(theme == "system" ? colorScheme == .dark ? .white : Color.black : theme == "light" ? Color.black : Color.white)
            .preferredColorScheme(theme == "system" ? .init(colorScheme) : theme == "light" ? .light : .dark)
            
        }
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .navigationBarItems(leading: backButton) // Place the custom back button in the top-left corner
        .environment(\.locale, Locale(identifier: CurrentUser.shared.settingLanguage)) // Apply the selected language
    }
}

struct LeaderBoardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderBoard()
    }
}
