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
                    .trim(from: 0.0, to: 0.6)
                    .stroke(Color.red, lineWidth: 8)
                    .frame(width: geometry.size.width / 2, height: geometry.size.height / 2)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(Animation.timingCurve(0.6, 0.25 + Double(index) / 6.0, 0.25, 0.4, duration: 1.3)
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
