
import Foundation
import UIKit
import Combine
import SwiftUI
import AVFoundation
final class GameViewModel: ObservableObject {
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
    var audioPlayer = AVAudioPlayer()
    var pieces: [ChessPiece] { chessGame.activePieces }
    private var disposables = Set<AnyCancellable>()
    
    let chessGame: ChessBoard
    private let ai1: AIBot
    private let ai2: AIBot
    
    var gameSetting = Setting()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        chessGame = ChessBoard()
        // create an AI (Will be updated)
        ai1 = AIBot(chessBoard: chessGame, player: .white)
        ai2 = AIBot(chessBoard: chessGame, player: .black)
        
        // capture changes in currentPlayer
        chessGame.$currentPlayer
            .sink { [weak self] currentPlayer in
                self?.currentPlayer = currentPlayer
            }
            .store(in: &cancellables)
        
        chessGame.piecePositions.assign(to: \.board, on: self).store(in: &disposables)
        
        chessGame.$whiteTimeLeft
            .sink { [weak self] whiteTime in
                self?.whiteRemainigTime = "\(whiteTime)" // Use directly as Int
                if whiteTime <= 10 {
                    self?.playSound(sound: "tenseconds", type: "mp3")
                }
            }
            .store(in: &cancellables)
        
        chessGame.$blackTimeLeft
            .sink { [weak self] blackTime in
                self?.blackRemainigTime = "\(blackTime)" // Use directly as Int
            }
            .store(in: &cancellables)
        
        chessGame.$allValidMoves
            .assign(to: &$allValidMoves)
        
        chessGame.history.assign(to: \.history, on: self).store(in: &disposables)
        
        
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
            blackTitle = "Novice"
        default:
            blackPlayerName = "Error" // Set a default value if none of the cases match
        }
    }
    
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
        case .queen:
            allValidMoves = chessGame.allValidRookMoves(board: chessGame.piecePositions.value, from: from) + chessGame.allValidBishopMoves(board: chessGame.piecePositions.value, from: from)
            chessGame.allValidMoves = allValidMoves
        }
    }
    
    func didMove(move: Move, piece: ChessPiece) {
        // trigger when player turn
        guard ai2.isCalculatingMove == false else { return }
        
////                allMove(from: move.from, piece: piece)
////                print("Human Move: from \(move.from.x), \(move.from.y) to \(move.to.x), \(move.to.y)")
////                print(piece.pieceName)
////                // move a piece
////                chessGame.movePiece(from: move.from, to: move.to)
//
//                allValidMoves = []
//        // will be updated later (right now AI is black by default)
//        //        while chessGame.outcome == .ongoing {
        if currentPlayer == .white {
            ai1.bestMove { move in
                if let move = move {
                    print("AI White Move: before \(move.from.x), \(move.from.y)")
                    self.playSound(sound: "move-self", type: "mp3")
    
                    // When has value -> move the piece
                    self.chessGame.movePieceAI(from: move.from, to: move.to)
                    print("AI White Move: after \(move.to.x), \(move.to.y)")
                    print("------")
                    self.allValidMoves = []
                }
            }
        }
        
        guard ai1.isCalculatingMove == false else { return }

        // will be updated later (right now AI is black by default)
        if currentPlayer == .black {
            ai2.bestMove { move in
                if let move = move {
                    print("AI Black Move: before \(move.from.x), \(move.from.y)")
                    // When has value -> move the piece
                    self.chessGame.movePieceAI(from: move.from, to: move.to)
                    self.playSound(sound: "move-self", type: "mp3")
                    print("AI Black Move: after \(move.to.x), \(move.to.y)")
                    print("------")
                    self.allValidMoves = []
                }
            }
        }
        //        }
        
    }
    
    // get current piece index
    func indexOf(_ piece: ChessPiece) -> Position {
        chessGame.getPiece(piece)
    }
    
    func getPiece(at position: Position) -> ChessPiece? {
        chessGame.getPiece(at: position)
    }
    
    func removePiece(at position: Position) {
        chessGame.removePiece(at: position)
    }
    // start new game
    func start() {
        currentUser.hasActiveGame = false
        chessGame.start()
    }
    
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
}
