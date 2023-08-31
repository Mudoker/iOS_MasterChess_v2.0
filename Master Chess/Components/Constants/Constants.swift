//
//  Constants.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 14/08/2023.
//

import Foundation

struct Constant {
    static let boardSize = 8
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
