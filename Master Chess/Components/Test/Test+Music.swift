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

// test background music
struct Test_Music: View {
    var body: some View {
        VStack {
            //Push view
            Spacer()
            
            // Play music button
            Button(action: {
                SoundPlayer.startBackgroundMusic()
            }) {
                Text("Play Music")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            // Stop music button
            Button(action: {
                SoundPlayer.stopBackgroundMusic()
                
            }) {
                Text("Stop Music")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            // Push view
            Spacer()
        }
    }
}

struct Test_Music_Previews: PreviewProvider {
    static var previews: some View {
        Test_Music()
    }
}
