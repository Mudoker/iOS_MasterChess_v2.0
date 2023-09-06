/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 12/08/2023
 Last modified: 01/09/2023
 Acknowledgement:
 ivangodfather. “Chess” Github.com. https://dribbble.com/shots/17726071/attachments/12888457?mode=media (accessed Aug 25, 2023).
 */

import Foundation
import UIKit
import Combine
import SwiftUI
import AVFoundation

final class GameViewModel: ObservableObject {
    // Control game state
    var currentUser = CurrentUser.shared
    @Published var board: [[ChessPiece?]] = []
    @Published var currentPlayer = Player.white
    @Published var whiteRemainigTime: String = ""
    @Published var blackRemainigTime: String = ""
    @Published var whitePlayerName = "Player 1"
    @Published var blackPlayerName = ""
    @Published var allValidMoves: [Move] = []
    @Published var history: [Move] = []
    @Published var blackPlayerProfile = ""
    @Published var blackTitle = ""
    @Published var isPromotion = false
    var pieces: [ChessPiece] { chessGame.activePieces }
    private var disposables = Set<AnyCancellable>()
    private var cancellables = Set<AnyCancellable>()

    // Audio player
    var audioPlayer = AVAudioPlayer()
    
    // AI
    let chessGame: ChessBoard
    private let ai1: AIBot
    private let ai2: AIBot

    // Initializer
    init() {
        chessGame = ChessBoard()
        
        // create an AI
        ai1 = AIBot(chessBoard: chessGame, player: .white)
        ai2 = AIBot(chessBoard: chessGame, player: .black)
        
        // capture changes in currentPlayer
        chessGame.$currentPlayer
            .sink { [weak self] currentPlayer in
                self?.currentPlayer = currentPlayer
            }
            .store(in: &cancellables)
        
        // capture changes in currentPlayer
        chessGame.$isPromotion
            .sink { [weak self] isPromotion in
                self?.isPromotion = isPromotion
            }
            .store(in: &cancellables)
        
        // Capture changes in piece position
        chessGame.piecePositions.assign(to: \.board, on: self).store(in: &disposables)
        
        // Update timer
        chessGame.$whiteTimeLeft
            .sink { [weak self] whiteTime in
                self?.whiteRemainigTime = "\(whiteTime)" // Use directly as Int
                // Play when 10 seconds left
                if whiteTime <= 10 && whiteTime >= 9 {
                    self?.playSound(sound: "tenseconds", type: "mp3")
                    
                    if whiteTime == 0 {
                        self?.chessGame.outcome = .outOfTime
                    }
                }
            }
            .store(in: &cancellables)
        
        // Update timer
        chessGame.$blackTimeLeft
            .sink { [weak self] blackTime in
                self?.blackRemainigTime = "\(blackTime)" // Use directly as Int
            }
            .store(in: &cancellables)
        
        // All valid moves
        chessGame.$allValidMoves
            .assign(to: &$allValidMoves)
        
        // Game history
        chessGame.history.assign(to: \.history, on: self).store(in: &disposables)
        
        // AI profile
        switch currentUser.settingDifficulty {
        case "normal":
            blackPlayerName = "Mitten"
            blackPlayerProfile = "mitten"
            blackTitle = "Pro"
            
        case "hard":
            blackPlayerName = "M.Carlsen"
            blackPlayerProfile = "magnus"
            blackTitle = "Grand Master"
            
        case "easy":
            blackPlayerName = "Nobita"
            blackPlayerProfile = "nobita"
            blackTitle = "Newbie"
            
        default:
            blackPlayerName = "Error" // Set a default value if none of the cases match
        }
    }
    
    // Generate all possible move for a piece at specific location
    func allMove(from: Position, piece: ChessPiece) {
        switch piece.pieceType {
        case .pawn:
            allValidMoves = chessGame.allValidPawnMoves(board: chessGame.piecePositions.value, from: from, history: chessGame.history.value)
            chessGame.allValidMoves = allValidMoves
            
        case .knight:
            allValidMoves = chessGame.allValidKnightMoves(board: chessGame.piecePositions.value, from: from)
            chessGame.allValidMoves = allValidMoves
            
        case .king:
            allValidMoves = chessGame.allValidKingMoves(board: chessGame.piecePositions.value, from: from)
            chessGame.allValidMoves = allValidMoves
            
        case .bishop:
            allValidMoves = chessGame.allValidBishopMoves(board: chessGame.piecePositions.value, from: from)
            chessGame.allValidMoves = allValidMoves
            
        case .rook:
            allValidMoves = chessGame.allValidRookMoves(board: chessGame.piecePositions.value, from: from)
            chessGame.allValidMoves = allValidMoves
            
        // Queen available moves will be the combination of bishop and rook
        case .queen:
            allValidMoves = chessGame.allValidRookMoves(board: chessGame.piecePositions.value, from: from) + chessGame.allValidBishopMoves(board: chessGame.piecePositions.value, from: from)
            chessGame.allValidMoves = allValidMoves
        }
    }
    
    // Move piêc
    func didMove(move: Move, piece: ChessPiece) {
        // Check if the ai is still moving
        guard ai2.isCalculatingMove == false else { return }
        guard chessGame.isPromotion == false else {return}
        // Player turn
        if currentPlayer == .white {
            allMove(from: move.from, piece: piece)
            // move a piece
            chessGame.movePiece(from: move.from, to: move.to)

            // Reset to empty
            allValidMoves = []
        }

        // AI is black by default
        if currentPlayer == .black {
            ai2.bestMove { move in
                if let move = move {
                    // When has value -> move the piece
                    self.chessGame.movePieceAI(from: move.from, to: move.to)
                    if self.currentUser.settingSoundEnabled {
                        self.playSound(sound: "move-opponent", type: "mp3")
                    }
                    self.allValidMoves = []
                }
            }
            
            // After move, check if white is loss
            if chessGame.isCheckMate(player: currentPlayer) || chessGame.isStaleMate(player: currentPlayer) ||
                chessGame.isOutOfMove(player: currentPlayer) || chessGame.isOutOfTime(player: currentPlayer) ||
                chessGame.isInsufficientMaterial(player: currentPlayer) {
                if self.currentUser.settingSoundEnabled {
                    self.playSound(sound: "game-end", type: "mp3")
                }
                
                if chessGame.winner == .white {
                    currentUser.rating += chessGame.ratingChange.calculateRatingChange(playerRating: currentUser.rating, opponentRating: currentUser.settingDifficulty == "easy" ? 400 : currentUser.settingDifficulty == "medium" ? 1000 : 2000, result: chessGame.outcome, difficulty: currentUser.settingDifficulty)
                } else {
                    currentUser.rating -= chessGame.ratingChange.calculateRatingChange(playerRating: currentUser.rating, opponentRating: currentUser.settingDifficulty == "easy" ? 400 : currentUser.settingDifficulty == "medium" ? 1000 : 2000, result: chessGame.outcome, difficulty: currentUser.settingDifficulty)
                    if currentUser.rating < 0 {
                        currentUser.rating = 0
                    }
                }
            }
        }        
    }
    
    // get current piece index
    func indexOf(_ piece: ChessPiece) -> Position {
        chessGame.getPiece(piece)
    }
    
    // Get piece at a location
    func getPiece(at position: Position) -> ChessPiece? {
        chessGame.getPiece(at: position)
    }
    
    // Remove a piece
    func removePiece(at position: Position) {
        chessGame.removePiece(at: position)
    }
    // start new game
    func start() {
        chessGame.start()
    }
    
    // Play sound
    func playSound(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer.play()
            } catch {
                print("Fail to play song")
            }
        }
    }

    // Converting for saving
    func convertChessPieceArrayToStringArray(_ chessPieceArray: [[ChessPiece?]]) -> [[String]] {
        return chessPieceArray.map { row in
            row.map { piece in
                piece?.pieceName ?? ""
            }
        }
    }
}
