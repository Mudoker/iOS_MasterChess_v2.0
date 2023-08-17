
import Foundation
import UIKit
import Combine
import SwiftUI

final class GameViewModel: ObservableObject {
    @Binding var currentUser: Users
    @Published var board: [[ChessPiece?]] = []
    @Published var currentPlayer = Player.white
    @Published var whiteRemainigTime: String = ""
    @Published var blackRemainigTime: String = ""
    @Published var whitePlayerName = "Player 1"
    @Published var blackPlayerName = ""
    var pieces: [ChessPiece] { chessGame.activePieces }

    private var disposables = Set<AnyCancellable>()
    private let chessGame: ChessBoard
    private let ai: SimpleAI
    let gameSetting: Setting

    init(user: Binding<Users>) {
        _currentUser = user
        gameSetting = user.wrappedValue.userSettings ?? Setting()
        chessGame = ChessBoard(user: user)
        ai = SimpleAI(chessGame: chessGame)
        
        chessGame.currentPlayer
            .assign(to: \.currentPlayer, on: self)
            .store(in: &disposables)

        chessGame.piecePositions
            .assign(to: \.board, on: self)
            .store(in: &disposables)

        chessGame.whiteTimeLeft
            .map { $0.chessyTime() }
            .assign(to: \.whiteRemainigTime, on: self)
            .store(in: &disposables)

        chessGame.blackTimeLeft
            .map { $0.chessyTime() }
            .assign(to: \.blackRemainigTime, on: self)
            .store(in: &disposables)

        switch gameSetting.difficulty {
            case "hard":
                blackPlayerName = "Mitten"
            case "intermediate":
                blackPlayerName = "M.Carlsen"
            case "easy":
                blackPlayerName = "Nobita"
            default:
                blackPlayerName = "DefaultName" // Set a default value if none of the cases match
        }
    }
    
    
    func didMove(move: Move) {
        guard ai.isThinking == false else { return }
        chessGame.movePiece(from: move.from, to: move.to)
        if currentPlayer == .black{
            ai.bestMove { move in
                if let move = move {
                    self.chessGame.movePiece(from: move.from, to: move.to)
                }
            }
        }
    }

    func indexOf(_ piece: ChessPiece) -> Position {
        chessGame.getPiece(piece)
    }

    func start() {
        chessGame.start()
    }
}
