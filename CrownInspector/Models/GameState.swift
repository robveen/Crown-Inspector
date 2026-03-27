import Foundation

/// The overall saved game state
struct GameState: Codable {
    var playerName: String = "Steven Stampman"
    var economy: Economy = Economy()
    var currentTier: EventTier = .themePark
    var highestUnlockedTier: EventTier = .themePark
    var totalShiftsCompleted: Int = 0
    var totalCorrectDecisions: Int = 0
    var totalMistakes: Int = 0
    var lifetimeEarnings: Int = 0
    var lifetimePrestige: Int = 0

    /// Check if the player can afford the mandatory mortgage
    var canAffordMortgage: Bool {
        // Will be computed based on current event
        true
    }

    /// Check if a new tier is unlocked
    func isTierUnlocked(_ tier: EventTier) -> Bool {
        economy.prestige >= tier.prestigeRequired
    }
}

// MARK: - Codable conformance for enums used in GameState

extension EventTier: Codable {}
extension Difficulty: Codable {}

// MARK: - Persistence

extension GameState {
    private static let saveKey = "CrownInspector.GameState"

    static func load() -> GameState {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let state = try? JSONDecoder().decode(GameState.self, from: data)
        else {
            return GameState()
        }
        return state
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: saveKey)
    }
}
