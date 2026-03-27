import SwiftUI

/// Game over screen when the player goes bankrupt
struct GameOverView: View {
    @EnvironmentObject var game: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Image(systemName: "hand.thumbsdown.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.red)

                Text("Bankrupt!")
                    .font(.headline)
                    .foregroundStyle(.red)

                Text("Steven Stampman's dream of becoming the Crown Inspector has ended... for now.")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Divider()

                VStack(spacing: 4) {
                    statRow("Shifts Worked", "\(game.gameState.totalShiftsCompleted)")
                    statRow("Highest Rank", game.gameState.highestUnlockedTier.displayName)
                    statRow("Lifetime Earnings", "\(game.gameState.lifetimeEarnings)")
                    statRow("Peak Prestige", "\(game.gameState.lifetimePrestige)")
                }

                Button("Try Again") {
                    game.startNewGame()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(.horizontal, 8)
        }
        .navigationTitle("Game Over")
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption2)
                .fontWeight(.bold)
        }
    }
}
