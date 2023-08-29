//
//  Modal+BackGround.swift
//  Master Chess
//
//  Created by quoc on 29/08/2023.
//

import SwiftUI

struct Modal_BackGround: View {
    var body: some View {
        VStack {
            Text("Hello")
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(BlurView())
        .edgesIgnoringSafeArea(.all)
    }
}

struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
struct Modal_BackGround_Previews: PreviewProvider {
    static var previews: some View {
        Modal_BackGround()
    }
}
