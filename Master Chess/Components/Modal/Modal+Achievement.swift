import SwiftUI

struct AchievementView: View {
    @State var isContentVisible: Bool = true
    @State var isShowProfile = false
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                HStack {
                    Spacer()
                    VStack {
                        if isContentVisible {
                            Button(action: {
                                isShowProfile.toggle()
                            }) {
                                Capsule()
                                    .fill(.gray)
                                    .frame(width: proxy.size.height / 2, height: proxy.size.width / 5)
                                    .overlay(
                                        HStack {
                                            Image("rank1")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: proxy.size.height / 11, height: proxy.size.width / 9)
                                            
                                            VStack(alignment: .leading) {
                                                Text("Achievement Unlocked")
                                                    .font(.title2)
                                                    .bold()
                                                    .foregroundColor(.white)
                                                Text("Top 1 on the leaderboard!")
                                                    .foregroundColor(.white)
                                            }
                                            Spacer()
                                        }
                                            .padding(.horizontal)
                                    )
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .top),
                                        removal: .move(edge: .top)
                                    ))
                                    .opacity(isContentVisible ? 1 : 0)
                                    .offset(y: isContentVisible ? 0 : -proxy.size.height)
                                    .scaleEffect(isContentVisible ? 1 : 0.2)
                            }
                            .navigationDestination(isPresented: $isShowProfile) {
                                ProfileView()
                            }
                            
                            
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isContentVisible.toggle()
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isContentVisible = false
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct AchievementView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementView()
    }
}
