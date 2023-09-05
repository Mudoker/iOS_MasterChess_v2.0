/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 12/08/2023
 Last modified: 03/09/2023
 Acknowledgement:
 */

import SwiftUI

// Custom modifier to shake image
struct VibratingShakingModifier: ViewModifier {
    // Control state
    @State private var isAnimating = false
    @State private var imageScale = 1.0
    
    // interval
    var deadline: TimeInterval = 1
    
    func body(content: Content) -> some View {
        // apply to the content
        content
            .scaleEffect(imageScale) // scaling
            .rotationEffect(.degrees(isAnimating ? -20 : 0), anchor: .center) // shaking
            .animation(
                Animation.easeInOut(duration: 0.1).repeatCount(isAnimating ? .max : 1, autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                if !isAnimating {
                    imageScale = 1.2
                    withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                        if !isAnimating {
                            isAnimating.toggle()
                            
                            // Stop animation after a time
                            DispatchQueue.main.asyncAfter(deadline: .now() + deadline) {
                                isAnimating = false
                                imageScale = 1.0
                            }
                        }
                    }
                }
            }
    }
}

// Apply to view
extension View {
    func vibratingShaking(deadline: TimeInterval) -> some View {
        self.modifier(VibratingShakingModifier(deadline: deadline))
    }
}

// Test
struct ShakingView: View {
    var body: some View {
        // Example usage
        Image(systemName: "star.fill")
            .resizable()
            .frame(width: 50, height: 50)
            .vibratingShaking(deadline: 1)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ShakingView()
    }
}
