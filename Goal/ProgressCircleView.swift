//
//  CircularProgressView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/30.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    var total: Double
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(.gray)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress / self.total, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            
            Text(String(format: "%.0f %%", min(self.progress / self.total, 1.0)*100.0))
                .font(.title)
                .bold()
        }
    }
}


struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(progress: 100, total: 10)
            .frame(width: 100, height: 100)
    }
}


