//
//  CoinDataService.swift
//  Crypto
//
//  Created by Harsh Pranay on 12/07/25.
//

import Foundation

class CoinDataService {
    private let baseURL = "https://api.coingecko.com/api/v3/coins/markets"

    func fetchCoins(completion: @escaping ([Coin]?) -> Void) {
        let urlString = "\(baseURL)?vs_currency=usd&order=market_cap_desc&per_page=20&page=1&sparkline=false&price_change_percentage=24h"

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching coins: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            do {
                let coins = try JSONDecoder().decode([Coin].self, from: data)
                completion(coins)
            } catch {
                print("Error decoding coins: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
