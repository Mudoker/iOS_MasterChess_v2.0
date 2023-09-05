/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 28/08/2023
 Last modified: 28/08/2023
 Acknowledgement:
 */

import SwiftUI

struct PulsingView: View {
    @State var isPulsing = false
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Pulsing animation
                Circle().fill(Color.blue.opacity(0.25))
                    .frame(width: (proxy.size.width / 1 )/1.5)
                    .scaleEffect(self.isPulsing ? 1 : 0.001)
                
                Circle().fill(Color.blue.opacity(0.35))
                    .frame(width: (proxy.size.width / 1 )/2)
                    .scaleEffect(self.isPulsing ? 1 : 0.001)
                
                Circle().fill(Color.blue.opacity(0.45))
                    .frame(width: (proxy.size.width / 1 )/2.5)
                    .scaleEffect(self.isPulsing ? 1 : 0.001)
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
            .onAppear {
                self.isPulsing.toggle()
            }
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: true), value: isPulsing)
        }
    }
}

struct PulsingView_Previews: PreviewProvider {
    static var previews: some View {
        PulsingView()
    }
}
