//
//  ContentView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(ContentViewModel.self) var viewModel
        
    var body: some View {
        ZStack {
            switch viewModel.currentScreen {
            case .main:
                MainView()
                    .modelContainer(for: [DogBird.self])
            }
        }
    }
}
