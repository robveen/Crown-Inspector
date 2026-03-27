import SwiftUI

/// The main gameplay view — split screen with Digital Crown controls
struct ShiftView: View {
    @EnvironmentObject var game: GameManager

    var body: some View {
        VStack(spacing: 0) {
            // Top: Timer bar
            timerBar

            if let person = game.currentPerson {
                // Split screen: document on top, person on bottom
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        // Top half: Document
                        DocumentCardView(document: person.document, minimumAge: game.currentScreen == .shift ? 18 : nil)
                            .frame(height: geo.size.height * 0.45)

                        Divider()
                            .background(Color.white.opacity(0.3))

                        // Bottom half: Person's actual appearance
                        PersonCardView(person: person)
                            .frame(height: geo.size.height * 0.45)

                        // Stamp indicator
                        stampIndicator
                            .frame(height: geo.size.height * 0.1)
                    }
                }
            }
        }
        .focusable()
        .digitalCrownRotation(
            $game.crownRotation,
            from: -1.0,
            through: 1.0,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: game.crownRotation) { _, newValue in
            game.updateCrownValue(newValue)

            // Auto-commit when threshold is fully reached
            if abs(newValue) >= 0.95 && game.stampState != .stamped {
                game.commitDecision()
            }
        }
        .navigationBarHidden(true)

        // Show result overlay
        if game.showingResult, let result = game.lastDecisionResult {
            DecisionOverlayView(result: result)
        }
    }

    // MARK: - Subviews

    private var timerBar: some View {
        HStack {
            // Time remaining
            let minutes = Int(game.shiftTimeRemaining) / 60
            let seconds = Int(game.shiftTimeRemaining) % 60
            Text(String(format: "%d:%02d", minutes, seconds))
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(game.shiftTimeRemaining < 10 ? .red : .white)

            Spacer()

            // Money indicator
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 10))
                .foregroundStyle(.yellow)
            Text("\(game.gameState.economy.money)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(Color.black.opacity(0.6))
    }

    private var stampIndicator: some View {
        HStack {
            if game.stampState == .approving || game.stampState == .stamped && game.lastDecisionResult?.decision == .approved {
                Text("APPROVE")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(.green)
            } else if game.stampState == .denying || game.stampState == .stamped && game.lastDecisionResult?.decision == .denied {
                Text("DENY")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(.red)
            } else {
                Text("Scroll Crown")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
