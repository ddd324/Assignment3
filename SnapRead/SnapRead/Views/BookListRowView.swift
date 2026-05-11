import SwiftUI

// Book list row view
struct BookListRowView: View {
    let book: Book

    var body: some View {
        HStack(spacing: 14) {

            Group {
                // Show book cover
                if let data = book.coverData,
                   let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    // Default image
                    Image(systemName: "book.closed.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                        .foregroundStyle(.blue)
                }
            }
            .frame(width: 62, height: 86)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Book info
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.headline)

                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(book.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
