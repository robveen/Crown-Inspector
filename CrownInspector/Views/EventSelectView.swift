import SwiftUI

struct EventSelectView: View {
    @EnvironmentObject var game: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(EventTier.allCases, id: \.rawValue) { tier in
                    let unlocked = game.gameState.isTierUnlocked(tier)
                    let events = EventFactory.events(for: tier)

                    ForEach(events) { event in
                        Button {
                            game.selectEvent(event)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(event.name)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                    Spacer()
                                    if !unlocked {
                                        Image(systemName: "lock.fill")
                                            .font(.caption2)
                                    }
                                }

                                Text(tier.description)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)

                                HStack {
                                    Label("\(event.payPerCorrect)", systemImage: "dollarsign.circle")
                                    Spacer()
                                    Label(event.difficulty.displayName, systemImage: "speedometer")
                                }
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .disabled(!unlocked)
                        .opacity(unlocked ? 1.0 : 0.4)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Select Gig")
    }
}
