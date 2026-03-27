import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var game: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
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
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Money:")
                                .font(.caption2)
                            Spacer()
                            Text("\(game.gameState.economy.money)")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        HStack {
                            Text("Prestige:")
                                .font(.caption2)
                            Spacer()
                            Text("\(game.gameState.economy.prestige)")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        HStack {
                            Text("Rank:")
                                .font(.caption2)
                            Spacer()
                            Text(game.gameState.currentTier.displayName)
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 4)
        }
    }
}
