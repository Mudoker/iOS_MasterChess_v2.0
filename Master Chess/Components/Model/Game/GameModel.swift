
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
    @Published var allValidMoves: [Move] = []
    @Published var history: [Move] = []

    var pieces: [ChessPiece] { chessGame.activePieces }
    private var disposables = Set<AnyCancellable>()

    let chessGame: ChessBoard
    private let ai: AIBot
    var gameSetting = Setting()
    private var cancellables = Set<AnyCancellable>()

    init() {
        chessGame = ChessBoard()
        // create an AI (Will be updated)
        ai = AIBot(chessBoard: chessGame)
        
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
        guard ai.isCalculatingMove == false else { return }
                
        allMove(from: move.from, piece: piece)
        
        // move a piece
        chessGame.movePiece(from: move.from, to: move.to)
        
        // The promotion is to queen by default
        if piece.pieceType == .pawn && move.to.y == 0 {
            chessGame.promotePiece(at: move.to, to: .queen)
        } else if piece.pieceType == .pawn && move.to.y == 7 {
            chessGame.promotePiece(at: move.to, to: .queen)
        }
        
        
        allValidMoves = []
        // will be updated later (right now AI is black by default)
        if currentPlayer == .black {
            ai.bestMove { move in
                if let move = move {
//                    self.chessGame.allValidMoves.append(move)
                    // When has value -> move the piece
                    self.chessGame.movePieceAI(from: move.from, to: move.to)
                    // The promotion is to queen by default
                    if let currentAIPiece = self.chessGame.getPiece(at: Position(x: move.from.x, y: move.from.y)) {
                        if currentAIPiece.pieceType == .pawn && move.to.y == 0 {
                            self.chessGame.promotePiece(at: move.to, to: .queen)
                        } else if currentAIPiece.pieceType == .pawn && move.to.y == 7 {
                            self.chessGame.promotePiece(at: move.to, to: .queen)
                        }
                    }
                    self.allValidMoves = []
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
    
    func removePiece(at position: Position) {
        chessGame.removePiece(at: position)
    }
    // start new game
    func start() {
        currentUser.hasActiveGame = false
        chessGame.start()
    }
}
