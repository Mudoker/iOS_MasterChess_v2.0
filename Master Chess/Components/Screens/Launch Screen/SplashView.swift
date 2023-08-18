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
 Q.Doan, "Author Signature" unpublished, Jul. 2023.
 Q.Doan, "appIcon" unpublished, Jul. 2023.
 */

import SwiftUI

struct SplashView: View {
    // Variables to trigger animation
    @State private var isActive = false
    @State private var size = 1.0
    @State private var opacity = 0.5
    @EnvironmentObject var currentUser: CurrentUser

    var body: some View {
        NavigationStack {
            // Navigate to welcome screen if true
            if isActive {
                Welcome_Screen()
            } else {
                ZStack {
                    // Background
                    Color(.black)
                        .edgesIgnoringSafeArea(.all)
                    
                    // Author credentials
                    VStack {
                        VStack {
                            Image("Author Signature")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .scaleEffect(size)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1)) {
                                self.size = 3
                                self.opacity = 1.0
                            }
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.isActive = true // trigger navigation after 1 second
                        }
                    }
                    .navigationBarHidden(true) // hide the "Back" button after navigation
                }
            }
        }
    }
}

struct SplashView_Preview: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
    
}
