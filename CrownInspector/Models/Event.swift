import Foundation

/// An event (gig) that Steven Stampman works at
struct Event: Identifiable {
    let id = UUID()
    let name: String
    let tier: EventTier
    let minimumAge: Int? // nil means all ages
    let shiftDuration: TimeInterval // seconds of gameplay
    let difficulty: Difficulty
    let payPerCorrect: Int
    let penaltyPerMistake: Int
    let prestigePerCorrect: Int
    let prestigePerMistake: Int
    let mortgageCost: Int
    let baseFoodCost: Int
    let baseUtilitiesCost: Int
    let baseLuxuryCost: Int

    /// How likely deceivers are to appear (0.0 - 1.0)
    let deceiverRate: Double

    /// How many discrepancy types can appear
    let maxDiscrepancies: Int
}

// MARK: - Event Tier

/// Progression tiers from lowly ticket inspector to Crown Inspector
enum EventTier: Int, CaseIterable, Comparable {
    case themePark = 0
    case localFair
    case musicFestival
    case fashionGala
    case charityBall
    case royalGarden
    case crownInspector

    var displayName: String {
        switch self {
        case .themePark: return "Theme Park"
        case .localFair: return "Local Fair"
        case .musicFestival: return "Music Festival"
        case .fashionGala: return "Fashion Gala"
        case .charityBall: return "Charity Ball"
        case .royalGarden: return "Royal Garden Party"
        case .crownInspector: return "Crown Inspector"
        }
    }

    var description: String {
        switch self {
        case .themePark: return "Where every stamp enthusiast starts"
        case .localFair: return "The county needs your steady hands"
        case .musicFestival: return "Louder crowds, trickier IDs"
        case .fashionGala: return "High fashion, higher stakes"
        case .charityBall: return "The elite expect perfection"
        case .royalGarden: return "One step from the throne"
        case .crownInspector: return "The Queen awaits"
        }
    }

    var prestigeRequired: Int {
        switch self {
        case .themePark: return 0
        case .localFair: return 50
        case .musicFestival: return 150
        case .fashionGala: return 350
        case .charityBall: return 600
        case .royalGarden: return 1000
        case .crownInspector: return 2000
        }
    }

    static func < (lhs: EventTier, rhs: EventTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Difficulty

enum Difficulty: Int, CaseIterable {
    case easy = 1
    case medium
    case hard
    case expert

    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .expert: return "Expert"
        }
    }
}
