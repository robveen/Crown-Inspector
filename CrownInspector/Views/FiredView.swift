import SwiftUI

/// Shown when the player gets fired due to poor hygiene/luxury
struct FiredView: View {
    @EnvironmentObject var game: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)

                Text("Fired!")
                    .font(.headline)
                    .foregroundStyle(.orange)

                Text("Your employer couldn't tolerate you any longer. You've been demoted.")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Divider()

                HStack {
                    Text("Demoted to:")
                        .font(.caption2)
                    Spacer()
                    Text(game.gameState.currentTier.displayName)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                }

                Button("Continue") {
                    game.acknowledgeFired()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            .padding(.horizontal, 8)
        }
        .navigationTitle("Demoted")
    }
}
