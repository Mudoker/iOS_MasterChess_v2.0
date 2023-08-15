//
//  Board.swift
//  Chess
//
//  Created by Ivan Ruiz Monjo on 08/05/2020.
//  Copyright © 2020 Ivan Ruiz Monjo. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

struct ChessBoard {
    @Binding var currentUser: Users

    private var piecePositions: CurrentValueSubject<[[ChessPiece?]], Never> = CurrentValueSubject([])

    let currentPlayer: CurrentValueSubject<Player, Never> = CurrentValueSubject(.white)
    let isChecked: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)

    let whiteTimeLeft: CurrentValueSubject<TimeInterval, Never>
    let blackTimeLeft: CurrentValueSubject<TimeInterval, Never>
    private var cancellables = Set<AnyCancellable>()
    private let gameSetting: Setting

    init(player: Binding<Player>, user: Binding<Users>) {
        _currentUser = user
        gameSetting = user.wrappedValue.userSettings ?? Setting()

        // load from saved
        if user.wrappedValue.hasActiveGame, let savedGame = user.wrappedValue.savedGame {
            gameSetting.autoPromotionEnabled = savedGame.autoPromotionEnabled
            gameSetting.difficulty = savedGame.difficulty
            gameSetting.language = savedGame.language
            whiteTimeLeft = CurrentValueSubject(savedGame.whiteTimeLeft)
            blackTimeLeft = CurrentValueSubject(savedGame.blackTimeLeft)
        } else {
            // create new from user settings
            if let userSettings = user.wrappedValue.userSettings {
                gameSetting.autoPromotionEnabled = userSettings.autoPromotionEnabled
                gameSetting.difficulty = userSettings.difficulty
                gameSetting.language = userSettings.language
            }
            // Timer based on user ranking (Newbie: 60 mins, Master and GrandMaster: 15 mins)
            let initialTimeLimit: TimeInterval = user.wrappedValue.rating > 500 ? 15 * 60 : 60 * 60
            whiteTimeLeft = CurrentValueSubject(initialTimeLimit)
            blackTimeLeft = CurrentValueSubject(initialTimeLimit)
        }
    }
    
    // Start new game
    static func createInitialBoard() -> [[ChessPiece?]] {
        var piecePositions = Array(repeating: Array<ChessPiece?>(repeating: nil, count: 8), count: 8)

        for (rank, files) in Constant.initialBoardSetup.enumerated() {
            for (file, pieceCode) in files.enumerated() {
                if let pieceCode = pieceCode {
                    let piece = ChessPiece(stringLiteral: pieceCode)
                    piecePositions[rank][file] = piece
                }
            }
        }

        return piecePositions
    }
    
    // Load game from saved
    func createBoardFromLoad() -> [[ChessPiece?]] {
        var piecePositions = Array(repeating: Array<ChessPiece?>(repeating: nil, count: 8), count: 8)

        if let unwrappedBoardSetup = currentUser.savedGame?.unwrappedBoardSetup as? [[String?]] {
            for (rank, files) in unwrappedBoardSetup.enumerated() {
                for (file, pieceCode) in files.enumerated() {
                    if let pieceCode = pieceCode as String? {
                        let piece = ChessPiece(stringLiteral: pieceCode)
                        piecePositions[rank][file] = piece
                    }
                }
            }
        }

        return piecePositions
    }
}
