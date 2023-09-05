/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 14/08/2023
 Last modified: 14/08/2023
 Acknowledgement:
 */

import Foundation

struct Constant {
    // Board size
    static let boardSize = 8
    
    // New board
    static let initialBoardSetup = [
        ["br", "bn", "bb", "bq", "bk", "bb", "bn", "br"],
        ["bp", "bp", "bp", "bp", "bp", "bp", "bp", "bp"],
        Array(repeating: "", count: Constant.boardSize), // Represents empty rows
        Array(repeating: "", count: Constant.boardSize), // Represents empty rows
        Array(repeating: "", count: Constant.boardSize), // Represents empty rows
        Array(repeating: "", count: Constant.boardSize), // Represents empty rows
        ["wp", "wp", "wp", "wp", "wp", "wp", "wp", "wp"],
        ["wr", "wn", "wb", "wq", "wk", "wb", "wn", "wr"],
    ]
    
    // Cases for testing game end state
    static let checkMateSetup = [
        // Stalemate Case with No Available Moves for Kings
        ["", "", "wr", "wk", "wr", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "bq", "", "", "", ""],
        ["", "", "", "bk", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""]
    ]
    
    static let staleMateSetup = [
        // Stalemate Case with No Available Moves for Kings
        ["bk", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "bq", "", ""],
        ["", "", "", "", "", "", "", "wk"]
    ]
    
    static let kingVsKing = [
        // Stalemate Case with No Available Moves for Kings
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["bk", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["wk", "", "", "", "", "", "", ""]
    ]
    
    static let kingKnightVsKing = [
        // Stalemate Case with No Available Moves for Kings
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "bn", "", "", "", "", ""],
        ["bk", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["wk", "", "", "wn", "", "", "", ""]
    ]
    
    static let kingBishopVsKing = [
        // Stalemate Case with No Available Moves for Kings
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "bb", "", "", "", "", ""],
        ["bk", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["wk", "", "", "wb", "", "", "", ""]
    ]
    
    static let kingKnightsVsKing1 = [
        // Stalemate Case with No Available Moves for Kings
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "bn", "", "", "", "", ""],
        ["bk", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["wk", "", "", "bn", "", "", "", ""]
    ]
    
    static let kingKnightsVsKing2 = [
        // Stalemate Case with No Available Moves for Kings
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["", "", "wn", "", "", "", "", ""],
        ["bk", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", ""],
        ["wk", "", "", "wn", "", "", "", ""]
    ]
    
}
