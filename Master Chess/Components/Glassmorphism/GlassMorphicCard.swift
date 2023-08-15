import SwiftUI

// creat a glass morphic card view
struct GlassMorphicCard: View {
    // Checking for darkmode
    @Binding var isDarkMode: Bool

    // default dimension for card
    @State var width: CGFloat = 360
    @State var height: CGFloat = 200
    @State var minWidth: CGFloat = 0
    @State var opacity: CGFloat = 0.65
    // default option for card
    @State var useMinWidth = false
    var body: some View {
        // custom dimension for card
        if useMinWidth {
            ZStack {
                // Apply glass morphic effect with the provided dark mode binding
                GlassMorphicCardView(isDarkMode: $isDarkMode)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .opacity(opacity)
            }
            .frame(minWidth: minWidth)
            .frame(height: height)
        } else {
            ZStack {
                // Apply glass morphic effect with the provided dark mode binding
                GlassMorphicCardView(isDarkMode: $isDarkMode)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .opacity(opacity)
            }
            .frame(width: width)
            .frame(height: height)
        }
    }
}

// creat a glass morphic card view
struct GlassMorphicCardView: UIViewRepresentable {
    // Checking for darkmode
    @Binding var isDarkMode: Bool

    // creates the UIView representation of the card
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: nil)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return view
    }

    // updates the UIView when the isDarkMode state changes
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        let effectStyle: UIBlurEffect.Style = isDarkMode ? .extraLight : .dark
        
        let newEffect = UIBlurEffect(style: effectStyle)
        uiView.effect = newEffect
    }
}

struct GlassView: PreviewProvider {
    static var previews: some View {
        GlassMorphicCard(isDarkMode: .constant(true))
    }
}
