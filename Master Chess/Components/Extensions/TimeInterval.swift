/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 15/08/2023
 Last modified: 01/09/2023
 Acknowledgement:
    ivangodfather. “Chess” Github.com. https://dribbble.com/shots/17726071/attachments/12888457?mode=media (accessed Aug 25, 2023).
 */

import Foundation

// Extend the TimeInterval
extension TimeInterval {
    // This method converts a TimeInterval into a formatted string
    func chessyTime() -> String {
        // Create a DateComponentsFormatter for formatting
        let formatter = DateComponentsFormatter()
        
        // Format the time as hours, minutes, and seconds
        formatter.unitsStyle = .positional
        
        // hours, minutes, and seconds
        formatter.allowedUnits = [ .hour, .minute, .second ]
        
        // pad with zeroes as needed
        formatter.zeroFormattingBehavior = [ .pad ]
        
        return formatter.string(from: self) ?? ""
    }
}
