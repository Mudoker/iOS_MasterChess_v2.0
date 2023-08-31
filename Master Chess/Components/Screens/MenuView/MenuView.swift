import SwiftUI

struct MenuView: View {
    @State private var currentTime = Date()
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Users.username, ascending: true)], animation: .default) private var users: FetchedResults<Users>
    @AppStorage("userName") var username = "Mudoker"
    @State private var isSheetPresented = true
    @State var showToast = false
    func getUserWithUsername(_ username: String) -> Users? {
        return users.first { $0.username == username }
    }
    // Function to convert date to string
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM / dd / yyyy"
        return dateFormatter.string(from: date)
    }
    
    @State var how2playView = false
    @State var gameView = false

    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                ZStack {
                    let currentUser = getUserWithUsername(username)

                    Color(red: 0.00, green: 0.09, blue: 0.18)
                    .ignoresSafeArea()
                    
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(getFormattedDate())
                                    
                                    .frame(height: proxy.size.width/100)
                                    .padding(.leading)
                        
                                Text(greeting(for: currentTime))
                                    .font(.title2)
                                    .frame(height: proxy.size.width/10)
                                    .bold()
                                    .padding(.leading)
                            }
                        
                            Spacer()
                        
                            HStack {
                                Text("Rank: \(String(currentUser?.ranking ?? 0))")
                                    .font(.caption)
                                Button(action: {}) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.gray.opacity(0.7))
                                            .frame(width: proxy.size.width/8, height: proxy.size.height/16)
                                        Image(systemName: "medal.fill")
                                            .resizable()
                                            .frame(width: proxy.size.width/16, height: proxy.size.width/16)
                                    }
                                }
                            }
                            .padding(.horizontal)

                        }
                        
                        HStack (spacing: 15) {
                            Button(action: {
                                gameView.toggle()
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.7))
                                        .frame(width: proxy.size.width/2.5, height: proxy.size.height/3)

                                    VStack {
                                        HStack {
                                            Image("chess")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                            .frame(width: proxy.size.width/3)
                                            Spacer()
                                        }
                                        .frame(width: proxy.size.width/2)
                                    
    //                                    Spacer()
                                    
                                        VStack (alignment: .leading, spacing: 5) {
                                            Text("Competitive")
                                                .font(.custom("OpenSans", size: 25))
                                                .bold()
                                                .multilineTextAlignment(.leading)
                                            Text("Player versus\nComputer")
                                                .font(.custom("OpenSans", size: 16))
                                                .multilineTextAlignment(.leading)
                                                .lineSpacing(2)
                                        }
                                        Spacer()
                                        Divider()
                                        HStack {
                                            Text("Play")
                                            Spacer()
                                            Image(systemName: "triangle.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: proxy.size.width/35)
                                                .rotationEffect(Angle(degrees: 90))
                                            
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom)

                                        Spacer()
                                    }
                                    .frame(width: proxy.size.width/2.5, height: proxy.size.height/2.5)
                                }
                            }
                            .fullScreenCover(isPresented: $gameView){
                                GameView()
                            }
                            
                            VStack {
                                Button(action: {
                                    how2playView = true
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.gray.opacity(0.7))
                                            .frame(width: proxy.size.width/2.5, height: proxy.size.height/6.1)

                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text("How to play?")
                                                        .font(.custom("OpenSans_Italic", size: 18))
                                                        .bold()
                                                    .multilineTextAlignment(.leading)
                                                Image("how2play")
                                                    .resizable()
                                                    .frame(width: proxy.size.width/6)
                                            }
                                            .padding(.leading)
                                            Spacer()
                                            Divider()
                                            HStack {
                                                Text("Explore")
                                                    .font(.caption)
                                                Spacer()
                                                Image(systemName: "triangle.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: proxy.size.width/55)
                                                    .rotationEffect(Angle(degrees: 90))
                                                
                                            }
                                            .padding(.horizontal)
                                            Spacer()
                                        }
                                        .padding(.top)
                                        .frame(width: proxy.size.width/2.5)
                                    }
                                }
                                .navigationDestination(isPresented: $how2playView) {
                                    How2playScreen()
                                        .navigationBarBackButtonHidden(false)
                                   
                                }
                                .frame(width: proxy.size.width/2.5, height: proxy.size.height/6)
                                
                                
                                Button(action: {
                                    if let url = URL(string: "https://www.fide.com") {
                                            UIApplication.shared.open(url)
                                        }
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.gray.opacity(0.7))
                                            .frame(width: proxy.size.width/2.5, height: proxy.size.height/6.3)
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text("Official Website")
                                                        .font(.custom("OpenSans_Italic", size: 18))
                                                        .bold()
                                                    .multilineTextAlignment(.leading)
                                                Image("fide")
                                                    .resizable()
                                                    .frame(width: proxy.size.width/6)
                                            }
                                            .padding(.leading)

    //                                                .padding(.leading)
                                            Spacer()
                                            Divider()
                                            HStack {
                                                Text("Explore")
                                                    .font(.caption)
                                                Spacer()
                                                Image(systemName: "triangle.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: proxy.size.width/55)
                                                    .rotationEffect(Angle(degrees: 90))
                                                
                                            }
                                            .padding(.horizontal)
                                            Spacer()
                                        }
                                        .padding(.top)
                                        .frame(width: proxy.size.width/2.5)

                                    }
                                }
                                .frame(width: proxy.size.width/2.5, height: proxy.size.height/6.3)
                            }
                        }
                        
                        
                        .frame(width: proxy.size.width)
                        .padding(.top)
                        Spacer()
                        
                        VStack {
                            HStack {
                                Text("Recent Matches")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                                Text(String(currentUser?.userStats?.unwrappedWins ?? 0))
                                    .bold()
                                Text("|")
                                    .bold()

                                Text(String(currentUser?.userStats?.unwrappedLosses ?? 0))
                                    .bold()
                                    .opacity(0.6)
                            }
                            .padding(.horizontal)
                         
                            if currentUser?.unwrappedGameHistory.isEmpty ?? true {
                                Spacer()
                                Text("No available history")
                            } else {
                                ScrollView {
                                    ForEach(currentUser?.unwrappedGameHistory ?? [GameHistory(context: viewContext)], id: \.self) { history in
                                        HStack {
                                            Text(formatDate(history.unwrappedDatePlayed))
                                                .bold()

                                            Spacer()

                                            Image("autobot")
                                                .resizable()
                                                .frame(width: proxy.size.width / 10, height: proxy.size.width / 12)
                                                .background(
                                                    Circle()
                                                    .foregroundColor(.white)
                                                )

                                            Text("Autobot")
                                                .bold()

                                            Spacer()

                                            Text(history.unwrappedOutcome)
                                        }
                                    }
                                }
                            }

                            Spacer()
                        }
                        .frame(width: proxy.size.width)
                        .padding(.top)
                    }
                    .frame(width: proxy.size.width)
                    .padding(.top)
                    
                    if showToast {
                        AchievementView(isContentVisible: showToast)
                    }
                }
                .frame(width: proxy.size.width)
                .foregroundColor(.white)
                .onAppear {
                    withAnimation(.easeInOut) {
                        showToast = true
                    }
                }
            }
            
        }
    }
    
    private func greeting(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        
        if hour >= 0 && hour < 12 {
            return "Good morning!"
        } else if hour >= 12 && hour < 18 {
            return "Good afternoon!"
        } else {
            return "Good evening!"
        }
    }
    
    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d yyyy"
        return dateFormatter.string(from: Date())
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
