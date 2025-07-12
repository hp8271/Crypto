//
//  CoinListView.swift
//  Crypto
//
//  Created by Harsh Pranay on 12/07/25.
//

import SwiftUI

struct CoinListView: View {
    @EnvironmentObject private var viewModel: CoinViewModel
    @State private var searchText = ""
    @State private var isRefreshing = false
    @State private var refreshText = "Pull to refresh"

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.clear
                    .edgesIgnoringSafeArea(.all)

                // Content
                VStack(spacing: 0) {
                    // Manual refresh control
                    RefreshControl(isRefreshing: $isRefreshing, refreshText: $refreshText) {
                        Task {
                            await manualRefresh()
                        }
                    }
                    .padding(.vertical, isRefreshing ? 10 : 0)
                    .zIndex(1) // Ensure refresh control stays above the list

                    // List of coins
                    List {
                        ForEach(filteredCoins) { coin in
                            CoinRowView(
                                coin: coin,
                                isInWatchlist: viewModel.isInWatchlist(coin: coin),
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

                // Loading view
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .navigationTitle("Crypto Tracker")
            .searchable(text: $searchText, prompt: "Search coins")
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

    private var filteredCoins: [Coin] {
        if searchText.isEmpty {
            return viewModel.allCoins
        } else {
            return viewModel.allCoins.filter { coin in
                coin.name.localizedCaseInsensitiveContains(searchText) ||
                coin.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private func refreshData() async {
        await withCheckedContinuation { continuation in
            viewModel.fetchCoins()
            continuation.resume()
        }
    }

    private func manualRefresh() async {
        isRefreshing = true
        refreshText = "Refreshing..."

        await refreshData()

        // Simulate a short delay to show the completion message
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        refreshText = "Updated!"

        // Reset after showing the completion message
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        refreshText = "Pull to refresh"
        isRefreshing = false
    }
}

// MARK: - Custom Refresh Control
struct RefreshControl: View {
    @Binding var isRefreshing: Bool
    @Binding var refreshText: String
    var onRefresh: () -> Void

    @State private var dragOffset: CGFloat = 0
    private let refreshThreshold: CGFloat = 80

    var body: some View {
        GeometryReader { geometry in
            // Only show content when dragging or refreshing
            if dragOffset > 0 || isRefreshing {
                VStack {
                    VStack(spacing: 8) {
                        if isRefreshing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.2)
                        } else {
                            Image(systemName: dragOffset > refreshThreshold ? "arrow.up.circle.fill" : "arrow.down.circle")
                                .font(.title2)
                                .foregroundColor(dragOffset > refreshThreshold ? .green : .gray)
                                .rotationEffect(.degrees(dragOffset > refreshThreshold ? 0 : 180))
                                .animation(.spring(), value: dragOffset > refreshThreshold)
                        }

                        Text(refreshText)
                            .font(.subheadline)
                            .foregroundColor(isRefreshing || dragOffset > refreshThreshold ? .primary : .secondary)
                    }
                    .frame(height: min(dragOffset, 120))
                    .frame(width: geometry.size.width)
                    .opacity(min(1, dragOffset / 40))
                    Spacer()
                }
                .offset(y: -dragOffset)
                .animation(.spring(), value: isRefreshing)
            }
        }
        .frame(height: 0) // No fixed height
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isRefreshing {
                        dragOffset = max(0, value.translation.height)
                    }
                }
                .onEnded { value in
                    if dragOffset > refreshThreshold && !isRefreshing {
                        onRefresh()
                    }
                    if !isRefreshing {
                        withAnimation {
                            dragOffset = 0
                        }
                    }
                }
        )
    }
}
