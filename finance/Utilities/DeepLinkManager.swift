//
//  DeepLinkManager.swift
//  finance
//
//  Created on 11/21/25.
//
//  Deep link support - commented out for now

/*
import Foundation
import SwiftUI
import Combine

enum DeepLinkDestination {
    case forgotPassword
    case emailVerification
    case resetPassword(token: String)
    case verifyEmail(actionCode: String)
    case unknown
    
    init?(url: URL) {
        guard let host = url.host else {
            self = .unknown
            return
        }
        
        switch host {
        case "forgot-password":
            self = .forgotPassword
        case "verify-email":
            // Extract action code from query parameters
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let actionCode = components.queryItems?.first(where: { $0.name == "oobCode" })?.value {
                self = .verifyEmail(actionCode: actionCode)
            } else {
                self = .emailVerification
            }
        case "reset-password":
            // Extract token from query parameters
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let token = components.queryItems?.first(where: { $0.name == "oobCode" })?.value {
                self = .resetPassword(token: token)
            } else {
                self = .forgotPassword
            }
        default:
            self = .unknown
        }
    }
}

class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()
    
    @Published var destination: DeepLinkDestination?
    @Published var shouldNavigate = false
    
    private init() {}
    
    func handleURL(_ url: URL) {
        destination = DeepLinkDestination(url: url)
        shouldNavigate = true
    }
    
    func reset() {
        destination = nil
        shouldNavigate = false
    }
}
*/

