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

// Custom back button
struct TestCustomBackButton: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: SecondView()) {
                Text("Go to Second View")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .navigationBarTitle("First View", displayMode: .inline)
        }
    }
}

struct SecondView: View {
    // Control the presentation of views
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            Text("Second View")
                .font(.largeTitle)
                .padding()
        }
        .navigationBarBackButtonHidden(true) // Hide the back button
        .navigationBarItems(leading: backButton) // Place the custom back button in the top-left corner
    }

    // Button
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "arrow.left.circle.fill")
                    .imageScale(.large)
                
                Text("Go Back")
            }
            .padding()
            .foregroundColor(.blue)
        }
    }
}

struct TestCustomBackButton_Previews: PreviewProvider {
    static var previews: some View {
        TestCustomBackButton()
    }
}
