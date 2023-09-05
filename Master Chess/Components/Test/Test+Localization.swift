/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 03/09/2023
 Last modified: 03/09/2023
 Acknowledgement:
 */

import SwiftUI

// Test localization
struct Test_Localization: View {
    //Control state
    @State var language = "en"
    @State var text = "greeting string"
    
    var body: some View {
        VStack {
            // Push view
            Spacer()
            
            // Content
            Text(LocalizedStringKey(text))
            
            // Button to localize
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
            
            // Push view
            Spacer()
            
        }
        .environment(\.locale, Locale.init(identifier: language)) // localization
    }
}

struct Test_Localization_Previews: PreviewProvider {
    static var previews: some View {
        Test_Localization()
            .environment(\.locale, Locale.init(identifier: "vi"))
    }
}
