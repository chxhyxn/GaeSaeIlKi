//
//  MainView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var context
    @Query private var dogBirds: [DogBird]
    
    @State private var fieldSize: CGSize = .zero
    
    @State private var currentGoal: String = (UserDefaults.standard.string(forKey: "currentGoal") ?? "")
    @State private var totalGaeSae: Int = UserDefaults.standard.integer(forKey: "totalGaeSae")

    @State private var failureNote: String = ""
    @State private var showAddGoalSheet = false

    @FocusState private var isTextFieldFocused: Bool
    
    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    // 잔디 배경
                    Image(uiImage: UIImage(named: "bg")!)
                        .resizable(resizingMode: .stretch)
                        .onAppear {
                            fieldSize = geometry.size
                        }
                    
                    // 개새들 (욕아님!)
                    ForEach(dogBirds) { dogBird in
                        DogBirdView(dogBird: dogBird)
                    }
                }
                .ignoresSafeArea(.all)
                .onTapGesture {
                    isTextFieldFocused = false
                }
            }
            
            // UI
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 2)
                    
                    VStack {
                        Text("나의 목표")
                            .font(.headline)
                            .padding(.top, 5)
                        
                        Text(currentGoal)
                            .font(.title)
                            .padding(.horizontal)
                            .padding(.bottom, 5)
                    }
                }
                .padding()

                .frame(height: 80)
                .onTapGesture {
                    // Dismiss keyboard first, then show sheet
                    isTextFieldFocused = false
                    showAddGoalSheet = true
                }
                
                Spacer()
                
                // 실패일기 입력 영역
                HStack {
                    TextField("오늘의 실패일기를 작성하세요", text: $failureNote)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .focused($isTextFieldFocused)
                    
                    Button(action: {
                        addDogBird()
                        isTextFieldFocused = false
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(failureNote.isEmpty ? .gray.opacity(0.2) : .white)
                            .frame(width: 50, height: 50)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                            .shadow(color: failureNote.isEmpty ? .clear : Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                    }
                    .disabled(failureNote.isEmpty)
                }
                .padding()
                .background(.ultraThinMaterial)
                .frame(height: 80)
                .clipShape(.rect(cornerRadius: 10))
                .padding()
            }
        }
        .onAppear() {
            showAddGoalSheet = currentGoal == ""
        }
        .sheet(isPresented: $showAddGoalSheet) {
            GoalSettingView(currentGoal: $currentGoal)
        }
        .onReceive(timer) { _ in
            updateDogBirdPositions()
        }
    }
    
    private func addDogBird() {
        guard !failureNote.isEmpty else { return }
        
        let randomX = CGFloat.random(in: 50..<(fieldSize.width - 50))
        let randomY = CGFloat.random(in: 50..<(fieldSize.height - 50))
        
        let newDogBird = DogBird(
            position: CGPoint(x: randomX, y: randomY),
            failureNote: failureNote
        )
        
        context.insert(newDogBird)
        failureNote = ""
    }
    
    // 개새 위치 업데이트
    private func updateDogBirdPositions() {
        var birdsToDelete: [DogBird] = []

        for dogBird in dogBirds {
            if dogBird.isFlying {
                var newPosition = dogBird.position
                newPosition.y -= 10
                newPosition.x += CGFloat.random(in: -3...3)
                dogBird.position = newPosition
                
                if newPosition.y < -100 {
                    birdsToDelete.append(dogBird)
                }
            } else {
                // 일반적인 움직임 (랜덤 방향으로 돌아다님)
                let angle = dogBird.rotation * .pi / 180
                var newPosition = dogBird.position
                
                newPosition.x += CGFloat(cos(angle) * dogBird.speed)
                newPosition.y += CGFloat(sin(angle) * dogBird.speed)
                
                // 화면 경계에 닿으면 방향 전환
                if newPosition.x < 20 || newPosition.x > fieldSize.width - 20 {
                    dogBird.rotation = 180 - dogBird.rotation
                }
                
                if newPosition.y < 20 || newPosition.y > fieldSize.height - 20 {
                    dogBird.rotation = 360 - dogBird.rotation
                }
                
                // 방향 전환 후 위치 재계산
                let newAngle = dogBird.rotation * .pi / 180
                newPosition.x = dogBird.position.x + CGFloat(cos(newAngle) * dogBird.speed)
                newPosition.y = dogBird.position.y + CGFloat(sin(newAngle) * dogBird.speed)
                
                // 가끔 랜덤하게 방향 변경
                if Int.random(in: 0...100) < 3 {
                    dogBird.rotation = Double.random(in: 0...360)
                }
                
                dogBird.position = newPosition
            }
        }

        for bird in birdsToDelete {
            context.delete(bird)
        }

        try? context.save()
    }
}
