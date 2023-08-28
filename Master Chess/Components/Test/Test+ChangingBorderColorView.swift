import SwiftUI

struct RunningBorderColorView: View {
    @State private var rotation:CGFloat = 0.0
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(width: 200, height: 300)
            
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(width: 130, height: 400)
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [.yellow.opacity(0.8), .orange.opacity(0.8), .yellow.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .rotationEffect(.degrees(rotation))
                .mask {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(lineWidth: 7)
                        .frame(width: 200, height: 300)
                }

        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
        
    }
}

struct RunningBorderColorView_Previews: PreviewProvider {
    static var previews: some View {
        RunningBorderColorView()
    }
}
