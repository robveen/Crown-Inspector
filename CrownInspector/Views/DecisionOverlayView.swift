import SwiftUI

/// Brief overlay shown after making a decision
struct DecisionOverlayView: View {
    let result: DecisionResult

    var body: some View {
        VStack(spacing: 4) {
            // Stamp icon
            Image(systemName: result.wasCorrect ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.system(size: 24))
                .foregroundStyle(result.wasCorrect ? .green : .red)
                .symbolEffect(.bounce, value: result.wasCorrect)

            Text(result.reason)
                .font(.system(size: 10, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            HStack(spacing: 8) {
                Label(
                    "\(result.moneyChange > 0 ? "+" : "")\(result.moneyChange)",
                    systemImage: "dollarsign.circle"
                )
                .foregroundStyle(result.moneyChange >= 0 ? .green : .red)

                Label(
                    "\(result.prestigeChange > 0 ? "+" : "")\(result.prestigeChange)",
                    systemImage: "star.fill"
                )
                .foregroundStyle(result.prestigeChange >= 0 ? .yellow : .red)
            }
            .font(.system(size: 9, weight: .bold))
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
        .transition(.scale.combined(with: .opacity))
    }
}
