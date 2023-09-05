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

struct Move: Equatable, Hashable {
    var from, to: Position
}
