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
        ["br0", "bn1", "bb2", "bq3", "bk4", "bb5", "bn6", "br7"],
        ["bp0", "bp1", "bp2", "bp3", "bp4", "bp5", "bp6", "bp7"],
        Array(repeating: nil, count: Constant.boardSize), // Represents empty rows
        Array(repeating: nil, count: Constant.boardSize), // Represents empty rows
        Array(repeating: nil, count: Constant.boardSize), // Represents empty rows
        Array(repeating: nil, count: Constant.boardSize), // Represents empty rows
        ["wp0", "wp1", "wp2", "wp3", "wp4", "wp5", "wp6", "wp7"],
        ["wr0", "wn1", "wb2", "wq3", "wk4", "wb5", "wn6", "wr7"],
    ]
}
