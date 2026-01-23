import Foundation

struct CurrencyFormatter {
    static let shared = CurrencyFormatter()

    private let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f
    }()

    enum Currency: String {
        case kzt = "KZT"
        case usd = "USD"
        case eur = "EUR"
        case rub = "RUB"

        var symbol: String {
            switch self {
            case .kzt: return "₸"
            case .usd: return "$"
            case .eur: return "€"
            case .rub: return "₽"
            }
        }
    }

    func format(_ value: Double, currency: Currency = .kzt, showDecimals: Bool = false) -> String {
        formatter.currencyCode = currency.rawValue
        formatter.currencySymbol = currency.symbol
        formatter.maximumFractionDigits = showDecimals ? 2 : 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(currency.symbol)0"
    }
}
