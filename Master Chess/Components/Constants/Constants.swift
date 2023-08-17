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
}
