import Foundation

/// Pre-shift checklist shown before a shift starts
struct ShiftBriefing {
    let event: Event
    let vipNames: [String]
    let blacklistedNames: [String]
    let specialRules: [String]

    static func generate(for event: Event) -> ShiftBriefing {
        let vipPool = [
            "Lady Pemberton", "Duke Ashworth", "Sir Reginald",
            "Countess Vane", "Baron Holt", "Dame Eloise",
            "Lord Whitmore", "Marquess Faye", "Viscount Drake"
        ]

        let blacklistPool = [
            "Karl Fox", "Xena Stone", "Ivan Cross",
            "Quinn Bell", "Zara Wood", "Ulrich Moore",
            "Edgar Hill", "Tara White", "Yuri Rose"
        ]

        // Higher tiers have more VIPs and blacklisted people
        let vipCount: Int
        let blacklistCount: Int
        var rules: [String] = []

        switch event.tier {
        case .themePark:
            vipCount = 0
            blacklistCount = 0
        case .localFair:
            vipCount = 1
            blacklistCount = 0
        case .musicFestival:
            vipCount = 1
            blacklistCount = 1
            rules.append("18+ event")
        case .fashionGala:
            vipCount = 2
            blacklistCount = 1
            rules.append("18+ event")
        case .charityBall:
            vipCount = 2
            blacklistCount = 2
            rules.append("18+ event")
        case .royalGarden:
            vipCount = 3
            blacklistCount = 2
            rules.append("18+ event")
        case .crownInspector:
            vipCount = 3
            blacklistCount = 3
            rules.append("18+ event")
        }

        if let age = event.minimumAge {
            rules.append("Minimum age: \(age)")
        }

        return ShiftBriefing(
            event: event,
            vipNames: Array(vipPool.shuffled().prefix(vipCount)),
            blacklistedNames: Array(blacklistPool.shuffled().prefix(blacklistCount)),
            specialRules: rules
        )
    }
}
