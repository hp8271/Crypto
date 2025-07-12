//
//  WatchlistView.swift
//  Crypto
//
//  Created by Harsh Pranay on 12/07/25.
//

import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject private var viewModel: CoinViewModel

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.clear
                    .edgesIgnoringSafeArea(.all)

                // Content
                VStack {
                    if viewModel.watchlistCoins.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "star.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)

                            Text("Your watchlist is empty")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text("Add coins by tapping the star icon")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        // List of watchlisted coins
                        List {
                            ForEach(viewModel.watchlistCoins) { coin in
                                CoinRowView(
                                    coin: coin,
                                    isInWatchlist: true,
                                    onToggleWatchlist: {
                                        viewModel.toggleWatchlist(coin: coin)
                                    }
                                )
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
                            await refreshData()
                        }
                    }
                }

                // Loading view
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .navigationTitle("Watchlist")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await refreshData()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }

    private func refreshData() async {
        await withCheckedContinuation { continuation in
            viewModel.fetchCoins()
            continuation.resume()
        }
    }
}
