//
//  TimePeriod.swift
//  finance
//
//  Unified time period enum for the app.
//  Merges PeriodType (from HomeViewModel) and TimePeriod (from AnalyticsView).
//

import Foundation

// MARK: - Time Period (for HomeView period selection)
enum PeriodType: String, CaseIterable, Identifiable {
    case day = "День"
    case week = "Неделя"
    case month = "Месяц"
    case year = "Год"
    case last7Days = "Последние 7 дней"
    case last30Days = "Последние 30 дней"
    case allTime = "Все время"
    case custom = "Пользовательский"

    var id: String { rawValue }

    var canNavigate: Bool {
        switch self {
        case .day, .week, .month, .year:
            return true
        case .last7Days, .last30Days, .allTime, .custom:
            return false
        }
    }
}

// MARK: - Analytics Time Period (for AnalyticsView)
enum AnalyticsTimePeriod: String, CaseIterable {
    case today = "Today"
    case week = "Week"
    case twoWeeks = "2 Weeks"
    case month = "Month"
    case threeMonths = "3 Months"

    var days: Int {
        switch self {
        case .today: return 1
        case .week: return 7
        case .twoWeeks: return 14
        case .month: return 30
        case .threeMonths: return 90
        }
    }
}

// MARK: - Trend Direction
enum TrendDirection: String, CaseIterable {
    case up
    case down
}
