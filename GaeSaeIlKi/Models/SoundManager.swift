//
//  SoundManager.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//

import SwiftUI
import AVFoundation

class SoundManager: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    @Published var soundLevel: Float = 0.0
    let threshold: Float = 0.3 // 소리 감지 임계값 (낮춤)
    
    init() {
        setupAudioRecorder()
    }
    
    private func setupAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // 권한 요청을 명시적으로 처리
            print("오디오 권한 요청 중...")
            try audioSession.requestRecordPermission { granted in
                if granted {
                    print("마이크 권한 승인됨")
                } else {
                    print("마이크 권한 거부됨")
                }
            }
            
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false
            ]
            
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentPath.appendingPathComponent("soundMeter.wav")
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            
            startMonitoring()
        } catch {
            print("오디오 레코더 설정 오류: \(error.localizedDescription)")
        }
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.audioRecorder?.updateMeters()
            let power = self.audioRecorder?.averagePower(forChannel: 0) ?? -160
            self.soundLevel = power + 160  // 0-160 사이의 값으로 정규화
            
            // 디버깅용 로그 (큰 소리가 감지될 때만)
            if power > -50 {
                print("큰 소리 감지: \(power) dB (정규화: \(self.soundLevel))")
            }
        }
    }
    
    func isShouting() -> Bool {
        // 디버깅을 위해 로그 추가
        print("현재 소리 레벨: \(soundLevel), 임계값: \(threshold * 160)")
        return soundLevel > threshold * 150
    }
    
    deinit {
        timer?.invalidate()
        audioRecorder?.stop()
    }
}
