//
//  ContentView.swift
//  Crypto
//
//  Created by Harsh Pranay on 12/07/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: CoinViewModel
    @State private var selectedTab = 0
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        TabView(selection: $selectedTab) {
            // Coin List Tab
            CoinListView()
                .tabItem {
                    Label("Coins", systemImage: "bitcoinsign.circle")
                }
                .tag(0)

            // Watchlist Tab
            WatchlistView()
                .tabItem {
                    Label("Watchlist", systemImage: "star")
                }
                .tag(1)
        }
        .accentColor(.blue)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isDarkMode.toggle()
                }) {
                    Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                }
            }
        }
        .alert(item: errorBinding) { errorMessage in
            Alert(
                title: Text("Error"),
                message: Text(errorMessage.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var errorBinding: Binding<ErrorMessage?> {
        Binding<ErrorMessage?>(
            get: {
                viewModel.errorMessage.map { ErrorMessage(message: $0) }
            },
            set: { _ in
                viewModel.errorMessage = nil
            }
        )
    }
}

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CoinViewModel())
    }
}

