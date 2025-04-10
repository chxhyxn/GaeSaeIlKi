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
    @State private var isDragging = false
    @State private var dragOffset = CGSize.zero
    
    init(dogBird: DogBird) {
        self.dogBird = dogBird
        self._noteText = State(initialValue: dogBird.failureNote)
    }
    
    var body: some View {
        ZStack {
            if dogBird.isFlying {
                LottieView(name: "flying_dogbird", loopMode: .loop)
                    .frame(width: dogBird.size, height: dogBird.size)
            } else {
                LottieView(name: "dogbird", loopMode: .loop)
                    .frame(width: dogBird.size, height: dogBird.size)
            }
        }
        .position(dogBird.position)
        .scaleEffect(isDragging ? 1.1 : 1.0) // 드래그 시 약간 커지는 효과
        .shadow(color: .black.opacity(isDragging ? 0.3 : 0), radius: isDragging ? 10 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if !isDragging {
                        isDragging = true
                        // 드래그 시작할 때 날아가는 상태 중지
                        dogBird.isFlying = false
                    }
                    // 새 위치로 개새 이동
                    let newPosition = CGPoint(
                        x: gesture.location.x,
                        y: gesture.location.y
                    )
                    dogBird.position = newPosition
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
        .onTapGesture {
            if !isDragging {
                showNotePopup = true
            }
        }
        .sheet(isPresented: $showNotePopup) {
            NoteDetailView(failureNote: $noteText)
        }
    }
}
