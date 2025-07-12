//
//  CoinViewModel.swift
//  Crypto
//
//  Created by Harsh Pranay on 12/07/25.
//

import Foundation
import Combine

class CoinViewModel: ObservableObject {
    @Published var allCoins: [Coin] = []
    @Published var watchlistCoins: [Coin] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var dataService = CoinDataService()
    private var refreshTimer: Timer?
    private let userDefaultsKey = "watchlist"
    private var savedWatchlistIds: [String] = []  // Store IDs temporarily

    init() {
        loadWatchlistFromUserDefaults()
        fetchCoins()
        startAutoRefresh()
    }

    deinit {
        stopAutoRefresh()
    }

    // MARK: - Public Methods

    func fetchCoins() {
        isLoading = true
        errorMessage = nil

        dataService.fetchCoins { [weak self] coins in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let coins = coins {
                    self.allCoins = coins
                    self.updateWatchlistCoins()
                } else {
                    self.errorMessage = "Failed to fetch cryptocurrency data"
                }
                self.isLoading = false
            }
        }
    }

    func toggleWatchlist(coin: Coin) {
        if isInWatchlist(coin: coin) {
            watchlistCoins.removeAll { $0.id == coin.id }
        } else {
            if let coinToAdd = allCoins.first(where: { $0.id == coin.id }) {
                watchlistCoins.append(coinToAdd)
            }
        }

        saveWatchlistToUserDefaults()
    }

    func isInWatchlist(coin: Coin) -> Bool {
        return watchlistCoins.contains(where: { $0.id == coin.id })
    }

    // MARK: - Private Methods

    private func startAutoRefresh() {
        // Create a timer that fires every 60 seconds
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.fetchCoins()
        }
    }

    private func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    private func updateWatchlistCoins() {
        // If we have saved IDs from UserDefaults, use them to populate the watchlist
        if !savedWatchlistIds.isEmpty {
            watchlistCoins = savedWatchlistIds.compactMap { id in
                allCoins.first(where: { $0.id == id })
            }
            // Clear the saved IDs as we've now used them
            savedWatchlistIds = []
        } else {
            // Get the latest data for already watchlisted coins
            let watchlistIds = watchlistCoins.map { $0.id }
            watchlistCoins = allCoins.filter { watchlistIds.contains($0.id) }
        }
    }

    private func saveWatchlistToUserDefaults() {
        let watchlistIds = watchlistCoins.map { $0.id }
        UserDefaults.standard.set(watchlistIds, forKey: userDefaultsKey)
    }

    private func loadWatchlistFromUserDefaults() {
        guard let watchlistIds = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] else {
            return
        }

        // Store the IDs to use after coins are fetched
        self.savedWatchlistIds = watchlistIds

        // If we already have coins loaded, update the watchlist immediately
        if !allCoins.isEmpty {
            watchlistCoins = watchlistIds.compactMap { id in
                allCoins.first(where: { $0.id == id })
            }
        }
    }
}
