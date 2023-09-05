/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 18/08/2023
 Last modified: 18/08/2023
 Acknowledgement:
 */

import SwiftUI

struct Test_LoadEnvData: View {
    var currentUser = CurrentUser.shared

    var body: some View {
        Text(currentUser.username ?? "undefined")
    }
}

struct Test_LoadEnvData_Previews: PreviewProvider {
    static var previews: some View {
        Test_LoadEnvData()
    }
}
