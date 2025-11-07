//
//  Blueberry_LearnApp.swift
//  Blueberry Learn
//
//  Created by Daniel Matar on 11/5/25.
//

import SwiftUI

@main
struct Blueberry_LearnApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.light) // For POC, use light mode
                .fontDesign(.serif)
        }
    }
}
