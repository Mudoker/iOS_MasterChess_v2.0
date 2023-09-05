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
import UIKit

// Represents a position on a 2D grid
struct Position: Hashable {
    var x, y: Int
    
    var isValid: Bool {
        return x >= 0 && x < Constant.boardSize && y >= 0 && y < Constant.boardSize
    }
    
    // Overload for the - operator.
    // Calculates the difference between two positions and returns a Position
    static func - (left: Position, right: Position) -> Position {
        return Position(x: left.x - right.x, y: left.y - right.y)
    }
    
    // Overload for the + operator.
    // Adds a Position to another Position and returns a new Position
    static func + (left: Position, right: Position) -> Position {
        return Position(x: left.x + right.x, y: left.y + right.y)
    }
    
    // Overload for the += operator.
    // Modifies a Position by adding the values of another Position
    static func += (left: inout Position, right: Position) {
        left.x += right.x
        left.y += right.y
    }
}

extension Position {
    var size: CGSize {
        CGSize(width: CGFloat(x) * UIScreen.main.bounds.width / 8, height: -CGFloat(y) * UIScreen.main.bounds.width / 8)
    }
    
    init(_ translation: CGSize) {
        x = Int((translation.width / (UIScreen.main.bounds.width / 8)).rounded())
        y = Int((translation.height / (UIScreen.main.bounds.width / 8)).rounded())
    }
}
