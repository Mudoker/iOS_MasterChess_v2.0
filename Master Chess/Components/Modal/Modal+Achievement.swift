/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Doan Huu Quoc
  ID: 3927776
  Created  date: 30/08/2023
  Last modified: 01/09/2023
  Acknowledgement:
    Chess.com. "Achievements" chess.com https://www.chess.com/awards/josephreidnz/achievements (accessed 30/08/2023)
*/

import SwiftUI

// Achievement modal notification
struct AchievementView: View {
    // Control state
    @State var isContentVisible: Bool = true
    
    // Data
    var imageName = "master"
    var des = "Top 1 on the leaderboard!"
    
    // Localization
    @AppStorage("selectedLanguage") var selectedLanguage = "vi"
    
    // Dark Mode
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
            // Center horizontally
            HStack {
                // Push view
                Spacer()
                
                VStack {
                    if isContentVisible {
                        Capsule()
                            .fill(.gray)
                            .frame(width: capsuleSizeWidth, height: capsuleSizeHeight)
                            .overlay(
                                // Content
                                HStack {
                                    Image(imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: proxy.size.height / 11, height: proxy.size.width / 9)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Achievement Unlocked")
                                            .font(titleFont)
                                            .bold()
                                        
                                        Text(LocalizedStringKey(des))
                                            .font(contentFont)
                                    }
                                    
                                    // Push view
                                    Spacer()
                                }
                                .padding(.horizontal)
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .top),
                                removal: .move(edge: .top)
                            )) // Animation move up
                            .opacity(isContentVisible ? 1 : 0)
                            .offset(y: isContentVisible ? 0 : -proxy.size.height)
                            .scaleEffect(isContentVisible ? 1 : 0.2)
                    }
                }
                .onAppear {
                    // Responsive
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        capsuleSizeWidth = proxy.size.height / 2
                        capsuleSizeHeight = proxy.size.width / 5
                    } else {
                        capsuleSizeWidth = proxy.size.height / 1.5
                        capsuleSizeHeight = proxy.size.width / 6
                        contentFont = .title
                        titleFont = .largeTitle
                    }
                    
                    // Trigger animation
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
                
                // Push view
                Spacer()
            }
            
        }
        // Theme
        .foregroundColor(theme == "system" ? colorScheme == .dark ? .white : Color.black : theme == "light" ? Color.black : Color.white)
        .preferredColorScheme(theme == "system" ? .init(colorScheme) : theme == "light" ? .light : .dark)
        .environment(\.locale, Locale(identifier: selectedLanguage)) // localization
    }
}

struct AchievementView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementView()
    }
}
