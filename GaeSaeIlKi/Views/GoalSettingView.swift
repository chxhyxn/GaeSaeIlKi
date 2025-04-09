//
//  GoalSettingView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//

import SwiftUI

struct GoalSettingView: View {
    @Binding var currentGoal: String
    @State private var newGoal: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("당신의 목표를 설정하세요")
                    .font(.headline)
                
                TextField("목표를 입력하세요", text: $newGoal)
                    .padding()
                    .background(Color(white: 0.95))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button(action: {
                    if !newGoal.isEmpty {
                        currentGoal = newGoal
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("저장")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationBarTitle("목표 설정", displayMode: .inline)
            .navigationBarItems(trailing: Button("취소") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                newGoal = currentGoal
                if currentGoal == "목표를 설정해주세요" {
                    newGoal = ""
                }
            }
        }
    }
}
