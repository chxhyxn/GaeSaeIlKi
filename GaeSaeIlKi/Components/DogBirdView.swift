//
//  DogBirdView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//


import SwiftUI
import Lottie

struct DogBirdView: View {
    let dogBird: DogBird
    @State private var showNotePopup = false
    @State private var noteText: String
    
    init(dogBird: DogBird) {
        self.dogBird = dogBird
        self._noteText = State(initialValue: dogBird.failureNote)
    }
    
    var body: some View {
        ZStack {
            if dogBird.isFlying {
                LottieView(name: "flying_dogbird", loopMode: .loop)
                    .frame(width: dogBird.size * 1.2, height: dogBird.size * 1.2) // 날 때는 약간 크게
                    .offset(y: -10) // 위로 약간 올림
            } else {
                LottieView(name: "dogbird", loopMode: .loop)
                    .frame(width: dogBird.size, height: dogBird.size)
            }
        }
        .position(dogBird.position)
        .onTapGesture {
            showNotePopup = true
        }
        .sheet(isPresented: $showNotePopup) {
            NoteDetailView(failureNote: $noteText)
        }
    }
}
