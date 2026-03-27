import SwiftUI

/// End of shift summary screen
struct ShiftResultView: View {
    @EnvironmentObject var game: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Shift Complete")
                    .font(.headline)

                if let result = game.lastDecisionResult {
                    // We show aggregate stats from the game manager
                }

                // Stats
                VStack(spacing: 4) {
                    statRow("Correct", "\(game.gameState.totalCorrectDecisions)", color: .green)
                    statRow("Mistakes", "\(game.gameState.totalMistakes)", color: .red)
                    statRow("Money", "\(game.gameState.economy.money)", color: .yellow)
                    statRow("Prestige", "\(game.gameState.economy.prestige)", color: .purple)
                }

                Divider()

                // Status indicators
                HStack(spacing: 12) {
                    statusIcon("fork.knife", game.gameState.economy.hunger.displayName)
                    statusIcon("drop.fill", game.gameState.economy.hygiene.displayName)
                    statusIcon("sparkles", game.gameState.economy.luxury.displayName)
                }
                .font(.system(size: 9))

                Button("Pay Expenses") {
                    game.currentScreen = .expenses
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Results")
    }

    private func statRow(_ label: String, _ value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
    }

    private func statusIcon(_ icon: String, _ text: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 8))
        }
        .foregroundStyle(.secondary)
    }
}
