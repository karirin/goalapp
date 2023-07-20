//
//  LoadingView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/07/10.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<5) { index in
                Circle()
                    .trim(from: 0.0, to: 0.1)
                    .stroke(Color.red, lineWidth: 4)
                    .frame(width: geometry.size.width / 2, height: geometry.size.height / 2)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(Animation.timingCurve(0.9, 0.25 + Double(index) / 5.0, 0.25, 1.0, duration: 2.3)
//                        .animation(Animation.linear(duration: 1.0)
                        .repeatForever(autoreverses: false))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            self.isAnimating = true
        }
    }
}


struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
