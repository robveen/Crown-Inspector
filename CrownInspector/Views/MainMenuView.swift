import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var game: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Image(systemName: "crown.fill")
                    .font(.title3)
                    .foregroundStyle(.yellow)

                Text("Crown Inspector")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("Steven Stampman")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Divider()

                Button {
                    game.continueGame()
                } label: {
                    Label("Continue", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(game.gameState.totalShiftsCompleted == 0)

                Button {
                    game.startNewGame()
                } label: {
                    Label("New Game", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                // Stats preview
                if game.gameState.totalShiftsCompleted > 0 {
                    VStack(alignment: .leading, spacing: 3) {
                        statRow("Money", "\(game.gameState.economy.money)", icon: "dollarsign.circle")
                        statRow("Prestige", "\(game.gameState.economy.prestige)", icon: "star.fill")
                        statRow("Rank", game.gameState.currentTier.displayName, icon: "crown")
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 4)
        }
        .onAppear {
            GameCenterManager.shared.authenticate()
        }
    }

    private func statRow(_ label: String, _ value: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
                .frame(width: 12)
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
