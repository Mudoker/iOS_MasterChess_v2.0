/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 19/08/2023
 Last modified: 19/08/2023
 Acknowledgement:
 */

import SwiftUI

// Test image sliding
struct Test_Slide: View {
    // Control state
    @State private var imageOffset: CGSize = .zero
    @State private var targetOffset: CGSize = .zero
    @State private var isMoving: Bool = false

    var body: some View {
        GeometryReader { proxy in
            VStack {
                // Push view
                Spacer()
                
                // Object
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
                
                // Push view
                Spacer()
                
                Image(systemName: "star")
                    .offset(imageOffset)
                
                // Push view
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
