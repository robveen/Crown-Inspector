import Foundation

/// Manages Steven Stampman's finances and living conditions
struct Economy: Codable {
    var money: Int = 100
    var prestige: Int = 0
    var hunger: HungerLevel = .satisfied
    var hygiene: HygieneLevel = .clean
    var luxury: LuxuryLevel = .modest

    // MARK: - Shift End Expenses

    struct ShiftExpenses {
        let mortgageCost: Int
        let foodCost: Int
        let utilitiesCost: Int
        let luxuryCost: Int

        var totalRequired: Int { mortgageCost } // Only mortgage is mandatory
        var totalOptional: Int { foodCost + utilitiesCost + luxuryCost }
        var totalAll: Int { mortgageCost + foodCost + utilitiesCost + luxuryCost }
    }

    // MARK: - Hunger

    /// How hungry Steven is — affects work hours
    enum HungerLevel: Int, Codable, CaseIterable {
        case starving = 0
        case hungry
        case peckish
        case satisfied
        case full

        var displayName: String {
            switch self {
            case .starving: return "Starving"
            case .hungry: return "Hungry"
            case .peckish: return "Peckish"
            case .satisfied: return "Satisfied"
            case .full: return "Full"
            }
        }

        /// Multiplier on shift duration (how long you can work)
        var shiftMultiplier: Double {
            switch self {
            case .starving: return 0.5
            case .hungry: return 0.7
            case .peckish: return 0.85
            case .satisfied: return 1.0
            case .full: return 1.1
            }
        }
    }

    // MARK: - Hygiene

    /// How clean Steven is — affects prestige multiplier
    enum HygieneLevel: Int, Codable, CaseIterable {
        case foul = 0
        case smelly
        case passable
        case clean
        case pristine

        var displayName: String {
            switch self {
            case .foul: return "Foul"
            case .smelly: return "Smelly"
            case .passable: return "Passable"
            case .clean: return "Clean"
            case .pristine: return "Pristine"
            }
        }

        /// Multiplier on prestige earned
        var prestigeEarnedMultiplier: Double {
            switch self {
            case .foul: return 0.3
            case .smelly: return 0.6
            case .passable: return 0.85
            case .clean: return 1.0
            case .pristine: return 1.2
            }
        }

        /// Multiplier on prestige lost (higher = lose more)
        var prestigeLostMultiplier: Double {
            switch self {
            case .foul: return 2.0
            case .smelly: return 1.5
            case .passable: return 1.15
            case .clean: return 1.0
            case .pristine: return 0.8
            }
        }

        /// Risk modifier for getting fired (0.0 - 1.0 added to base risk)
        var fireRiskModifier: Double {
            switch self {
            case .foul: return 0.3
            case .smelly: return 0.15
            case .passable: return 0.05
            case .clean: return 0.0
            case .pristine: return -0.05
            }
        }
    }

    // MARK: - Luxury

    /// Luxury level — spend money to boost prestige
    enum LuxuryLevel: Int, Codable, CaseIterable {
        case destitute = 0
        case frugal
        case modest
        case comfortable
        case lavish

        var displayName: String {
            switch self {
            case .destitute: return "Destitute"
            case .frugal: return "Frugal"
            case .modest: return "Modest"
            case .comfortable: return "Comfortable"
            case .lavish: return "Lavish"
            }
        }

        /// Bonus multiplier on prestige earned
        var prestigeBonus: Double {
            switch self {
            case .destitute: return 0.7
            case .frugal: return 0.85
            case .modest: return 1.0
            case .comfortable: return 1.2
            case .lavish: return 1.5
            }
        }

        /// Reduction on prestige lost
        var prestigeProtection: Double {
            switch self {
            case .destitute: return 1.3
            case .frugal: return 1.1
            case .modest: return 1.0
            case .comfortable: return 0.85
            case .lavish: return 0.6
            }
        }

        /// Risk modifier for getting fired
        var fireRiskModifier: Double {
            switch self {
            case .destitute: return 0.1
            case .frugal: return 0.05
            case .modest: return 0.0
            case .comfortable: return -0.05
            case .lavish: return -0.15
            }
        }
    }

    // MARK: - Calculations

    /// Calculate effective prestige earned for a correct admission
    func effectivePrestigeEarned(base: Int) -> Int {
        let result = Double(base)
            * hygiene.prestigeEarnedMultiplier
            * luxury.prestigeBonus
        return max(1, Int(result.rounded()))
    }

    /// Calculate effective prestige lost for a mistake
    func effectivePrestigeLost(base: Int) -> Int {
        let result = Double(base)
            * hygiene.prestigeLostMultiplier
            * luxury.prestigeProtection
        return max(1, Int(result.rounded()))
    }

    /// Calculate effective shift duration
    func effectiveShiftDuration(base: TimeInterval) -> TimeInterval {
        base * hunger.shiftMultiplier
    }

    /// Total fire risk modifier from hygiene + luxury
    var fireRiskModifier: Double {
        hygiene.fireRiskModifier + luxury.fireRiskModifier
    }
}
