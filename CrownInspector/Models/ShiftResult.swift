import Foundation

/// Result of a completed shift
struct ShiftResult {
    let event: Event
    let correctAdmissions: Int
    let correctDenials: Int
    let wrongAdmissions: Int // Let a deceiver in
    let wrongDenials: Int // Denied a legitimate person
    let moneyEarned: Int
    let moneyLost: Int
    let prestigeEarned: Int
    let prestigeLost: Int
    let timeElapsed: TimeInterval

    var totalCorrect: Int { correctAdmissions + correctDenials }
    var totalMistakes: Int { wrongAdmissions + wrongDenials }
    var accuracy: Double {
        let total = totalCorrect + totalMistakes
        guard total > 0 else { return 0 }
        return Double(totalCorrect) / Double(total)
    }
    var netMoney: Int { moneyEarned - moneyLost }
    var netPrestige: Int { prestigeEarned - prestigeLost }
}

/// Individual decision made during a shift
enum Decision {
    case approved
    case denied
}

/// The result of a single decision
struct DecisionResult {
    let person: Person
    let decision: Decision
    let wasCorrect: Bool
    let moneyChange: Int
    let prestigeChange: Int
    let reason: String // e.g. "Correct! ID matched." or "Wrong! Name didn't match document."
}
