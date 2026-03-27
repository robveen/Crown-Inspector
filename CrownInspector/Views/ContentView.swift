import SwiftUI

/// Root content view that switches between screens based on game state
struct ContentView: View {
    @EnvironmentObject var game: GameManager

    var body: some View {
        Group {
            switch game.currentScreen {
            case .mainMenu:
                MainMenuView()
            case .eventSelect:
                EventSelectView()
            case .shift:
                ShiftView()
            case .shiftResult:
                ShiftResultView()
            case .expenses:
                ExpensesView()
            case .gameOver:
                GameOverView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: game.currentScreen)
    }
}
