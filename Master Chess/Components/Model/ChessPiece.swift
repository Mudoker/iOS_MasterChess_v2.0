import Foundation
import SwiftUI

// Enum to represent the type of a game piece
enum PieceType: String {
    case pawn, rook, knight, bishop, queen, king

    // Assign weight for AI to calculate best move
    var weight: Int {
        switch self {
            case .pawn: return 10
            case .knight, .bishop: return 30
            case .rook: return 50
            case .queen: return 90
            case .king: return 900
        }
    }
}

// Enum to represent the player side
enum Player {
    case white, black
}

// ExpressibleByStringLiteral allows the pieces to be created by string literal
struct ChessPiece: ExpressibleByStringLiteral {
    let id: String
    var pieceType: PieceType
    let side: Color

    init(stringLiteral value: String) {
        guard value.count == 3 else {
            preconditionFailure("Invalid string literal length")
        }

        let color = value[value.startIndex].lowercased()
        let type = value[value.index(after: value.startIndex)].lowercased()

        switch color {
            case "b": side = .black
            case "w": side = .white
            default: preconditionFailure("Invalid side")
        }

        switch type {
            case "p": pieceType = .pawn
            case "r": pieceType = .rook
            case "n": pieceType = .knight
            case "b": pieceType = .bishop
            case "q": pieceType = .queen
            case "k": pieceType = .king
            default: preconditionFailure("Invalid piece type")
        }

        id = value
    }
}
