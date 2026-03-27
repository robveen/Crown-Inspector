import SwiftUI

/// Pre-shift checklist — VIPs to admit, blacklisted to deny, rules
struct BriefingView: View {
    @EnvironmentObject var game: GameManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if let briefing = game.currentBriefing {
                    Text(briefing.event.name)
                        .font(.caption)
                        .fontWeight(.bold)

                    Divider()

                    // Rules
                    if !briefing.specialRules.isEmpty {
                        sectionHeader("Rules", icon: "list.clipboard")
                        ForEach(briefing.specialRules, id: \.self) { rule in
                            bulletItem(rule, color: .orange)
                        }
                    }

                    // VIP list
                    if !briefing.vipNames.isEmpty {
                        sectionHeader("VIP - Always Admit", icon: "star.fill")
                        ForEach(briefing.vipNames, id: \.self) { name in
                            bulletItem(name, color: .green)
                        }
                    }

                    // Blacklist
                    if !briefing.blacklistedNames.isEmpty {
                        sectionHeader("Blacklist - Always Deny", icon: "xmark.shield.fill")
                        ForEach(briefing.blacklistedNames, id: \.self) { name in
                            bulletItem(name, color: .red)
                        }
                    }

                    Divider()

                    Button {
                        game.startShiftFromBriefing()
                    } label: {
                        Label("Start Shift", systemImage: "hand.raised.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
            .padding(.horizontal, 6)
        }
        .navigationTitle("Briefing")
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(.secondary)
        .padding(.top, 4)
    }

    private func bulletItem(_ text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 5, height: 5)
            Text(text)
                .font(.system(size: 10))
                .lineLimit(1)
        }
    }
}
