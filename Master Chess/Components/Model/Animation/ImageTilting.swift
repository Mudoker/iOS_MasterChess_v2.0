import SwiftUI

struct VibratingShakingModifier: ViewModifier {
    @State private var isAnimating = false
    @State private var imageScale = 1.0
    var deadline: TimeInterval = 1
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(imageScale)
            .rotationEffect(.degrees(isAnimating ? -20 : 0), anchor: .center)
            .animation(
                Animation.easeInOut(duration: 0.1)
                    .repeatCount(isAnimating ? .max : 1, autoreverses: true)
                , value: isAnimating
            )
            .onAppear {
                if !isAnimating {
                    imageScale = 1.2
                    withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                        if !isAnimating {
                            isAnimating.toggle()
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

extension View {
    func vibratingShaking(deadline: TimeInterval) -> some View {
        self.modifier(VibratingShakingModifier(deadline: deadline))
    }
}

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
