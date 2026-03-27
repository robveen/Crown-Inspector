import SwiftUI

/// Displays the document/ID card — optimized for vertical (right) split panel
struct DocumentCardView: View {
    let document: Document
    let minimumAge: Int?

    private var formattedDOB: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: document.dateOfBirth)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Header
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 7))
                Text("ID")
                    .font(.system(size: 7, weight: .bold))
                Spacer()
                if let minimumAge {
                    Text("\(minimumAge)+")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(.orange)
                }
            }
            .foregroundStyle(.secondary)

            // Photo (document appearance)
            AppearanceIconView(appearance: document.photo, size: 32)
                .frame(maxWidth: .infinity, alignment: .center)

            // Name
            Text(document.firstName)
                .font(.system(size: 9, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(document.lastName)
                .font(.system(size: 9, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // DOB — player must calculate age themselves
            Text("DOB")
                .font(.system(size: 7))
                .foregroundStyle(.secondary)
            Text(formattedDOB)
                .font(.system(size: 9, weight: .medium, design: .monospaced))

            Spacer(minLength: 0)
        }
        .padding(4)
    }
}
