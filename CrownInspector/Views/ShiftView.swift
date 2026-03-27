import SwiftUI

/// The main gameplay view — vertical split with Digital Crown controls
/// Document on the right (Crown side), person on the left
struct ShiftView: View {
    @EnvironmentObject var game: GameManager
    @Environment(\.isLuminanceReduced) var isLuminanceReduced

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top: Timer bar
                timerBar

                if let person = game.currentPerson, !game.isTransitioningPerson {
                    // Vertical split: person LEFT, document RIGHT (Crown side)
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            // Left side: Person at the gate
                            PersonCardView(person: person)
                                .frame(width: geo.size.width * 0.5)

                            // Divider line
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 1)

                            // Right side: Document (Crown side for stamping)
                            DocumentCardView(
                                document: person.document,
                                minimumAge: game.currentEvent?.minimumAge
                            )
                            .frame(width: geo.size.width * 0.5 - 1)
                        }
                    }
                } else {
                    // Transition state — person walking in/out
                    Spacer()
                    if game.isTransitioningPerson {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                    Spacer()
                }

                // Bottom: Stamp indicator
                stampBar
            }
            .offset(game.screenShakeOffset)

            // Result overlay
            if game.showingResult, let result = game.lastDecisionResult {
                DecisionOverlayView(result: result)
                    .transition(.scale.combined(with: .opacity))
            }

            // Endless mode lives
            if game.currentGameMode == .endless {
                VStack {
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < game.endlessLives ? "heart.fill" : "heart")
                                .font(.system(size: 8))
                                .foregroundStyle(i < game.endlessLives ? .red : .gray)
                        }
                    }
                    .padding(.bottom, 2)
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
            if abs(newValue) >= 0.95 && game.stampState != .stamped && !game.isTransitioningPerson {
                game.commitDecision()
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Timer Bar

    private var timerBar: some View {
        HStack(spacing: 4) {
            if game.currentGameMode == .endless {
                Image(systemName: "infinity")
                    .font(.system(size: 10, weight: .bold))
                Text("Score: \(game.endlessScore)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
            } else {
                let minutes = Int(game.shiftTimeRemaining) / 60
                let seconds = Int(game.shiftTimeRemaining) % 60
                Text(String(format: "%d:%02d", minutes, seconds))
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(game.shiftTimeRemaining < 10 ? .red : .white)
            }

            Spacer()

            if game.currentGameMode == .career {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.yellow)
                Text("\(game.gameState.economy.money)")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.black.opacity(0.7))
    }

    // MARK: - Stamp Bar

    private var stampBar: some View {
        HStack(spacing: 0) {
            // Intensity meter (left)
            stampIntensityBar
                .frame(width: 30)

            Spacer()

            // Stamp label
            Group {
                switch game.stampState {
                case .approving:
                    Text("APPROVE")
                        .foregroundStyle(.green)
                case .denying:
                    Text("DENY")
                        .foregroundStyle(.red)
                case .stamped:
                    if game.lastDecisionResult?.decision == .approved {
                        Text("APPROVED")
                            .foregroundStyle(.green)
                    } else {
                        Text("DENIED")
                            .foregroundStyle(.red)
                    }
                case .neutral:
                    Text("Scroll")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.system(size: 9, weight: .black, design: .monospaced))

            Spacer()

            // Crown direction hint (right)
            VStack(spacing: 1) {
                Image(systemName: "chevron.up")
                    .foregroundStyle(game.stampState == .approving ? .green : .gray.opacity(0.3))
                Image(systemName: "chevron.down")
                    .foregroundStyle(game.stampState == .denying ? .red : .gray.opacity(0.3))
            }
            .font(.system(size: 7))
            .frame(width: 16)
        }
        .padding(.horizontal, 4)
        .frame(height: 20)
        .background(Color.black.opacity(0.5))
    }

    // MARK: - Stamp Intensity Meter

    private var stampIntensityBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))

                Rectangle()
                    .fill(
                        game.stampState == .approving ? Color.green :
                        game.stampState == .denying ? Color.red :
                        Color.gray.opacity(0.4)
                    )
                    .frame(height: geo.size.height * game.stampIntensity)
            }
        }
    }
}
