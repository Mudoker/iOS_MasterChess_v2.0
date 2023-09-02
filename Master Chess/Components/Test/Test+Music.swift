import SwiftUI

struct Test_Music: View {
    var body: some View {
        VStack {
            Spacer()
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
            Spacer()
        }
    }
}

struct Test_Music_Previews: PreviewProvider {
    static var previews: some View {
        Test_Music()
    }
}
