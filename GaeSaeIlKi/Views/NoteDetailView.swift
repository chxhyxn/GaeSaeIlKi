//
//  NoteDetailView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//

import SwiftUI

struct NoteDetailView: View {
    @Binding var failureNote: String
    @State private var editedNote: String
    @State private var isEditing: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    init(failureNote: Binding<String>) {
        self._failureNote = failureNote
        self._editedNote = State(initialValue: failureNote.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isEditing {
                    TextEditor(text: $editedNote)
                        .padding()
                        .background(Color(white: 0.95))
                        .cornerRadius(10)
                        .frame(minHeight: 150)
                } else {
                    ScrollView {
                        Text(failureNote)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(white: 0.95))
                            .cornerRadius(10)
                    }
                }
                
                if isEditing {
                    Button(action: {
                        failureNote = editedNote
                        isEditing = false
                    }) {
                        Text("저장")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("실패 일기", displayMode: .inline)
            .navigationBarItems(
                leading: Button("닫기") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: isEditing ? nil : Button("수정") {
                    isEditing = true
                }
            )
        }
    }
}
