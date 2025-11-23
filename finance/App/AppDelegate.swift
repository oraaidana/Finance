//
//  AppDelegate.swift
//  finance
//
//  Created on 11/21/25.
//
//  Deep link support - commented out for now

/*
import UIKit
import SwiftUI
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Handle deep links when app is launched from a URL
        return true
    }
    
    // Handle universal links
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        
        // Handle Firebase email verification/reset password links
        if Auth.auth().isSignIn(withEmailLink: url.absoluteString) {
            // This is a Firebase email link
            DeepLinkManager.shared.handleURL(url)
            return true
        }
        
        return false
    }
    
    // Handle custom URL schemes
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle custom URL scheme (e.g., qarzhyai://forgot-password)
        DeepLinkManager.shared.handleURL(url)
        return true
    }
}
*/

