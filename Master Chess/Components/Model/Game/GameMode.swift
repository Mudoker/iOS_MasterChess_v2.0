//
//  GameMode.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 15/08/2023.
//

import Foundation

struct GameMode: CustomStringConvertible, Identifiable {
    let id = UUID()
    
    let durationMinutes, timeIncrement: Int
    let mode: Mode
    
    var description: String {
        "\(durationMinutes) min + \(timeIncrement) sec"
    }
    
    enum Mode: String {
        case computer
        case localFriend = "Friend"
    }
}
