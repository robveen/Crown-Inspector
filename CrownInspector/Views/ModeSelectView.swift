import SwiftUI

struct ModeSelectView: View {
    @EnvironmentObject var game: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(GameMode.allCases, id: \.rawValue) { mode in
                    Button {
                        game.selectMode(mode)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: mode.icon)
                                .font(.system(size: 16))
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(mode.displayName)
                                    .font(.caption)
                                    .fontWeight(.bold)

                                Text(mode.description)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Play")
    }
}
