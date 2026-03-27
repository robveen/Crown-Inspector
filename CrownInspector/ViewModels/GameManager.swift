import SwiftUI
import Combine

/// Central game manager that coordinates game state and shift logic
@MainActor
class GameManager: ObservableObject {
    @Published var gameState: GameState
    @Published var currentScreen: Screen = .mainMenu
    @Published var isInShift: Bool = false

    // Shift state
    @Published var currentPerson: Person?
    @Published var shiftTimeRemaining: TimeInterval = 0
    @Published var crownRotation: Double = 0 // Digital Crown value
    @Published var stampState: StampState = .neutral
    @Published var lastDecisionResult: DecisionResult?
    @Published var showingResult: Bool = false

    // Shift tracking
    private var shiftCorrectAdmissions = 0
    private var shiftCorrectDenials = 0
    private var shiftWrongAdmissions = 0
    private var shiftWrongDenials = 0
    private var shiftMoneyEarned = 0
    private var shiftMoneyLost = 0
    private var shiftPrestigeEarned = 0
    private var shiftPrestigeLost = 0
    private var shiftStartTime: Date?
    private var currentEvent: Event?
    private var shiftTimer: Timer?
    private var personGenerator: PersonGenerator?

    enum Screen {
        case mainMenu
        case eventSelect
        case shift
        case shiftResult
        case expenses
        case gameOver
    }

    enum StampState {
        case neutral
        case approving // Scrolling up
        case denying // Scrolling down
        case stamped // Just stamped

        var displayText: String {
            switch self {
            case .neutral: return ""
            case .approving: return "APPROVE"
            case .denying: return "DENY"
            case .stamped: return "STAMPED!"
            }
        }
    }

    // MARK: - Crown Thresholds

    /// How far the crown must be turned to trigger a stamp
    private let approveThreshold: Double = 0.7
    private let denyThreshold: Double = -0.7

    init() {
        self.gameState = GameState.load()
    }

    // MARK: - Navigation

    func startNewGame() {
        GameState.reset()
        gameState = GameState()
        currentScreen = .eventSelect
    }

    func continueGame() {
        currentScreen = .eventSelect
    }

    // MARK: - Event Selection

    func selectEvent(_ event: Event) {
        currentEvent = event
        personGenerator = PersonGenerator(event: event)
        startShift(event: event)
    }

    // MARK: - Shift Management

    func startShift(event: Event) {
        let duration = gameState.economy.effectiveShiftDuration(base: event.shiftDuration)

        shiftTimeRemaining = duration
        shiftCorrectAdmissions = 0
        shiftCorrectDenials = 0
        shiftWrongAdmissions = 0
        shiftWrongDenials = 0
        shiftMoneyEarned = 0
        shiftMoneyLost = 0
        shiftPrestigeEarned = 0
        shiftPrestigeLost = 0
        shiftStartTime = Date()
        crownRotation = 0
        stampState = .neutral
        isInShift = true
        currentScreen = .shift

        nextPerson()
        startTimer()
    }

    private func startTimer() {
        shiftTimer?.invalidate()
        shiftTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func tick() {
        shiftTimeRemaining -= 0.1
        if shiftTimeRemaining <= 0 {
            endShift()
        }
    }

    func endShift() {
        shiftTimer?.invalidate()
        shiftTimer = nil
        isInShift = false

        guard let event = currentEvent else { return }

        let result = ShiftResult(
            event: event,
            correctAdmissions: shiftCorrectAdmissions,
            correctDenials: shiftCorrectDenials,
            wrongAdmissions: shiftWrongAdmissions,
            wrongDenials: shiftWrongDenials,
            moneyEarned: shiftMoneyEarned,
            moneyLost: shiftMoneyLost,
            prestigeEarned: shiftPrestigeEarned,
            prestigeLost: shiftPrestigeLost,
            timeElapsed: Date().timeIntervalSince(shiftStartTime ?? Date())
        )

        gameState.totalShiftsCompleted += 1
        gameState.totalCorrectDecisions += result.totalCorrect
        gameState.totalMistakes += result.totalMistakes
        gameState.economy.money += result.netMoney
        gameState.economy.prestige += result.netPrestige
        gameState.lifetimeEarnings += result.moneyEarned
        gameState.lifetimePrestige += result.prestigeEarned

        // Check tier unlocks
        for tier in EventTier.allCases where tier > gameState.highestUnlockedTier {
            if gameState.isTierUnlocked(tier) {
                gameState.highestUnlockedTier = tier
            }
        }

        gameState.save()
        currentScreen = .shiftResult
    }

    // MARK: - Person & Decision

    func nextPerson() {
        crownRotation = 0
        stampState = .neutral
        showingResult = false
        currentPerson = personGenerator?.generate()
    }

    /// Called as the Digital Crown rotates
    func updateCrownValue(_ value: Double) {
        crownRotation = value

        if value >= approveThreshold {
            stampState = .approving
        } else if value <= denyThreshold {
            stampState = .denying
        } else {
            stampState = .neutral
        }
    }

    /// Commit the current stamp decision
    func commitDecision() {
        guard let person = currentPerson, let event = currentEvent else { return }

        let decision: Decision = stampState == .approving ? .approved : .denied
        let result = evaluateDecision(decision, for: person, at: event)

        lastDecisionResult = result

        // Update shift tallies
        if result.wasCorrect {
            if decision == .approved {
                shiftCorrectAdmissions += 1
            } else {
                shiftCorrectDenials += 1
            }
            shiftMoneyEarned += result.moneyChange
            shiftPrestigeEarned += result.prestigeChange
        } else {
            if decision == .approved {
                shiftWrongAdmissions += 1
            } else {
                shiftWrongDenials += 1
            }
            shiftMoneyLost += abs(result.moneyChange)
            shiftPrestigeLost += abs(result.prestigeChange)
        }

        stampState = .stamped
        showingResult = true

        // Brief pause to show result, then next person
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.nextPerson()
        }
    }

    private func evaluateDecision(_ decision: Decision, for person: Person, at event: Event) -> DecisionResult {
        let shouldApprove = !person.isDeceiver && person.meetsAgeRequirement(event.minimumAge)

        let wasCorrect: Bool
        let reason: String

        switch (decision, shouldApprove) {
        case (.approved, true):
            wasCorrect = true
            reason = "Correct! Welcome in."
        case (.approved, false):
            wasCorrect = false
            if person.isDeceiver {
                reason = "Wrong! That was a deceiver."
            } else {
                reason = "Wrong! Underage."
            }
        case (.denied, false):
            wasCorrect = true
            if person.isDeceiver {
                reason = "Correct! Caught a deceiver."
            } else {
                reason = "Correct! Too young."
            }
        case (.denied, true):
            wasCorrect = false
            reason = "Wrong! They were legitimate."
        }

        let moneyChange: Int
        let prestigeChange: Int

        if wasCorrect {
            moneyChange = event.payPerCorrect
            prestigeChange = gameState.economy.effectivePrestigeEarned(base: event.prestigePerCorrect)
        } else {
            moneyChange = -event.penaltyPerMistake
            prestigeChange = -gameState.economy.effectivePrestigeLost(base: event.prestigePerMistake)
        }

        return DecisionResult(
            person: person,
            decision: decision,
            wasCorrect: wasCorrect,
            moneyChange: moneyChange,
            prestigeChange: prestigeChange,
            reason: reason
        )
    }

    // MARK: - Expenses

    func payExpenses(food: Bool, utilities: Bool, luxuries: Bool) {
        guard let event = currentEvent else { return }

        // Mortgage is mandatory
        gameState.economy.money -= event.mortgageCost

        if food {
            gameState.economy.money -= event.baseFoodCost
            gameState.economy.hunger = min(gameState.economy.hunger, .satisfied)
        } else {
            // Hunger increases
            if let lower = Economy.HungerLevel(rawValue: gameState.economy.hunger.rawValue - 1) {
                gameState.economy.hunger = lower
            }
        }

        if utilities {
            gameState.economy.money -= event.baseUtilitiesCost
            gameState.economy.hygiene = min(gameState.economy.hygiene, .clean)
        } else {
            if let lower = Economy.HygieneLevel(rawValue: gameState.economy.hygiene.rawValue - 1) {
                gameState.economy.hygiene = lower
            }
        }

        if luxuries {
            gameState.economy.money -= event.baseLuxuryCost
            gameState.economy.luxury = min(gameState.economy.luxury, .comfortable)
        } else {
            if let lower = Economy.LuxuryLevel(rawValue: gameState.economy.luxury.rawValue - 1) {
                gameState.economy.luxury = lower
            }
        }

        // Check game over
        if gameState.economy.money < 0 {
            currentScreen = .gameOver
        } else {
            gameState.save()
            currentScreen = .eventSelect
        }
    }
}

// MARK: - Comparable conformance for enum min/max

extension Economy.HungerLevel: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}

extension Economy.HygieneLevel: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}

extension Economy.LuxuryLevel: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}
