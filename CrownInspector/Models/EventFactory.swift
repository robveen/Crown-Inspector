import Foundation

/// Creates predefined events for each tier
enum EventFactory {
    static func events(for tier: EventTier) -> [Event] {
        switch tier {
        case .themePark:
            return [
                Event(
                    name: "Funland Adventure Park",
                    tier: .themePark,
                    minimumAge: nil,
                    shiftDuration: 60,
                    difficulty: .easy,
                    payPerCorrect: 5,
                    penaltyPerMistake: 3,
                    prestigePerCorrect: 2,
                    prestigePerMistake: 1,
                    mortgageCost: 10,
                    baseFoodCost: 5,
                    baseUtilitiesCost: 5,
                    baseLuxuryCost: 8,
                    deceiverRate: 0.2,
                    maxDiscrepancies: 1
                ),
            ]
        case .localFair:
            return [
                Event(
                    name: "Harvest County Fair",
                    tier: .localFair,
                    minimumAge: nil,
                    shiftDuration: 60,
                    difficulty: .easy,
                    payPerCorrect: 8,
                    penaltyPerMistake: 5,
                    prestigePerCorrect: 3,
                    prestigePerMistake: 2,
                    mortgageCost: 18,
                    baseFoodCost: 8,
                    baseUtilitiesCost: 8,
                    baseLuxuryCost: 12,
                    deceiverRate: 0.25,
                    maxDiscrepancies: 1
                ),
            ]
        case .musicFestival:
            return [
                Event(
                    name: "Soundwave Festival",
                    tier: .musicFestival,
                    minimumAge: 18,
                    shiftDuration: 75,
                    difficulty: .medium,
                    payPerCorrect: 12,
                    penaltyPerMistake: 8,
                    prestigePerCorrect: 5,
                    prestigePerMistake: 4,
                    mortgageCost: 30,
                    baseFoodCost: 12,
                    baseUtilitiesCost: 12,
                    baseLuxuryCost: 18,
                    deceiverRate: 0.3,
                    maxDiscrepancies: 2
                ),
            ]
        case .fashionGala:
            return [
                Event(
                    name: "The Grand Runway Gala",
                    tier: .fashionGala,
                    minimumAge: 18,
                    shiftDuration: 75,
                    difficulty: .medium,
                    payPerCorrect: 18,
                    penaltyPerMistake: 12,
                    prestigePerCorrect: 8,
                    prestigePerMistake: 6,
                    mortgageCost: 45,
                    baseFoodCost: 18,
                    baseUtilitiesCost: 15,
                    baseLuxuryCost: 25,
                    deceiverRate: 0.35,
                    maxDiscrepancies: 2
                ),
            ]
        case .charityBall:
            return [
                Event(
                    name: "The Silver Spoon Ball",
                    tier: .charityBall,
                    minimumAge: 18,
                    shiftDuration: 90,
                    difficulty: .hard,
                    payPerCorrect: 25,
                    penaltyPerMistake: 18,
                    prestigePerCorrect: 12,
                    prestigePerMistake: 10,
                    mortgageCost: 65,
                    baseFoodCost: 25,
                    baseUtilitiesCost: 20,
                    baseLuxuryCost: 35,
                    deceiverRate: 0.4,
                    maxDiscrepancies: 3
                ),
            ]
        case .royalGarden:
            return [
                Event(
                    name: "The Queen's Garden Soirée",
                    tier: .royalGarden,
                    minimumAge: 18,
                    shiftDuration: 90,
                    difficulty: .hard,
                    payPerCorrect: 35,
                    penaltyPerMistake: 25,
                    prestigePerCorrect: 18,
                    prestigePerMistake: 15,
                    mortgageCost: 90,
                    baseFoodCost: 35,
                    baseUtilitiesCost: 30,
                    baseLuxuryCost: 50,
                    deceiverRate: 0.45,
                    maxDiscrepancies: 3
                ),
            ]
        case .crownInspector:
            return [
                Event(
                    name: "The Royal Court",
                    tier: .crownInspector,
                    minimumAge: 18,
                    shiftDuration: 120,
                    difficulty: .expert,
                    payPerCorrect: 50,
                    penaltyPerMistake: 40,
                    prestigePerCorrect: 25,
                    prestigePerMistake: 20,
                    mortgageCost: 120,
                    baseFoodCost: 50,
                    baseUtilitiesCost: 45,
                    baseLuxuryCost: 70,
                    deceiverRate: 0.5,
                    maxDiscrepancies: 4
                ),
            ]
        }
    }
}
