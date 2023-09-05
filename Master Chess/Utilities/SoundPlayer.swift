/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 9/08/2023
 Last modified: 9/08/2023
 Acknowledgement:
 H. Tom. “Week 8 - UserDefaults, Sheet View, Sound Effects, Animation (RMIT Casino App - Part 2)” RMIT. https://rmit.instructure.com/courses/121597/modules (accessed Aug 30, 2023).
 */

import AVFoundation
import Foundation

struct SoundPlayer {
    static let shared = SoundPlayer()
    var audioPlayer: AVAudioPlayer?
    static var backgroundAudioPlayer: AVAudioPlayer?

    static func playSound(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer.play()
            } catch {
                print("Fail to play song")
            }
        }
    }

    static func startBackgroundMusic(volume: Float = 0.2) {
        guard let audioFilePath = Bundle.main.path(forResource: "background", ofType: "mp3") else {
            print("Background music file not found.")
            return
        }

        let audioFileURL = URL(fileURLWithPath: audioFilePath)

        do {
            backgroundAudioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
            backgroundAudioPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundAudioPlayer?.play()
            backgroundAudioPlayer?.volume = volume // Set the volume
        } catch {
            print("Error initializing audio player: \(error.localizedDescription)")
        }
    }

    static func stopBackgroundMusic() {
        backgroundAudioPlayer?.stop()
    }
}
