//
//  Coin.swift
//  Crypto
//
//  Created by Harsh Pranay on 12/07/25.
//

import Foundation

struct Coin: Identifiable, Codable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let current_price: Double
    let price_change_percentage_24h: Double?
    let last_updated: String

    // Computed property to format price as a currency string
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: current_price)) ?? "$\(current_price)"
    }

    // Computed property to determine if price change is positive
    var isPriceChangePositive: Bool {
        return (price_change_percentage_24h ?? 0) >= 0
    }

    // Computed property to format price change percentage
    var formattedPriceChangePercentage: String {
        guard let priceChange = price_change_percentage_24h else {
            return "N/A"
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2

        guard let formattedString = formatter.string(from: NSNumber(value: abs(priceChange))) else {
            return "\(priceChange)%"
        }

        return (priceChange >= 0 ? "+" : "-") + formattedString + "%"
    }
}
