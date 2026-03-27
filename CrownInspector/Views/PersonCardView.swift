import SwiftUI

/// Displays the actual person standing in front of you
struct PersonCardView: View {
    let person: Person

    private var formattedDOB: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: person.dateOfBirth)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Header
            HStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 8))
                Text("AT THE GATE")
                    .font(.system(size: 8, weight: .bold))
                Spacer()
            }
            .foregroundStyle(.secondary)

            Divider()

            // Actual person appearance
            HStack(spacing: 6) {
                AppearanceIconView(appearance: person.appearance, size: 28)

                VStack(alignment: .leading, spacing: 1) {
                    Text(person.fullName)
                        .font(.system(size: 11, weight: .semibold))
                        .lineLimit(1)

                    Text("Claims: \(formattedDOB)")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.darkGray).opacity(0.3))
        )
        .padding(.horizontal, 4)
    }
}
