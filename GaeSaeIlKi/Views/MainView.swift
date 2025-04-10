//
//  MainView.swift
//  GaeSaeIlKi
//
//  Updated on 4/10/25.
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
    
    // 쓰레기통 관련 상태
    @State private var trashVisible = false
    @State private var trashHighlighted = false
    @State private var draggingDogBirdID: UUID? = nil
    
    @FocusState private var isTopTextFieldFocused: Bool
    @FocusState private var isBottomTextFieldFocused: Bool
    
    @StateObject var soundManager = SoundManager()
    
    // 노트 팝업 관련 상태
    @State private var selectedDogBird: DogBird?
    @State private var showingNoteDetail = false
    @State private var editedNote = ""
    
    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    // MARK: 잔디 배경
                    Image(uiImage: UIImage(named: "bg")!)
                        .resizable(resizingMode: .stretch)
                        .onAppear {
                            fieldSize = geometry.size
                        }
                    
                    // MARK: 쓰레기통
                    ZStack {
                        Circle()
                            .fill(trashHighlighted ? Color.red.opacity(0.3) : Color.gray.opacity(0.2))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(trashHighlighted ? Color.red : Color.gray, lineWidth: trashHighlighted ? 3 : 1)
                            )
                        
                        Image(systemName: "trash")
                            .symbolEffect(.bounce, value: trashHighlighted)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(trashHighlighted ? .red : .gray)
                            .frame(width: 70, height: 70)
                            .background(
                                Circle()
                                    .fill(trashHighlighted ? .white.opacity(0.9) : .white.opacity(0.8))
                                )
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 120)
                    .opacity(trashVisible ? 1 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: trashVisible)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: trashHighlighted)
                    
                    // MARK: 개새들 (욕아님!)
                    ForEach(dogBirds) { dogBird in
                        ZStack {
                            if dogBird.isFlying {
                                LottieView(name: "flying_dogbird", loopMode: .loop)
                                    .frame(width: dogBird.size, height: dogBird.size)
                            } else {
                                LottieView(name: "dogbird", loopMode: .loop)
                                    .frame(width: dogBird.size, height: dogBird.size)
                            }
                            VStack {
                                Spacer()
                                    .frame(height: dogBird.size * 3 / 5)
                                Text("이름 없는 개새")
                                    .frame(height: 20)
                                    .font(.caption2)
                                    .padding(.horizontal, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.black.opacity(0.3))
                                    )
                                    .foregroundStyle(.white)
                            }
                        }
                        .position(dogBird.position)
                        .scaleEffect(draggingDogBirdID == dogBird.id ? 1.1 : 1.0)
                        .shadow(
                            color: .black.opacity(draggingDogBirdID == dogBird.id ? 0.3 : 0),
                            radius: draggingDogBirdID == dogBird.id ? 10 : 0
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    // 드래그 시작 또는 진행 중
                                    draggingDogBirdID = dogBird.id
                                    dogBird.isFlying = false
                                    dogBird.position = gesture.location
                                    
                                    // 쓰레기통 표시
                                    trashVisible = true
                                    
                                    // 쓰레기통 위에 있는지 확인
                                    let trashPosition = CGPoint(
                                        x: geometry.size.width / 2,
                                        y: geometry.size.height - 120
                                    )
                                    
                                    let distance = sqrt(
                                        pow(gesture.location.x - trashPosition.x, 2) +
                                        pow(gesture.location.y - trashPosition.y, 2)
                                    )
                                    
                                    trashHighlighted = distance < 45
                                }
                                .onEnded { gesture in
                                    // 드래그 종료
                                    let trashPosition = CGPoint(
                                        x: geometry.size.width / 2,
                                        y: geometry.size.height - 120
                                    )
                                    
                                    let distance = sqrt(
                                        pow(gesture.location.x - trashPosition.x, 2) +
                                        pow(gesture.location.y - trashPosition.y, 2)
                                    )
                                    
                                    // 쓰레기통 위에서 드롭되었으면 삭제
                                    if distance < 45 {
                                        withAnimation {
                                            context.delete(dogBird)
                                        }
                                    }
                                    
                                    // 상태 초기화
                                    draggingDogBirdID = nil
                                    trashVisible = false
                                    trashHighlighted = false
                                }
                        )
                        .onTapGesture {
                            if draggingDogBirdID == nil {
                                showNoteDetail(for: dogBird)
                            }
                        }
                    }
                }
                .ignoresSafeArea(.all)
                .onTapGesture {
                    isTopTextFieldFocused = false
                    isBottomTextFieldFocused = false
                }
            }
            
            // MARK: 큰 음성 감지 UI
            VStack {
                Spacer()
                VolumeRingView(decibel: soundManager.soundLevel)
                Spacer()
            }
            
            // UI
            VStack {
                // MARK: 상단 UI
                VStack {
                    Text("나의 목표")
                        .font(.headline)
                    
                    HStack {
                        TextField("당신의 목표를 작성하세요.", text: $currentGoal)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(isTopTextFieldFocused ? .white : .white.opacity(0.7))
                                )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .focused($isTopTextFieldFocused)
                        
                        if isTopTextFieldFocused {
                            Button(action: {
                                isTopTextFieldFocused = false
                                UserDefaults.standard.set(currentGoal, forKey: "currentGoal")
                            }) {
                                Image(systemName: "checkmark")
                                    .symbolEffect(.bounce, value: !isTopTextFieldFocused||currentGoal.isEmpty)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(!isTopTextFieldFocused||currentGoal.isEmpty ? .gray.opacity(0.2) : .gray)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(!isTopTextFieldFocused||currentGoal.isEmpty ? .white.opacity(0.2) : .white.opacity(0.9))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: currentGoal.isEmpty ? .clear : Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                            }
                            .disabled(!isTopTextFieldFocused||currentGoal.isEmpty)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 1)
                )
                .frame(height: 120)
                .padding()
                .onTapGesture {
                    isTopTextFieldFocused = false
                    isBottomTextFieldFocused = false
                }
                
                Spacer()
                
                // MARK: 하단 UI (실패일기 입력 영역 or 노트 상세 팝업)
                if showingNoteDetail, let dogBird = selectedDogBird {
                    PopupNoteDetailView(
                        isPresented: $showingNoteDetail,
                        failureNote: Binding(
                            get: { self.editedNote },
                            set: {
                                self.editedNote = $0
                                dogBird.failureNote = $0
                            }
                        )
                    )
                    .id(dogBird.id)
                    .transition(.move(edge: .bottom))
                }else {
                    HStack(alignment: .top) {
                        TextField("오늘의 실패일기를 작성하세요.", text: $failureNote, axis: .vertical)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(isBottomTextFieldFocused ? .white : .white.opacity(0.7))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .focused($isBottomTextFieldFocused)
                            .onSubmit {
                                if !failureNote.isEmpty {
                                    addDogBird()
                                    isBottomTextFieldFocused = false
                                }
                            }
                        
                        VStack {
                            Button(action: {
                                addDogBird()
                                isBottomTextFieldFocused = false
                            }) {
                                Image(systemName: "plus")
                                    .symbolEffect(.bounce, value: failureNote.isEmpty || failureNote.count > 110)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(failureNote.isEmpty || failureNote.count > 110 ? .gray.opacity(0.2) : .gray)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(failureNote.isEmpty || failureNote.count > 110 ? .white.opacity(0.2) : .white.opacity(0.9))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: failureNote.isEmpty || failureNote.count > 110 ? .clear : Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                            }
                            .disabled(failureNote.isEmpty || failureNote.count > 110)
                            
                            if failureNote.count > 64 {
                                Text("\(failureNote.count)/110")
                                    .font(.caption)
                                    .foregroundColor(
                                        failureNote.count > 110 ? .red : .gray
                                    )
                                    .padding(.top, 4)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 1)
                    )
                    .lineLimit(1...7)
                    .padding()
                    .onTapGesture {
                        isTopTextFieldFocused = false
                        isBottomTextFieldFocused = false
                    }
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .animation(.default, value: failureNote.isEmpty)
        .animation(.default, value: !isTopTextFieldFocused||currentGoal.isEmpty)
        .animation(.default, value: isTopTextFieldFocused)
        .animation(.default, value: isBottomTextFieldFocused)
        .animation(.easeInOut(duration: 0.5), value: showingNoteDetail)
        .animation(.easeInOut(duration: 0.5), value: selectedDogBird?.id)
        .onReceive(timer) { _ in
            updateDogBirdPositions()
        }
    }
    
    // MARK: 개새 추가 함수
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
    
    // MARK: 노트 상세 보기 표시
    private func showNoteDetail(for dogBird: DogBird) {
        selectedDogBird = dogBird
        editedNote = dogBird.failureNote
        showingNoteDetail = true
    }
    
    // MARK: 개새 위치 업데이트
    private func updateDogBirdPositions() {
        for dogBird in dogBirds {
            // 현재 드래그 중인 개새는 건너뜀
            if draggingDogBirdID == dogBird.id {
                continue
            }
            
            if soundManager.soundLevel > 0 {
                // 소리가 감지되면 위로 날아간다
                dogBird.isFlying = true
                var newPosition = dogBird.position
                newPosition.y -= CGFloat(2.0 + (soundManager.soundLevel * 10)) // 소리 크기에 비례해서 더 빨리 올라감
                newPosition.x += CGFloat.random(in: -2...2) // 살짝 좌우 흔들림
                
                // 화면 경계 체크
                if newPosition.x < 20 {
                    newPosition.x = 20
                } else if newPosition.x > fieldSize.width - 20 {
                    newPosition.x = fieldSize.width - 20
                }
                
                if newPosition.y < 20 {
                    newPosition.y = 20
                }
                
                dogBird.position = newPosition
            } else {
                // 소리가 없으면 자유롭게 돌아다님
                dogBird.isFlying = false
                let angle = dogBird.rotation * .pi / 180
                var newPosition = dogBird.position
                
                // 현재 방향으로 이동
                newPosition.x += CGFloat(cos(angle) * dogBird.speed)
                newPosition.y += CGFloat(sin(angle) * dogBird.speed)
                
                // 화면 경계에 닿으면 반대 방향으로 튕김
                var directionChanged = false
                
                if newPosition.x < 20 || newPosition.x > fieldSize.width - 20 {
                    dogBird.rotation = 180 - dogBird.rotation
                    directionChanged = true
                }
                
                if newPosition.y < 20 || newPosition.y > fieldSize.height - 20 {
                    dogBird.rotation = 360 - dogBird.rotation
                    directionChanged = true
                }
                
                // 방향이 변경되었다면 새 방향으로 위치 재계산
                if directionChanged {
                    let newAngle = dogBird.rotation * .pi / 180
                    newPosition.x = dogBird.position.x + CGFloat(cos(newAngle) * dogBird.speed)
                    newPosition.y = dogBird.position.y + CGFloat(sin(newAngle) * dogBird.speed)
                }
                
                // 가끔 랜덤하게 방향 변경 (3% 확률)
                if Int.random(in: 0...100) < 3 {
                    dogBird.rotation = Double.random(in: 0...360)
                }
                
                // 화면 밖에 있으면 화면 안으로 강제 이동
                if newPosition.x < 20 {
                    newPosition.x = 20
                } else if newPosition.x > fieldSize.width - 20 {
                    newPosition.x = fieldSize.width - 20
                }
                
                if newPosition.y < 20 {
                    newPosition.y = 20
                } else if newPosition.y > fieldSize.height - 20 {
                    newPosition.y = fieldSize.height - 20
                }
                
                dogBird.position = newPosition
            }
        }
    }
}
