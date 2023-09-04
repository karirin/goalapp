//
//  HugginFaceProgressCircle.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/07/20.
//

import SwiftUI

struct HugginFaceProgressCircle: View {
    @State private var rotationDegrees: [Double] = [0, 0, 0]
    @State private var startTrim: [CGFloat] = [0, 0, 0]
    @State private var trimTo: CGFloat = 240.0 / 360.0
    @State private var shouldRotate = true
    @State private var opacity = 1.0

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    @State private var percentage: Int = 0
    let timer2 = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    @State private var expandGreenCircle = false

    var body: some View {
        ZStack {
//            Text("\(percentage)%")
//                .font(.system(size: 30)) // smaller font size
//                .opacity(opacity)
//                .onReceive(timer2) { _ in
//                    if percentage < 100 {
//                        percentage += Int.random(in: 1...5)
//                        if percentage >= 100 {
//                            percentage = 100
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                withAnimation(.linear(duration: 1.0)) {
//                                    trimTo = 1.0 // Trim all the way when it reaches 100%
//                                    shouldRotate = false // Stop rotation when it reaches 100%
//                                    expandGreenCircle = true
//                                }
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                    withAnimation(.linear(duration: 0.4)) {
//                                        self.opacity = 0
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }

//            ForEach(0..<3) { index in
                Circle()
                    .trim(from: 0, to: trimTo)
                    .stroke(lineWidth: 3)
                    .frame(width: CGFloat(100 + 30), height: CGFloat(100 + 30))
                    .foregroundColor(Color(.red))
                    .rotationEffect(Angle.degrees(CGFloat(50)+rotationDegrees[0]))
                    .animation(shouldRotate ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default)
                    .opacity(opacity)
//            }
        }
        .onAppear() {
            startTrim = startTrim.map { _ in CGFloat.random(in: 0...1) }
        }
        .onReceive(timer) { _ in
            if shouldRotate {
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotationDegrees = rotationDegrees.enumerated().map { index, degree in
                        degree + (50.0 * Double(1 - Double(index) * 0.2))
                    }
                }
            }
        }
    }
}

struct HugginFaceProgressCircle_Previews: PreviewProvider {
    static var previews: some View {
        HugginFaceProgressCircle()
    }
}
