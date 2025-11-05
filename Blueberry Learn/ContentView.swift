//
//  ContentView.swift
//  Blueberry Learn
//
//  Created by Daniel Matar on 11/5/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "graduationcap")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Claude Learn")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
