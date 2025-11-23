//
//  OnboardingView.swift
//  finance
//
//  Created on 11/21/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var hasSeenOnboarding: Bool
    
    let pages = [
        OnboardingPage(
            title: "Track Your Expenses",
            description: "Easily monitor your spending and income with our intuitive interface",
            imageName: "chart.pie.fill",
            color: .blue
        ),
        OnboardingPage(
            title: "Smart Budget Planning",
            description: "Set budgets and get insights to help you save money and reach your goals",
            imageName: "dollarsign.circle.fill",
            color: .green
        ),
        OnboardingPage(
            title: "AI-Powered Insights",
            description: "Get personalized financial advice and recommendations from our AI assistant",
            imageName: "sparkles",
            color: .purple
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button at top
                HStack {
                    Spacer()
                    Button(action: {
                        skipOnboarding()
                    }) {
                        HStack(spacing: 6) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                }
                .padding(.top, 20)
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom section with dots and button
                VStack(spacing: 20) {
                    // Page indicator dots
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Next/Get Started button
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    private func skipOnboarding() {
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        OnboardingManager.markOnboardingAsSeen()
        hasSeenOnboarding = true
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon/Image
            Image(systemName: page.imageName)
                .font(.system(size: 120, weight: .light))
                .foregroundColor(page.color)
                .padding(.bottom, 20)
            
            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Description
            Text(page.description)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(4)
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}

