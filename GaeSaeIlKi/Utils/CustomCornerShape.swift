//
//  CustomCornerShape.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//

import SwiftUI

struct CustomCornerShape: Shape {
    var topLeft: CGSize = .zero
    var topRight: CGSize = .zero
    var bottomLeft: CGSize = .zero
    var bottomRight: CGSize = .zero

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let tl = topLeft
        let tr = topRight
        let bl = bottomLeft
        let br = bottomRight

        path.move(to: CGPoint(x: rect.minX + tl.width, y: rect.minY))

        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX - tr.width, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + tr.height),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )

        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br.height))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - br.width, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: rect.minX + bl.width, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - bl.height),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )

        // Left edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl.height))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + tl.width, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )

        return path
    }
}
