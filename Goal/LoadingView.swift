//
//  LoadingView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/07/10.
//

import SwiftUI

struct LoadingView: View {
    private let scaleEffect: CGFloat

    init(_ scaleEffect: CGFloat) {
        self.scaleEffect = scaleEffect
    }
    
    var body: some View {
        VStack {
            ProgressView() // This displays a spinning progress indicator.
                .progressViewStyle(.circular)
                .scaleEffect(scaleEffect)
                .frame(width: scaleEffect * 20, height: scaleEffect * 20)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(3)
    }
}
