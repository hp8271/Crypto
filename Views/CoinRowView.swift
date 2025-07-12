//
//  CoinRowView.swift
//  Crypto
//
//  Created by Harsh Pranay on 12/07/25.
//

import SwiftUI

struct CoinRowView: View {
    let coin: Coin
    let isInWatchlist: Bool
    var onToggleWatchlist: () -> Void

    var body: some View {
        HStack {
            // Coin rank and image
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: coin.image)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                    } else if phase.error != nil {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(coin.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(coin.symbol.uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Price info
            VStack(alignment: .trailing, spacing: 4) {
                Text(coin.formattedPrice)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(coin.formattedPriceChangePercentage)
                    .font(.caption)
                    .foregroundColor(coin.isPriceChangePositive ? .green : .red)
            }

            // Watchlist button
            Button(action: onToggleWatchlist) {
                Image(systemName: isInWatchlist ? "star.fill" : "star")
                    .foregroundColor(isInWatchlist ? .yellow : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.leading, 8)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}
