//
//  Test+Localization.swift
//  Master Chess
//
//  Created by quoc on 03/09/2023.
//

import SwiftUI

struct Test_Localization: View {
    @State var language = "en"
    @State var text = "greeting string"
    var body: some View {
        VStack {
            Spacer()
            Text(LocalizedStringKey(text))

            Button(action: {
                // Add your button action code here
                if language == "en" {
                    language = "vi"
                } else {
                    language = "en"
                }
            }) {
                Text("Click Me")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            Spacer()

        }
        .environment(\.locale, Locale.init(identifier: language))

    }
}

struct Test_Localization_Previews: PreviewProvider {
    static var previews: some View {
        Test_Localization()
//            .environment(\.locale, Locale.init(identifier: "vi"))
    }
}
