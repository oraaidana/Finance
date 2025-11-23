//
//  OnboardingManager.swift
//  finance
//
//  Created on 11/21/25.
//

import Foundation

class OnboardingManager {
    private static let hasSeenOnboardingKey = "hasSeenOnboarding"
    
    static var hasSeenOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasSeenOnboardingKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSeenOnboardingKey)
        }
    }
    
    static func markOnboardingAsSeen() {
        hasSeenOnboarding = true
    }
    
    static func resetOnboarding() {
        hasSeenOnboarding = false
    }
}

