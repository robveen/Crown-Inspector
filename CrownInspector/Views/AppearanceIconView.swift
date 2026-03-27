import SwiftUI

/// Visual representation of a person's appearance using SF Symbols
struct AppearanceIconView: View {
    let appearance: Appearance
    let size: CGFloat

    var body: some View {
        ZStack {
            // Base face
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: size, height: size)

            // Hair indicator (colored circle on top)
            Circle()
                .fill(hairColor)
                .frame(width: size * 0.4, height: size * 0.4)
                .offset(y: -size * 0.3)

            // Face icon
            Image(systemName: faceIcon)
                .font(.system(size: size * 0.45))
                .foregroundStyle(.white)

            // Accessory indicator
            if let accessory = appearance.accessory {
                accessoryOverlay(accessory)
            }
        }
        .frame(width: size, height: size)
    }

    private var hairColor: Color {
        switch appearance.hairColor {
        case .blonde: return .yellow
        case .brown: return .brown
        case .black: return .black
        case .red: return .red
        case .gray: return .gray
        case .pink: return .pink
        case .blue: return .blue
        }
    }

    private var faceIcon: String {
        switch appearance.hairStyle {
        case .short: return "person.circle"
        case .long: return "person.circle.fill"
        case .buzzed: return "person.crop.circle"
        case .curly: return "person.crop.circle.fill"
        case .mohawk: return "person.circle"
        case .bald: return "person.crop.circle"
        }
    }

    @ViewBuilder
    private func accessoryOverlay(_ accessory: Appearance.Accessory) -> some View {
        switch accessory {
        case .glasses:
            Image(systemName: "eyeglasses")
                .font(.system(size: size * 0.25))
                .foregroundStyle(.white.opacity(0.8))
        case .sunglasses:
            Image(systemName: "sunglasses.fill")
                .font(.system(size: size * 0.25))
                .foregroundStyle(.white.opacity(0.8))
        case .hat:
            Image(systemName: "crown.fill")
                .font(.system(size: size * 0.2))
                .foregroundStyle(.yellow)
                .offset(y: -size * 0.35)
        case .earring:
            Circle()
                .fill(Color.yellow)
                .frame(width: size * 0.1, height: size * 0.1)
                .offset(x: size * 0.35, y: size * 0.05)
        case .nosePiercing:
            Circle()
                .fill(Color.gray)
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(y: size * 0.05)
        }
    }
}
