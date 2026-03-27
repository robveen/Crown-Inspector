import SwiftUI

/// Displays the document/ID card a person presents
struct DocumentCardView: View {
    let document: Document
    let minimumAge: Int?

    private var formattedDOB: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: document.dateOfBirth)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Header
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 8))
                Text("ID DOCUMENT")
                    .font(.system(size: 8, weight: .bold))
                Spacer()
            }
            .foregroundStyle(.secondary)

            Divider()

            // Photo representation (appearance from document)
            HStack(spacing: 6) {
                AppearanceIconView(appearance: document.photo, size: 28)

                VStack(alignment: .leading, spacing: 1) {
                    Text(document.fullName)
                        .font(.system(size: 11, weight: .semibold))
                        .lineLimit(1)

                    Text("DOB: \(formattedDOB)")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)

                    if let minimumAge {
                        Text("Req: \(minimumAge)+")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.darkGray).opacity(0.4))
        )
        .padding(.horizontal, 4)
    }
}
