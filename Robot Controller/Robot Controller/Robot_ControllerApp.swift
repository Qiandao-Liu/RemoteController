//
//  Robot_ControllerApp.swift
//  Robot Controller
//
//  Created by Qiandao Liu on 4/27/24.
//

import SwiftUI

@main
struct Robot_ControllerApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environmentObject(RobotViewModel())
        }
    }
}
