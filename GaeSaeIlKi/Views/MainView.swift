//
//  MainView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//

import SwiftUI

struct MainView: View {
    @State private var dogBirds: [DogBird] = []
    @State private var failureNote: String = ""
    @State private var showAddGoalSheet = false
    @State private var currentGoal: String = "목표를 설정해주세요"
    @State private var fieldSize: CGSize = .zero
    
    @StateObject private var soundManager = SoundManager()
    @State private var shouting = false
    
    // Add focus state to track if the text field is focused
    @FocusState private var isTextFieldFocused: Bool
    
    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 배경
            Color(red: 0.8, green: 0.9, blue: 0.8)
                .edgesIgnoringSafeArea(.all)
                // Add tap gesture to the background to dismiss keyboard
                .onTapGesture {
                    isTextFieldFocused = false
                }
            
            VStack {
                // 들판 (개새들이 돌아다니는 곳)
                GeometryReader { geometry in
                    ZStack {
                        // 잔디 배경
                        Image(uiImage: UIImage(named: "bg")!)
                            .resizable(resizingMode: .stretch)
                            .onAppear {
                                fieldSize = geometry.size
                            }
                        
                        // 개새들
                        ForEach(dogBirds) { dogBird in
                            DogBirdView(dogBird: dogBird)
                        }
                    }
                    // Add tap gesture to dismiss keyboard when tapping in the field area
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                }
                .clipped()
                .background(Color(white: 0.95))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .ignoresSafeArea()
            }
            
            VStack {
                // 목표 표시
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(radius: 3)
                    
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
                .frame(height: 80)
                .padding(.horizontal)
                .onTapGesture {
                    // Dismiss keyboard first, then show sheet
                    isTextFieldFocused = false
                    showAddGoalSheet = true
                }
                
                Spacer()
                
                // 소리 레벨 표시기
                HStack {
                    Text("소리 레벨:")
                    ProgressView(value: CGFloat(soundManager.soundLevel), total: 160)
                        .progressViewStyle(LinearProgressViewStyle(tint: shouting ? Color.red : Color.blue))
                    
                    if shouting {
                        Text("오실완!")
                            .font(.headline.bold())
                            .foregroundColor(.red)
                    }
                    
                    // 디버깅용 소리 레벨 숫자 표시
                    Text("\(Int(soundManager.soundLevel))/160")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // 수동 버튼 추가 (테스트용)
                Button("오실완! (테스트)") {
                    print("테스트 버튼 눌림")
                    isTextFieldFocused = false  // Dismiss keyboard when button is pressed
                    shouting = true
                    
                    // 모든 개새의 isFlying을 true로 설정
                    for index in 0..<dogBirds.count {
                        var updatedDogBird = dogBirds[index]
                        updatedDogBird.isFlying = true
                        dogBirds[index] = updatedDogBird
                    }
                    
                    // 2초 후에 shouting 상태 원복
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        shouting = false
                    }
                }
                .padding(8)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.top, 4)
                
                // 실패일기 입력 영역
                HStack {
                    TextField("오늘의 실패일기를 작성하세요", text: $failureNote)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        // Add focus binding to the text field
                        .focused($isTextFieldFocused)
                    
                    Button(action: {
                        addDogBird()
                        // Dismiss keyboard after adding a dog bird
                        isTextFieldFocused = false
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.green)
                    }
                    .disabled(failureNote.isEmpty)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showAddGoalSheet) {
            GoalSettingView(currentGoal: $currentGoal)
        }
        .onReceive(timer) { _ in
            updateDogBirdPositions()
            checkShoutingStatus()
        }
    }
    
    // 개새 추가 함수
    private func addDogBird() {
        guard !failureNote.isEmpty else { return }
        
        let randomX = CGFloat.random(in: 50..<(fieldSize.width - 50))
        let randomY = CGFloat.random(in: 50..<(fieldSize.height - 50))
        
        let newDogBird = DogBird(
            position: CGPoint(x: randomX, y: randomY),
            failureNote: failureNote
        )
        
        dogBirds.append(newDogBird)
        failureNote = ""
    }
    
    // 개새 위치 업데이트
    private func updateDogBirdPositions() {
        for i in 0..<dogBirds.count {
            if i >= dogBirds.count { continue }
            
            // 날고 있는 개새는 화면 밖으로 이동
            if dogBirds[i].isFlying {
                var newPosition = dogBirds[i].position
                newPosition.y -= 10 // 위로 날아감
                newPosition.x += CGFloat.random(in: -3...3) // 약간 좌우로 흔들림
                
                dogBirds[i].position = newPosition
                
                // 화면에서 완전히 나가면 제거
                if newPosition.y < -100 {
                    dogBirds.remove(at: i)
                    continue
                }
            } else {
                // 일반적인 움직임 (랜덤 방향으로 돌아다님)
                let angle = dogBirds[i].rotation * .pi / 180
                var newPosition = dogBirds[i].position
                
                newPosition.x += CGFloat(cos(angle) * dogBirds[i].speed)
                newPosition.y += CGFloat(sin(angle) * dogBirds[i].speed)
                
                // 화면 경계에 닿으면 방향 전환
                if newPosition.x < 20 || newPosition.x > fieldSize.width - 20 {
                    dogBirds[i].rotation = 180 - dogBirds[i].rotation
                }
                
                if newPosition.y < 20 || newPosition.y > fieldSize.height - 20 {
                    dogBirds[i].rotation = 360 - dogBirds[i].rotation
                }
                
                // 방향 전환 후 위치 재계산
                let newAngle = dogBirds[i].rotation * .pi / 180
                newPosition.x = dogBirds[i].position.x + CGFloat(cos(newAngle) * dogBirds[i].speed)
                newPosition.y = dogBirds[i].position.y + CGFloat(sin(newAngle) * dogBirds[i].speed)
                
                // 가끔 랜덤하게 방향 변경
                if Int.random(in: 0...100) < 3 {
                    dogBirds[i].rotation = Double.random(in: 0...360)
                }
                
                dogBirds[i].position = newPosition
            }
        }
    }
    
    // 소리 체크 및 개새 날리기
    private func checkShoutingStatus() {
        let isCurrentlyShouting = soundManager.isShouting()
        
        // 상태가 변경되었을 때만 처리
        if isCurrentlyShouting != shouting {
            shouting = isCurrentlyShouting
            
            // 큰 소리가 감지되면 모든 개새를 날리기
            if shouting {
                print("큰 소리 감지됨! 개새들을 날립니다.")
                
                // 애니메이션 효과를 위해 약간의 지연시간을 두고 순차적으로 날리기
                for index in 0..<dogBirds.count {
                    // 각 개새마다 약간의 지연시간을 줌
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                        if index < self.dogBirds.count {
                            var updatedDogBird = self.dogBirds[index]
                            updatedDogBird.isFlying = true
                            self.dogBirds[index] = updatedDogBird
                        }
                    }
                }
            }
        }
    }
}
