//
//  TypingIndicatorView.swift
//  AIChatBuddy
//
//  Created by Yassine Lamtalaa on 6/13/25.
//

import SwiftUI

struct TypingIndicatorView: View {
    @State private var dotCount = 0
    private let maxDots = 3
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        Text("Typing" + String(repeating: ".", count: dotCount))
            .font(.headline)
            .foregroundColor(.gray)
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 0.4)) {
                    dotCount = (dotCount + 1) % (maxDots + 1)
                }
            }
    }
}
