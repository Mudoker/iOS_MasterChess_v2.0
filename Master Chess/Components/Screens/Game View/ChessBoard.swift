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

    var piecePositions: CurrentValueSubject<[[ChessPiece?]], Never> = CurrentValueSubject([])

    let currentPlayer: CurrentValueSubject<Player, Never> = CurrentValueSubject(.white)
    let isChecked: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)

    let whiteTimeLeft: CurrentValueSubject<TimeInterval, Never>
    let blackTimeLeft: CurrentValueSubject<TimeInterval, Never>
    private var cancellables = Set<AnyCancellable>()
    private let gameSetting: Setting
    private var timer = Timer.publish(every: 1.0, on: .main, in: .common)
    private var history = [Move]
    
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
    func createInitialBoard() -> [[ChessPiece?]] {
        var piecePositions = Array(repeating: Array<ChessPiece?>(repeating: nil, count: Constant.boardSize), count: Constant.boardSize)
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
        var piecePositions = Array(repeating: Array<ChessPiece?>(repeating: nil, count: Constant.boardSize), count: Constant.boardSize)

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
    
    func getPiece(at position: Position) -> ChessPiece? {
        guard (0 ..< Constant.boardSize).contains(position.y), (0 ..< Constant.boardSize).contains(position.x) else {
            return nil
        }
        return piecePositions.value[position.y][position.x]
    }
    
    mutating func movePiece(from: Position, to: Position) {
        var updatedPiecePositions = piecePositions.value  // Make a copy of the current piecePositions
        
        // Move the piece
        updatedPiecePositions[to.y][to.x] = getPiece(at: from)
        updatedPiecePositions[from.y][from.x] = nil
        
        // Update the piecePositions with the new value
        piecePositions.send(updatedPiecePositions)
    }
    
    mutating func removePiece(at position: Position) {
        var updatedPiecePositions = piecePositions.value
        updatedPiecePositions[position.y][position.x] = nil
        piecePositions.send(updatedPiecePositions)
    }

    mutating func promotePiece(at position: Position, to type: PieceType) {
        var updatedPiecePositions = piecePositions.value
        var piece = updatedPiecePositions[position.y][position.x]
        piece?.pieceType = type
        updatedPiecePositions[position.y][position.x] = piece
        piecePositions.send(updatedPiecePositions)
    }
    
    private func validPawnMove(board: [[ChessPiece?]], from start: Position, to end: Position, player: Player, history: [Move]) -> Bool {
        let deltaX = abs(start.x - end.x)
        let deltaY = end.y - start.y
        
        // Check for diagonal move
        if deltaX == 1 {
            // Check if there is a piece at the destination and if it belongs to the same player
            if let destinationPiece = board[end.y][end.x], destinationPiece.side == player {
                return false
            }
            // Pawn can only move one step forward, with direction based on the player
            return deltaY == (player == .white ? -1 : 1)
        }
        
        // Check for vertical move
        if deltaX == 0 {
            let middleY = start.y + (player == .white ? 1 : -1)
            
            if deltaY == (player == .white ? 1 : -1) {
                // Check if the destination is empty
                if board[end.y][end.x] == nil {
                    return true
                }
            } else if deltaY == (player == .white ? 2 : -2) {
                // Check for the initial double move of the pawn
                if board[end.y][end.x] == nil && board[start.y][middleY] == nil {
                    // Make sure it's the initial move for the pawn
                    if (player == .white && start.y == 1) || (player == .black && start.y == 6) {
                        return true
                    }
                }
            }
        }
        // Check for en passant
        if deltaX == 1 && deltaY == (player == .white ? -1 : 1) {
            if let lastMove = history.last, lastMove.to.x == end.x {
                if let piece = board[lastMove.to.y][lastMove.to.x], piece.pieceType == .pawn, piece.side != player {
                    if (player == .white && lastMove.from.y == end.y + 1 && lastMove.to.y == end.y - 1) ||
                       (player == .black && lastMove.from.y == end.y - 1 && lastMove.to.y == end.y + 1) {
                        return true
                    }
                }
            }
        }

        return false
    }
}
