//
//  SoundPlayer.swift
//  Master Chess
//
//  Created by quoc on 28/08/2023.
//

import AVFoundation
import Foundation

struct SoundPlayer {
    static let shared = SoundPlayer()
    var audioPlayer = AVAudioPlayer()
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
    
    static func startBackGroundMusic(volume: Float = 0.2) {
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
    
    func stopBackgroundMusic() {
        guard SoundPlayer.backgroundAudioPlayer != nil else { return }
        audioPlayer.stop()
    }
}
