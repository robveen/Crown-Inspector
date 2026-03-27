import SwiftUI

/// End-of-shift expenses screen where player chooses what to pay
struct ExpensesView: View {
    @EnvironmentObject var game: GameManager
    @State private var payFood = true
    @State private var payUtilities = true
    @State private var payLuxuries = false

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Expenses")
                    .font(.headline)

                // Available money
                HStack {
                    Text("Available:")
                    Spacer()
                    Text("\(game.gameState.economy.money)")
                        .fontWeight(.bold)
                        .foregroundStyle(.yellow)
                }
                .font(.caption)

                Divider()

                // Mortgage (mandatory)
                HStack {
                    Image(systemName: "house.fill")
                        .foregroundStyle(.red)
                    Text("Mortgage")
                    Spacer()
                    Text("Required")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
                .font(.caption2)

                // Food toggle
                Toggle(isOn: $payFood) {
                    HStack {
                        Image(systemName: "fork.knife")
                        Text("Food")
                    }
                    .font(.caption2)
                }

                // Utilities toggle
                Toggle(isOn: $payUtilities) {
                    HStack {
                        Image(systemName: "drop.fill")
                        Text("Utilities")
                    }
                    .font(.caption2)
                }

                // Luxuries toggle
                Toggle(isOn: $payLuxuries) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Luxuries")
                    }
                    .font(.caption2)
                }

                Divider()

                Button("Confirm") {
                    game.payExpenses(
                        food: payFood,
                        utilities: payUtilities,
                        luxuries: payLuxuries
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Bills")
    }
}
