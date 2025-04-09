//
//  DogBird.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//

import SwiftUI

struct DogBird: Identifiable {
    var id = UUID()
    var position: CGPoint
    var failureNote: String
    var isFlying: Bool = false
    var rotation: Double = Double.random(in: 0...360)
    var speed: Double = Double.random(in: 1...3)
    var size: CGFloat = CGFloat.random(in: 100...160)
}
