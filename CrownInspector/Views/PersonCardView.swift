import SwiftUI

/// Displays the actual person at the gate — optimized for vertical (left) split panel
struct PersonCardView: View {
    let person: Person

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Header
            HStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 7))
                Text("GATE")
                    .font(.system(size: 7, weight: .bold))
                Spacer()
                if person.specialStatus == .vip {
                    Text("VIP")
                        .font(.system(size: 7, weight: .black))
                        .foregroundStyle(.yellow)
                } else if person.specialStatus == .blacklisted {
                    Text("BAN")
                        .font(.system(size: 7, weight: .black))
                        .foregroundStyle(.red)
                }
            }
            .foregroundStyle(.secondary)

            // Person appearance
            AppearanceIconView(appearance: person.appearance, size: 32)
                .frame(maxWidth: .infinity, alignment: .center)

            // Name they state
            Text(person.firstName)
                .font(.system(size: 9, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(person.lastName)
                .font(.system(size: 9, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // What they claim
            Text("Says:")
                .font(.system(size: 7))
                .foregroundStyle(.secondary)
            Text(formattedDOB)
                .font(.system(size: 9, weight: .medium, design: .monospaced))

            Spacer(minLength: 0)
        }
        .padding(4)
    }

    private var formattedDOB: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: person.dateOfBirth)
    }
}
