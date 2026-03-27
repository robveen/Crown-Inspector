import SwiftUI

/// End of shift summary screen
struct ShiftResultView: View {
    @EnvironmentObject var game: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Shift Complete")
                    .font(.headline)

                // Mode-specific header
                if game.currentGameMode == .endless {
                    HStack {
                        Text("Score:")
                            .font(.caption)
                        Text("\(game.endlessScore)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.yellow)
                    }
                } else if game.currentGameMode == .timeTrial {
                    Text("Time Trial")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }

                // Stats
                VStack(spacing: 4) {
                    statRow("Correct", "\(game.gameState.totalCorrectDecisions)", color: .green)
                    statRow("Mistakes", "\(game.gameState.totalMistakes)", color: .red)

                    if game.currentGameMode == .career {
                        statRow("Money", "\(game.gameState.economy.money)", color: .yellow)
                        statRow("Prestige", "\(game.gameState.economy.prestige)", color: .purple)
                    }
                }

                if game.currentGameMode == .career {
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
                } else {
                    Button("Play Again") {
                        game.currentScreen = .modeSelect
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Button("Menu") {
                        game.currentScreen = .mainMenu
                    }
                    .buttonStyle(.bordered)
                }
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
