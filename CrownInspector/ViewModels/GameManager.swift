import SwiftUI
import Combine

/// Central game manager that coordinates game state and shift logic
@MainActor
class GameManager: ObservableObject {
    @Published var gameState: GameState
    @Published var currentScreen: Screen = .mainMenu
    @Published var isInShift: Bool = false
    @Published var currentGameMode: GameMode = .career

    // Shift state
    @Published var currentPerson: Person?
    @Published var shiftTimeRemaining: TimeInterval = 0
    @Published var crownRotation: Double = 0
    @Published var stampState: StampState = .neutral
    @Published var stampIntensity: Double = 0 // 0-1, how hard the stamp lands
    @Published var lastDecisionResult: DecisionResult?
    @Published var showingResult: Bool = false
    @Published var screenShakeOffset: CGSize = .zero
    @Published var currentBriefing: ShiftBriefing?
    @Published var isTransitioningPerson: Bool = false

    // Endless mode state
    @Published var endlessLives: Int = 3
    @Published var endlessScore: Int = 0
    @Published var endlessDifficulty: Double = 1.0

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
    private(set) var currentEvent: Event?
    private var shiftTimer: Timer?
    private var personGenerator: PersonGenerator?

    enum Screen: Equatable {
        case mainMenu
        case modeSelect
        case eventSelect
        case briefing
        case shift
        case shiftResult
        case expenses
        case gameOver
        case fired
    }

    enum StampState: Equatable {
        case neutral
        case approving
        case denying
        case stamped

        var displayText: String {
            switch self {
            case .neutral: return ""
            case .approving: return "APPROVE"
            case .denying: return "DENY"
            case .stamped: return "STAMPED!"
            }
        }
    }

    // MARK: - Crown Thresholds & Physics

    private let approveThreshold: Double = 0.7
    private let denyThreshold: Double = -0.7
    private let transitionDuration: Double = 0.75

    init() {
        self.gameState = GameState.load()
    }

    // MARK: - Navigation

    func startNewGame() {
        GameState.reset()
        gameState = GameState()
        currentScreen = .modeSelect
    }

    func continueGame() {
        currentScreen = .modeSelect
    }

    func selectMode(_ mode: GameMode) {
        currentGameMode = mode
        switch mode {
        case .career:
            currentScreen = .eventSelect
        case .endless:
            startEndlessMode()
        case .timeTrial:
            startTimeTrialMode()
        }
    }

    // MARK: - Career Mode

    func selectEvent(_ event: Event) {
        currentEvent = event
        let briefing = ShiftBriefing.generate(for: event)
        currentBriefing = briefing
        personGenerator = PersonGenerator(
            event: event,
            vipNames: briefing.vipNames,
            blacklistedNames: briefing.blacklistedNames
        )
        currentScreen = .briefing
    }

    func startShiftFromBriefing() {
        guard let event = currentEvent else { return }
        startShift(event: event)
    }

    // MARK: - Endless Mode

    private func startEndlessMode() {
        endlessLives = 3
        endlessScore = 0
        endlessDifficulty = 1.0

        let event = Event(
            name: "Endless Gate",
            tier: .themePark,
            minimumAge: Bool.random() ? 18 : nil,
            shiftDuration: .infinity,
            difficulty: .medium,
            payPerCorrect: 10,
            penaltyPerMistake: 5,
            prestigePerCorrect: 3,
            prestigePerMistake: 2,
            mortgageCost: 0,
            baseFoodCost: 0,
            baseUtilitiesCost: 0,
            baseLuxuryCost: 0,
            deceiverRate: 0.3,
            maxDiscrepancies: 2
        )

        currentEvent = event
        let briefing = ShiftBriefing.generate(for: event)
        currentBriefing = briefing
        personGenerator = PersonGenerator(
            event: event,
            vipNames: briefing.vipNames,
            blacklistedNames: briefing.blacklistedNames
        )
        currentScreen = .briefing
    }

    // MARK: - Time Trial Mode

    private func startTimeTrialMode() {
        let event = Event(
            name: "Speed Stamp",
            tier: .themePark,
            minimumAge: nil,
            shiftDuration: 60,
            difficulty: .easy,
            payPerCorrect: 10,
            penaltyPerMistake: 5,
            prestigePerCorrect: 1,
            prestigePerMistake: 1,
            mortgageCost: 0,
            baseFoodCost: 0,
            baseUtilitiesCost: 0,
            baseLuxuryCost: 0,
            deceiverRate: 0.25,
            maxDiscrepancies: 1
        )

        currentEvent = event
        let briefing = ShiftBriefing.generate(for: event)
        currentBriefing = briefing
        personGenerator = PersonGenerator(
            event: event,
            vipNames: briefing.vipNames,
            blacklistedNames: briefing.blacklistedNames
        )
        currentScreen = .briefing
    }

    // MARK: - Shift Management

    func startShift(event: Event) {
        let duration: TimeInterval
        if currentGameMode == .endless {
            duration = .infinity
        } else {
            duration = gameState.economy.effectiveShiftDuration(base: event.shiftDuration)
        }

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
        stampIntensity = 0
        isInShift = true
        currentScreen = .shift

        nextPerson()
        if currentGameMode != .endless {
            startTimer()
        }
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
        guard shiftTimeRemaining != .infinity else { return }
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

        // Submit to Game Center
        GameCenterManager.shared.submitShiftResults(result, gameMode: currentGameMode)

        if currentGameMode == .career {
            gameState.totalShiftsCompleted += 1
            gameState.totalCorrectDecisions += result.totalCorrect
            gameState.totalMistakes += result.totalMistakes
            gameState.economy.money += result.netMoney
            gameState.economy.prestige += result.netPrestige
            gameState.lifetimeEarnings += result.moneyEarned
            gameState.lifetimePrestige += result.prestigeEarned

            for tier in EventTier.allCases where tier > gameState.highestUnlockedTier {
                if gameState.isTierUnlocked(tier) {
                    gameState.highestUnlockedTier = tier
                }
            }

            gameState.save()
        }

        currentScreen = .shiftResult
    }

    // MARK: - Person & Decision

    func nextPerson() {
        isTransitioningPerson = true
        crownRotation = 0
        stampState = .neutral
        stampIntensity = 0
        showingResult = false

        // 0.75s transition: person walks out, new person walks in
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) { [weak self] in
            self?.currentPerson = self?.personGenerator?.generate()
            self?.isTransitioningPerson = false
        }
    }

    /// Called as the Digital Crown rotates
    func updateCrownValue(_ value: Double) {
        crownRotation = value

        // Calculate stamp intensity based on how far the crown is turned
        let normalizedValue = abs(value)
        stampIntensity = min(1.0, normalizedValue / 0.95)

        if value >= approveThreshold {
            stampState = .approving
        } else if value <= denyThreshold {
            stampState = .denying
        } else {
            stampState = .neutral
        }
    }

    /// Commit the current stamp decision — intensity determines screen shake
    func commitDecision() {
        guard let person = currentPerson, let event = currentEvent else { return }
        guard stampState == .approving || stampState == .denying else { return }

        let decision: Decision = stampState == .approving ? .approved : .denied
        let result = evaluateDecision(decision, for: person, at: event)

        lastDecisionResult = result

        // Screen shake proportional to crown rotation intensity
        triggerScreenShake()

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

            // Endless mode: lose a life
            if currentGameMode == .endless {
                endlessLives -= 1
                if endlessLives <= 0 {
                    endShift()
                    return
                }
            }
        }

        if currentGameMode == .endless {
            endlessScore += result.wasCorrect ? 1 : 0
            // Gradually increase difficulty
            endlessDifficulty += 0.02
        }

        stampState = .stamped
        showingResult = true

        // Quick transition to next person
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) { [weak self] in
            self?.nextPerson()
        }
    }

    // MARK: - Screen Shake

    private func triggerScreenShake() {
        let intensity = stampIntensity * 6.0 // Max 6pt shake

        withAnimation(.interpolatingSpring(stiffness: 800, damping: 8)) {
            screenShakeOffset = CGSize(
                width: Double.random(in: -intensity...intensity),
                height: Double.random(in: -intensity...intensity)
            )
        }

        // Settle back
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.interpolatingSpring(stiffness: 600, damping: 10)) {
                self.screenShakeOffset = CGSize(
                    width: Double.random(in: -intensity * 0.4...intensity * 0.4),
                    height: Double.random(in: -intensity * 0.4...intensity * 0.4)
                )
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.1)) {
                self.screenShakeOffset = .zero
            }
        }
    }

    // MARK: - Decision Evaluation

    private func evaluateDecision(_ decision: Decision, for person: Person, at event: Event) -> DecisionResult {
        let briefing = currentBriefing
        let correctDecision = person.correctDecision(
            minimumAge: event.minimumAge,
            vipList: briefing?.vipNames ?? [],
            blacklist: briefing?.blacklistedNames ?? []
        )

        let wasCorrect = decision == correctDecision

        let reason: String
        switch (decision, correctDecision) {
        case (.approved, .approved):
            if person.specialStatus == .vip {
                reason = "Correct! VIP welcomed."
            } else {
                reason = "Correct! Welcome in."
            }
        case (.denied, .denied):
            if person.specialStatus == .blacklisted {
                reason = "Correct! Blacklisted."
            } else if person.isDeceiver {
                reason = "Correct! Caught a fake."
            } else {
                reason = "Correct! Too young."
            }
        case (.approved, .denied):
            if person.specialStatus == .blacklisted {
                reason = "Wrong! They're blacklisted!"
            } else if person.isDeceiver {
                reason = "Wrong! Fake ID."
            } else {
                reason = "Wrong! Underage."
            }
        case (.denied, .approved):
            if person.specialStatus == .vip {
                reason = "Wrong! That was a VIP!"
            } else {
                reason = "Wrong! They were legit."
            }
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

        // Check fire risk
        let fireRisk = gameState.economy.fireRiskModifier
        if fireRisk > 0 && Double.random(in: 0...1) < fireRisk {
            handleFired()
            return
        }

        // Check bankruptcy
        if gameState.economy.money < 0 {
            currentScreen = .gameOver
        } else {
            gameState.save()
            currentScreen = .eventSelect
        }
    }

    // MARK: - Fired / Demotion

    private func handleFired() {
        // Demote to previous tier
        if gameState.currentTier.rawValue > 0,
           let lowerTier = EventTier(rawValue: gameState.currentTier.rawValue - 1) {
            gameState.currentTier = lowerTier
        }
        gameState.save()
        currentScreen = .fired
    }

    func acknowledgeFired() {
        currentScreen = .eventSelect
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
