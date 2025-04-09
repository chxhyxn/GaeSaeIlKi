//
//  VolumeRingView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//

import SwiftUI

struct VolumeRingView: View {
    var decibel: Float

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.white.opacity(0.8), lineWidth: 2 + CGFloat(decibel) * 3)
                .frame(width: CGFloat(100 + (decibel * 100)),
                       height: CGFloat(100 + (decibel * 100)))
                .scaleEffect(1 + CGFloat(decibel) * 0.3)
                .opacity(0.5 + Double(decibel) * 0.5)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: decibel)
        }
    }
}
