//
//  DogBird.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//

import SwiftUI
import SwiftData

@Model
class DogBird: Identifiable {
    var id = UUID()
    var name: String = "이름없는 개새"
    
    // CGPoint 대신 개별 속성으로 저장
    var x: Double
    var y: Double
    
    var failureNote: String
    var isFlying: Bool = false
    var rotation: Double = Double.random(in: 0...360)
    var speed: Double = Double.random(in: 1...3)
    var size: CGFloat = CGFloat.random(in: 100...160)

    var position: CGPoint {
        get { CGPoint(x: x, y: y) }
        set {
            x = newValue.x
            y = newValue.y
        }
    }

    init(id: UUID = UUID(), position: CGPoint, failureNote: String) {
        self.id = id
        self.x = position.x
        self.y = position.y
        self.failureNote = failureNote
    }
}
