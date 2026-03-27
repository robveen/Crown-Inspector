import GameKit

/// Manages Game Center authentication and leaderboard submissions
@MainActor
class GameCenterManager: ObservableObject {
    @Published var isAuthenticated = false

    static let shared = GameCenterManager()

    // MARK: - Leaderboard IDs

    enum Leaderboard {
        static let highestAccuracy = "com.crowninspector.accuracy"
        static let mostMoneyEarned = "com.crowninspector.money"
        static let fastestShift = "com.crowninspector.speed"
        static let highestPrestige = "com.crowninspector.prestige"
        static let endlessHighScore = "com.crowninspector.endless"
        static let timeTrialHighScore = "com.crowninspector.timetrial"
    }

    // MARK: - Authentication

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] _, error in
            Task { @MainActor in
                self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                if let error {
                    print("Game Center auth error: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Score Submission

    func submitScore(_ score: Int, to leaderboardID: String) {
        guard isAuthenticated else { return }
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) { error in
            if let error {
                print("Score submit error: \(error.localizedDescription)")
            }
        }
    }

    func submitShiftResults(_ result: ShiftResult, gameMode: GameMode) {
        let accuracyPercent = Int(result.accuracy * 100)
        submitScore(accuracyPercent, to: Leaderboard.highestAccuracy)
        submitScore(result.moneyEarned, to: Leaderboard.mostMoneyEarned)

        switch gameMode {
        case .endless:
            submitScore(result.totalCorrect, to: Leaderboard.endlessHighScore)
        case .timeTrial:
            submitScore(result.totalCorrect, to: Leaderboard.timeTrialHighScore)
        case .career:
            break
        }
    }
}
