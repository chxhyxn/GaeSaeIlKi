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
    
    // For animation
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    init(isPresented: Binding<Bool>, failureNote: Binding<String>) {
        self._isPresented = isPresented
        self._failureNote = failureNote
        self._editedNote = State(initialValue: failureNote.wrappedValue)
    }
    
    var body: some View {
        ZStack {
            // Background dimming
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .opacity(opacity)
                .onTapGesture {
                    closePopup()
                }
            
            // Glassmorphism popup card
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack {
                    Text("실패 일기")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
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
                            .opacity(0.8)
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
                            .fill(.ultraThinMaterial)
                            .opacity(0.8)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .frame(maxHeight: 200)
                    .padding(.horizontal)
                }
                
                // Footer
                HStack {
                    Spacer()
                    
                    Button(action: {
                        if isEditing {
                            commitChanges()
                        } else {
                            closePopup()
                        }
                    }) {
                        Text(isEditing ? "완료" : "닫기")
                            .fontWeight(.medium)
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
                .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(0.95)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 5)
            .frame(width: UIScreen.main.bounds.width * 0.85)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
        .animation(.default, value: isEditing)
    }
    
    private func commitChanges() {
        failureNote = editedNote
        isEditing = false
    }
    
    private func closePopup() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            scale = 0.8
            opacity = 0
        }
        
        // Delay dismissal to allow animation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}
