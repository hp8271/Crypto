//
//  CryptoApp.swift
//  Crypto
//
//  Created by Harsh Pranay on 12/07/25.
//

import SwiftUI

@main
struct CryptoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(CoinViewModel())
        }
    }
}
