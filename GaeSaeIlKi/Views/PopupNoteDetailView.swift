//
//  PopupNoteDetailView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/10/25.
//

import SwiftUI

struct PopupNoteDetailView: View {
    @Binding var isPresented: Bool
    @Binding var failureNote: String
    @State private var editedNote: String
    @State private var isEditing: Bool = false
        
    @GestureState private var dragOffset: CGFloat = 0
    
    init(isPresented: Binding<Bool>, failureNote: Binding<String>) {
        self._isPresented = isPresented
        self._failureNote = failureNote
        self._editedNote = State(initialValue: failureNote.wrappedValue)
    }
    
    var body: some View {
        ZStack {
            // Glassmorphism popup card
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack(alignment: .top) {
                    Text("실패 일기")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // 손잡이
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 40, height: 5)
                    
                    Spacer()
                    
                    if isEditing {
                        Button(action: {
                            commitChanges()
                        }) {
                            Text("저장")
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.primary)
                        }
                    } else {
                        Button(action: {
                            isEditing = true
                        }) {
                            Text("수정")
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                Divider()
                    .background(Color.white.opacity(0.7))
                
                Text("당시 목표 : Challenge2 열심히 하기")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                Text("생성 일자 : YYYY-MM-DD")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                // Content
                if isEditing {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThickMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        
                        TextEditor(text: $editedNote)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 11)
                            .scrollContentBackground(.hidden) // iOS 16+ 옵션
                            .background(Color.clear)
                    }
                    .frame(minHeight: 100, maxHeight: 200)
                    .padding(.horizontal)
                    .padding(.bottom)
                } else {
                    VStack {
                        Text(failureNote)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.3))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    .frame(maxHeight: 200)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 5)
            .padding()
            .offset(y: dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if value.translation.height > 0 {
                            state = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 100 {
                            closePopup()
                        }
                    }
            )
        }
        .animation(.default, value: isEditing)
    }
    
    private func commitChanges() {
        failureNote = editedNote
        isEditing = false
    }
    
    private func closePopup() {
        isPresented = false
    }
}
