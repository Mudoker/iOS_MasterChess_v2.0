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
        ["br0", "bn0", "bb0", "bq0", "bk0", "bb1", "bn1", "br1"],
        ["bp0", "bp1", "bp2", "bp3", "bp4", "bp5", "bp6", "bp7"],
        Array(repeating: nil, count: Constant.boardSize), // Represents empty rows
        Array(repeating: nil, count: Constant.boardSize), // Represents empty rows
        Array(repeating: nil, count: Constant.boardSize), // Represents empty rows
        Array(repeating: nil, count: Constant.boardSize), // Represents empty rows
        ["wp0", "wp1", "wp2", "wp3", "wp4", "wp5", "wp6", "wp7"],
        ["wr0", "wn0", "wb0", "wq0", "wk0", "wb1", "wn1", "wr1"],
    ]
}
