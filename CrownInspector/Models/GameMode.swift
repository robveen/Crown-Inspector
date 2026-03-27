import Foundation

/// The different ways to play Crown Inspector
enum GameMode: String, CaseIterable, Codable {
    case career
    case endless
    case timeTrial

    var displayName: String {
        switch self {
        case .career: return "Career"
        case .endless: return "Endless"
        case .timeTrial: return "Time Trial"
        }
    }

    var description: String {
        switch self {
        case .career: return "Rise from theme park to Crown Inspector"
        case .endless: return "How long can you last?"
        case .timeTrial: return "Most stamps in 60 seconds"
        }
    }

    var icon: String {
        switch self {
        case .career: return "crown.fill"
        case .endless: return "infinity"
        case .timeTrial: return "timer"
        }
    }
}
