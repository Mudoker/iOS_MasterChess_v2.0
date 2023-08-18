//
//  Test+LoadEnvData.swift
//  Master Chess
//
//  Created by Quoc Doan Huu on 18/08/2023.
//

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
