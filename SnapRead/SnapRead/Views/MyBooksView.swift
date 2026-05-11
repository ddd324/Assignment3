import SwiftUI

// My books page
struct MyBooksView: View {
    @EnvironmentObject var bookViewModel: BookViewModel

    var body: some View {
        ScrollView {
            // Empty state
            if bookViewModel.myBooks.isEmpty {
                ContentUnavailableView(
                    "No Saved Books",
                    systemImage: "heart",
                    description: Text("Books you add will appear here.")
                )
                .padding(.top, 100)
            } else {
                // Saved book list
                VStack(spacing: 14) {
                    ForEach(bookViewModel.myBooks) { book in
                        NavigationLink {
                            BookDetailView(book: book)
                        } label: {
                            MyBookRowView(book: book)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("My Books")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// My book row view
struct MyBookRowView: View {
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
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.headline)

                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ProgressView(value: book.progress)

                Text("\(Int(book.progress * 100))% completed")
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

