import SwiftUI

struct Test_Slide: View {
    @State private var imageOffset: CGSize = .zero
    @State private var targetOffset: CGSize = .zero
    @State private var isMoving: Bool = false

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.purple)
                    .frame(width: 20, height: 20)
                    .onTapGesture { location in
                        targetOffset = CGSize(
                            width: location.x,
                            height: location.y - proxy.size.height / 2
                        )
                        isMoving = true

                        withAnimation(.easeInOut(duration: 0.5)) {
                            imageOffset = targetOffset
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isMoving = false
                        }
                    }
                Spacer()
                Image(systemName: "star") // Replace with the name of your image asset
                    .offset(imageOffset)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct Test_Slide_Previews: PreviewProvider {
    static var previews: some View {
        Test_Slide()
    }
}
