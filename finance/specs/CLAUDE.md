# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

QarzhyAI is a SwiftUI finance tracker app with ML integration for bank statement parsing and financial recommendations. The app uses Firebase for authentication.

## Build Commands

```bash
# Build the project
xcodebuild -project ../finance.xcodeproj -scheme finance build

# Run tests
xcodebuild -project ../finance.xcodeproj -scheme finance test

# Build for simulator
xcodebuild -project ../finance.xcodeproj -scheme finance -destination 'platform=iOS Simulator,name=iPhone 15'
```

Open `finance.xcodeproj` in Xcode for development. The project requires:
- Firebase SDK (configured via `GoogleService-Info.plist` in `App/`)
- Swift Charts framework

## Architecture

**MVVM Pattern**: The app follows Model-View-ViewModel architecture.

### App Flow
`financeApp.swift` → `RootView.swift` (manages AppState) → Views

**AppState enum** controls navigation through: `splash` → `onboarding` → `login` → `emailVerification` → `main`

### Key Directories
- `App/` - App entry point and Firebase configuration
- `Models/` - Data models (`User`, transaction types)
- `Views/` - SwiftUI views organized by feature (Auth/, Dashboard/, Budget/, Chat/, Account/, Shared/)
- `ViewModels/` - View models (currently mostly empty, logic in `SharedDataManager`)
- `Services/` - `FirebaseAuthService` implements `AuthServiceProtocol`
- `Utilities/` - Managers (`AuthManager`, `OnboardingManager`, `DeepLinkManager`)

### State Management
- **AuthManager** (singleton): Manages Firebase auth state, publishes `isAuthenticated`, `currentUser`, `isLoading`, `errorMessage`
- **SharedDataManager** (EnvironmentObject): Manages transaction data, calculates totals, category spending, trends

### Authentication Flow
`FirebaseAuthService` → `AuthServiceProtocol` → `AuthManager` (singleton, observed by views)

Email verification is required after signup before accessing main content.

## Planned ML Integration Points

The app is designed to integrate ML for:
- Bank statement parsing and categorization
- Financial recommendations in Analytics
- Chat responses for financial queries

ML integration hooks should be added in Services/ with a protocol-based approach similar to `AuthServiceProtocol`.

## Code Style

- Use SwiftUI and Combine
- Follow MVVM pattern
- Singletons for services (`AuthManager.shared`, `FirebaseAuthService.shared`)
- EnvironmentObjects for shared view state
- Async/await for asynchronous operations
