import SwiftUI

struct LeaderBoard: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Users.rating, ascending: false)], animation: .default) private var users: FetchedResults<Users>
    var currentUserr = CurrentUser.shared
    @State private var isProfileViewActive = false
    @State private var selectedUser: Users?
    @State private var profileViewShown = false // This should be @State
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                VStack {
                    Spacer()
                        .frame(height: proxy.size.width/6)
                    ZStack {
                        HStack {
                            Spacer()
                            NavigationLink(
                                destination: ProfileView(currentUser: users[0])
                            ) {
                                    VStack {
                                        Image("first")
                                            .resizable()
                                            .frame(width: proxy.size.width/5, height: proxy.size.width/5)
                                        Circle()
                                            .fill(Color(red: 0.47, green: 0.87, blue: 0.47))
                                            .frame(width: proxy.size.width/3.5)
                                            .overlay(
                                                Image(users[0].unwrappedProfilePicture)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: proxy.size.width/4)
                                            )
                                        Text(users[0].unwrappedUsername)
                                            .font(.title2)
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
                            Spacer()
                        }
                        HStack {
                            NavigationLink(destination: ProfileView(currentUser: users[1])) {
                                VStack {
                                    Image("second")
                                        .resizable()
                                        .frame(width: proxy.size.width/5.5, height: proxy.size.width/5.5)
                                    Circle()
                                        .fill(.gray)
                                        .frame(width: proxy.size.width/4)
                                        .overlay(
                                            Image(users[1].unwrappedProfilePicture)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: proxy.size.width/4)
                                        )
                                    Text(users[1].unwrappedUsername)
                                        .font(.title3)
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

                            Spacer()
                            NavigationLink(destination: ProfileView(currentUser: users[2])) {
                                VStack {
                                    Image("third")
                                        .resizable()
                                        .frame(width: proxy.size.width/5.5, height: proxy.size.width/5.5)
                                    Circle()
                                        .fill(.brown)
                                        .frame(width: proxy.size.width/4)
                                        .overlay(
                                            Image(users[2].unwrappedProfilePicture)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: proxy.size.width/4)
                                        )
                                    Text(users[2].unwrappedUsername)
                                        .font(.title3)
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
                        .padding(.top, proxy.size.width / 3)
                    }
                    .padding(.horizontal)

                    ScrollView {
                        ForEach(3..<users.count, id: \.self) { index in
                            NavigationLink(destination: ProfileView(currentUser: users[index])) {
                                HStack {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: proxy.size.width / CGFloat(10))
                                        .overlay(
                                            Text("\(index + 1)")
                                                .font(.title3)
                                                .bold()
                                                .foregroundColor(.black)
                                        )
                                    Image(users[index].unwrappedProfilePicture)
                                        .resizable()
                                        .frame(width: proxy.size.width / 6, height: proxy.size.width / 6)
                                    Text(users[index].unwrappedUsername)
                                        .font(.title2)
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
                .edgesIgnoringSafeArea(.all)
                .foregroundColor(.white)
                .background(Color(red: 0.00, green: 0.09, blue: 0.18))
            }
        }
    }
}
