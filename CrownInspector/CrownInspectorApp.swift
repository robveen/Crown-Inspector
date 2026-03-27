import SwiftUI

@main
struct CrownInspectorApp: App {
    @StateObject private var gameManager = GameManager()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .environmentObject(gameManager)
        }
    }
}
