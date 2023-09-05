/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Doan Huu Quoc
  ID: 3927776
  Created  date: 29/08/2023
  Last modified: 03/09/2023
  Acknowledgement:
*/

import SwiftUI

// Create a dimmed background view for the modal view
struct Modal_BackGround: View {
    // Dark and light mode
    var isDark = false
    
    var body: some View {
        // Full screen cover
        VStack {
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(BlurView(isDark: isDark))
        .edgesIgnoringSafeArea(.all)
    }
}

// Blur view background
struct BlurView: UIViewRepresentable {
    // Dark and light mode
    var isDark = false
    
    // Required function
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: isDark ? .dark : .systemUltraThinMaterialDark))
        return view
    }
    
    // Required function
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct Modal_BackGround_Previews: PreviewProvider {
    static var previews: some View {
        Modal_BackGround()
    }
}
