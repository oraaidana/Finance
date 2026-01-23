//
//  SplashView.swift
//  finance
//
//  Created on 11/21/25.
//

import SwiftUI

struct SplashView: View {
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.3
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Background color - can be white or a gradient
            Color.appCardBackground
                .ignoresSafeArea()

            // Dollar icon in the middle with animation
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 100, weight: .medium))
                .foregroundColor(.appPrimary)
                .opacity(opacity)
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Initial state: invisible, small, and slightly rotated
        opacity = 0
        scale = 0.3
        rotation = -10
        
        // Animate in: fade in, scale up, and rotate to center
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            opacity = 1.0
            scale = 1.0
            rotation = 0
        }
        
        // Add a subtle pulse effect after initial animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.4).repeatCount(1, autoreverses: true)) {
                scale = 1.05
            }
        }
    }
}

#Preview {
    SplashView()
}

