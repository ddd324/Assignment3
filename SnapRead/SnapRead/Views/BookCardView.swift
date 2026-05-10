import SwiftUI

// Book card view
struct BookCardView: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {

                // Show cover image
                if let coverData = book.coverData,
                   let uiImage = UIImage(data: coverData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {

                    // Default icon
                    Image(systemName: "book.closed.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(16)
                        .foregroundStyle(.blue)
                }
            }
            .frame(width: 78, height: 110)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(radius: 2)

            // Book title
            Text(book.title)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)

            // Author name
            Text(book.author)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: 82)
    }
}
