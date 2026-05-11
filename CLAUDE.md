# CLAUDE.md — Crown Inspector

Guidance for Claude when working in this repository. The goal of this file is to gather **all required and supplemental information needed to one-shot an MVP** of *Crown Inspector*, a watchOS game built around the Digital Crown.

---

## 1. Project Concept

**Crown Inspector** is a ticket-checking game made specifically for Apple Watch. The player is a train/festival/border inspector who must rapidly judge whether each passing ticket is valid or forged. The **Digital Crown is the primary input**: scroll the crown to inspect the ticket (zoom, flip, slide between fields), then tap **Approve** or **Reject**.

Core loop (≤ 5 seconds per ticket):
1. A ticket appears with several fields (name, date, seat, stamp, barcode).
2. Player turns the Digital Crown to scrub through inspection states (front → seal → back → barcode zoom).
3. Player taps ✓ (valid) or ✗ (forged). Haptic feedback confirms.
4. Score updates. Wrong calls cost lives; correct calls add time.
5. Forgeries get more subtle as difficulty ramps.

Why it suits the watch:
- Sessions are 30–120 seconds — perfect "raise-wrist" play.
- The Digital Crown is **the** distinctive watch input and the game's name leans into it.
- Haptics + small visual deltas reward attention without needing a big screen.

---

## 2. Required Information Before Coding

Before generating code, confirm or assume the following. Defaults are listed; ask only if the user contradicts them.

| Item | Default Assumption |
|---|---|
| Target OS | **watchOS 10.0+** (SwiftUI-only, no Storyboards) |
| Companion iOS app | **None** — standalone watchOS app |
| Language | **Swift 5.9+** |
| UI framework | **SwiftUI** (with `WKApplicationDelegate` only if needed) |
| Graphics | **SwiftUI** primitives + `Canvas` / `TimelineView`. Use **SpriteKit** only if a particle/physics need appears. |
| Persistence | `@AppStorage` (UserDefaults) for high score + settings |
| Audio | None for MVP — rely on `WKHapticType` |
| Architecture | MVVM with `@Observable` (watchOS 10+) view models |
| Bundle ID | `com.example.crowninspector` (placeholder; user can rename) |
| Min Xcode | 15.0 |
| Testing | XCTest unit tests for game logic; no UI tests for MVP |

If the user has not provided an Apple Developer team ID, leave `DEVELOPMENT_TEAM` empty in the project file — they can set it in Xcode.

---

## 3. watchOS Development Skills Cheat Sheet

### 3.1 Project structure (SwiftUI-only watchOS app)
```
CrownInspector/
├── CrownInspectorApp.swift          // @main App entry
├── ContentView.swift                 // Root view, routes between menu/game/over
├── Game/
│   ├── GameViewModel.swift          // @Observable game state machine
│   ├── GameView.swift               // Active play screen
│   ├── Ticket.swift                 // Model: fields + forgery flags
│   ├── TicketGenerator.swift        // Procedural ticket + forgery generation
│   └── TicketView.swift             // Renders a ticket; reacts to crown
├── Menu/
│   ├── MenuView.swift               // Start, high score, settings
│   └── GameOverView.swift
├── Services/
│   ├── HapticsService.swift         // Wraps WKInterfaceDevice haptics
│   └── ScoreStore.swift             // @AppStorage wrapper
└── Assets.xcassets
```

### 3.2 Digital Crown — the critical API
Use `.digitalCrownRotation` on a focused view. **The view must be `.focusable()` and `.focused()` for crown events to arrive.**

```swift
@State private var crown: Double = 0
@FocusState private var focused: Bool

var body: some View {
    TicketView(inspectionProgress: crown)
        .focusable(true)
        .focused($focused)
        .digitalCrownRotation(
            $crown,
            from: 0.0, through: 1.0, by: 0.01,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onAppear { focused = true }
}
```

Pitfalls:
- Without `.focused`, crown does nothing — easy to miss.
- Only one view can own the crown at a time. Reset focus when switching screens.
- Use `isHapticFeedbackEnabled: true` for the built-in detent feel; layer custom haptics on top sparingly.

### 3.3 Haptics
```swift
WKInterfaceDevice.current().play(.success) // .failure .click .start .stop .notification .directionUp .directionDown
```
Use sparingly — every tap haptic during fast play feels noisy. Reserve for: approve/reject confirmation, game over, new high score.

### 3.4 Layout constraints
- Screen sizes vary: 40/41/44/45/49 mm. **Always use `GeometryReader` or relative spacing** — never hardcode points.
- Safe area is small; avoid bottom toolbars during play. Use full-screen gestures.
- Text: use `.minimumScaleFactor(0.7)` and `.lineLimit(1)` on small labels.
- Prefer `.containerBackground` (watchOS 10) for color-themed screens.

### 3.5 Performance
- Watch CPUs are weak — avoid expensive view bodies per frame.
- Prefer `TimelineView(.animation)` for clocks/timers over `Timer` + `@State`.
- Cap ticket re-renders by making `Ticket` a value type and diffing by id.

### 3.6 App lifecycle quirks
- Wrist-down can suspend the app at any moment. Persist score on every state change, not on background only.
- Don't rely on long-running timers; `TimelineView` survives short suspensions better.

---

## 4. Game Design — MVP Scope

### 4.1 Must-have (MVP)
1. **Main menu**: Start, high score display.
2. **Game loop**: ticket appears → crown to inspect → ✓/✗ buttons → next ticket.
3. **Ticket model** with 4–5 fields and a `forgery: Forgery?` enum (`.none`, `.misspelledName`, `.wrongDate`, `.fakeStamp`, `.barcodeMismatch`).
4. **Procedural generator** that produces a valid ticket then optionally injects one forgery type.
5. **Scoring**: +1 per correct call, lose 1 of 3 lives per wrong call. Game ends at 0 lives.
6. **Timer**: 60-second round; correct call adds +2s, wrong call −5s.
7. **Crown inspection**: rotating the crown reveals more detail (e.g., zooms the stamp or scrolls between front/back). Game must be **playable without** the crown (touch fallback) — accessibility.
8. **Haptics**: `.success` on correct, `.failure` on wrong, `.notification` on game over.
9. **Persist high score** via `@AppStorage`.
10. **Game over screen** with score + Play Again.

### 4.2 Explicit non-goals for MVP
- No sound, no Complications, no notifications.
- No iCloud sync, no GameKit leaderboards.
- No iPhone companion app.
- No multiple game modes or unlockables.
- No animations beyond simple transitions.

### 4.3 Stretch (only after MVP runs)
- Complication showing high score.
- Daily challenge with a fixed RNG seed.
- Difficulty curve: more forgery types unlock at score thresholds.

---

## 5. Implementation Plan (one-shot order)

1. Create Xcode project — watchOS App, SwiftUI lifecycle, no companion app.
2. Add `Ticket.swift` model + `Forgery` enum.
3. Add `TicketGenerator.swift` — fixed name/date/seat pools, ~30% forgery rate.
4. Add `GameViewModel.swift` (`@Observable`): `score`, `lives`, `timeRemaining`, `currentTicket`, `phase` (`.menu`, `.playing`, `.gameOver`), methods `start()`, `approve()`, `reject()`, `tick()`.
5. Add `TicketView.swift` — shows fields; uses a `progress: Double` parameter to switch between front/seal/back/barcode views.
6. Add `GameView.swift` — wires crown to `progress`, shows ticket + ✓/✗ buttons + timer + lives.
7. Add `MenuView.swift` and `GameOverView.swift`.
8. Add `HapticsService` and `ScoreStore`.
9. Wire `ContentView` to switch on `viewModel.phase`.
10. Add unit tests for `TicketGenerator` (valid tickets have no forgery flag; forgery rate within bounds) and `GameViewModel` (approve/reject affects score and lives correctly).

---

## 6. Coding Conventions

- SwiftUI views: keep `body` under ~40 lines; extract subviews.
- Use `@Observable` (watchOS 10+) over `ObservableObject` for view models.
- Use `let` aggressively; structs over classes for models.
- File-per-type unless the type is trivially small (< 20 lines).
- No force unwraps in production code (`!`). Use `guard let` or default values.
- No print statements in shipped code; use `Logger` from `os.log` if logging is needed.
- **No comments that restate code.** Only comment non-obvious *why*.

---

## 7. Build, Run, Test

```bash
# Open in Xcode (no CLI build for watchOS apps without provisioning)
open CrownInspector.xcodeproj

# Run tests from CLI (after project exists)
xcodebuild test \
  -scheme CrownInspector \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Linting/formatting: none required for MVP. If the user later adds SwiftFormat or SwiftLint, follow their config.

---

## 8. Supplemental Reference — APIs likely needed

| Need | API |
|---|---|
| App entry | `@main struct App: App` |
| Scene | `WindowGroup { ContentView() }` |
| Crown input | `.digitalCrownRotation(_:from:through:by:sensitivity:isContinuous:isHapticFeedbackEnabled:)` |
| Focus | `.focusable()`, `@FocusState`, `.focused()` |
| Haptics | `WKInterfaceDevice.current().play(_:)` with `WKHapticType` |
| Timer | `TimelineView(.periodic(from: .now, by: 1.0))` or `Timer.publish` |
| Persistence | `@AppStorage("highScore") var highScore: Int = 0` |
| State | `@Observable` macro (watchOS 10+) |
| Navigation | `NavigationStack` with `.navigationDestination` |
| Background color | `.containerBackground(.gradient, for: .navigation)` |
| Buttons | `Button(role: .destructive)`, `.buttonStyle(.borderedProminent)` |

---

## 9. Open Questions Claude Should Ask Before Coding

If any of these are unanswered and seem to matter, ask the user once before scaffolding:

1. **Apple Developer team / bundle ID?** (Otherwise leave blank.)
2. **Minimum watchOS version?** (Default: 10.0.)
3. **Should the MVP include sound?** (Default: no — haptics only.)
4. **Any branding/colors?** (Default: a navy → gold gradient evoking a ticket booth.)

Otherwise, proceed with the defaults above and ship the MVP.
