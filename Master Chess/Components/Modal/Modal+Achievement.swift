import SwiftUI

struct AchievementView: View {
    @State var isContentVisible: Bool = true
    @State var isShowProfile = false
    var imageName = "rank1"
    var des = "Top 1 on the leaderboard!"
    @AppStorage("selectedLanguage") var selectedLanguage = "vi"
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("theme") var theme = ""
    @State var lightBackground = Color(red: 0.70, green: 0.90, blue: 0.90)
    @State var darkBackground = Color(red: 0.00, green: 0.09, blue: 0.18)
    
    //Responsive
    @State var capsuleSizeWidth: CGFloat = 0
    @State var capsuleSizeHeight: CGFloat = 0
    @State var titleFont: Font = .title2
    @State var contentFont: Font = .body
    var body: some View {
        GeometryReader { proxy in
            HStack {
                Spacer()
                VStack {
                    if isContentVisible {
                        Capsule()
                            .fill(.gray)
                            .frame(width: capsuleSizeWidth, height: capsuleSizeHeight)
                            .overlay(
                                HStack {
                                    Image(imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: proxy.size.height / 11, height: proxy.size.width / 9)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Achievement Unlocked")
                                            .font(titleFont)
                                            .bold()
                                        
                                        Text(LocalizedStringKey(des))
                                            .font(contentFont)
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
                }
                .onAppear {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        capsuleSizeWidth = proxy.size.height / 2
                        capsuleSizeHeight = proxy.size.width / 5
                    } else {
                        capsuleSizeWidth = proxy.size.height / 2
                        capsuleSizeHeight = proxy.size.width / 8
                        contentFont = .title
                        titleFont = .largeTitle
                    }
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
        .foregroundColor(theme == "system" ? colorScheme == .dark ? .white : Color.black : theme == "light" ? Color.black : Color.white)
        .preferredColorScheme(theme == "system" ? .init(colorScheme) : theme == "light" ? .light : .dark)
        .environment(\.locale, Locale(identifier: selectedLanguage))

    }
}

struct AchievementView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementView()
    }
}
