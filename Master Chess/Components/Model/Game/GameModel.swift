
import Foundation
import UIKit
import Combine
import SwiftUI

final class GameViewModel: ObservableObject {
    var currentUser = CurrentUser.shared
    @Published var board: [[ChessPiece?]] = []
    @Published var currentPlayer = Player.white
    @Published var whiteRemainigTime: String = ""
    @Published var blackRemainigTime: String = ""
    @Published var whitePlayerName = "Player 1"
    @Published var blackPlayerName = ""
    var pieces: [ChessPiece] { chessGame.activePieces }

    private var disposables = Set<AnyCancellable>()
     let chessGame: ChessBoard
    private let ai: Mitten
    var gameSetting = Setting()

    init() {
        chessGame = ChessBoard()
        // create an AI (Will be updated)
        ai = Mitten(chessGame: chessGame)
        
        // capture changes in currentPlayer
        chessGame.currentPlayer
            .assign(to: \.currentPlayer, on: self)
            .store(in: &disposables)

        // capture changes in piece position
        chessGame.piecePositions
            .assign(to: \.board, on: self)
            .store(in: &disposables)

        // capture time left for both players
        chessGame.whiteTimeLeft
            .map { $0.chessyTime() }
            .assign(to: \.whiteRemainigTime, on: self)
            .store(in: &disposables)

        chessGame.blackTimeLeft
            .map { $0.chessyTime() }
            .assign(to: \.blackRemainigTime, on: self)
            .store(in: &disposables)

        switch currentUser.settingDifficulty {
            case "hard":
                blackPlayerName = "Mitten"
            case "normal":
                blackPlayerName = "M.Carlsen"
            case "easy":
                blackPlayerName = "Nobita"
            default:
                blackPlayerName = "Error" // Set a default value if none of the cases match
        }
    }
    
    
    func didMove(move: Move) {
        // trigger when player turn
        guard ai.isThinking == false else { return }
        
        // move a piece
        chessGame.movePiece(from: move.from, to: move.to)
        
        // will be updated later (right now AI is black by default)
        if currentPlayer == .black {
            ai.bestMove { move in
                if let move = move {
                    self.chessGame.movePiece(from: move.from, to: move.to)
                }
            }
        }
    }

    // get current piece index
    func indexOf(_ piece: ChessPiece) -> Position {
        chessGame.getPiece(piece)
    }

    func getPiece(at position: Position) -> ChessPiece? {
        chessGame.getPiece(at: position)
    }
    
    // start new game
    func start() {
        currentUser.hasActiveGame = true
        chessGame.start()
    }
}
