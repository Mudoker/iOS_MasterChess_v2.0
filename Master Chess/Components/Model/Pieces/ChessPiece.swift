/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 12/08/2023
 Last modified: 12/08/2023
 Acknowledgement:
 ivangodfather. “Chess” Github.com. https://dribbble.com/shots/17726071/attachments/12888457?mode=media (accessed Aug 25, 2023).
 */

import Foundation
import SwiftUI

// Enum to represent the type of a game piece
enum PieceType: String {
    case pawn, rook, knight, bishop, queen, king
    
    // Assign weight for AI to calculate best move
    var weight: Int {
        switch self {
        case .pawn: return 1
        case .knight, .bishop: return 3
        case .rook: return 5
        case .queen: return 9
        case .king: return 1000
        }
    }
}

// Enum to represent the player side
enum Player {
    case white, black
}

// ExpressibleByStringLiteral allows the pieces to be created by string literal
struct ChessPiece: ExpressibleByStringLiteral, Identifiable, Hashable {
    let id: String
    var pieceType: PieceType
    let side: Player
    let imageView: String
    let pieceName: StringLiteralType
    var isInvalidMove = false
    init(stringLiteral value: String) {
        // the name should be bq, bk, wp, wk, ...
        guard value.count == 2 else {
            preconditionFailure("Invalid string literal length")
        }
        
        // Name format: bq = black queen
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
        
        id = UUID().uuidString
        imageView = color + type
        pieceName = value
    }
}
