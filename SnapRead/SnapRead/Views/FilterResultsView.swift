import SwiftUI

// Filtered books page
struct FilterResultsView: View {
    @EnvironmentObject var bookViewModel: BookViewModel

    let categoryName: String

    // Filter books by category
    var filteredBooks: [Book] {
        bookViewModel.booksByCategory(categoryName)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                // Book count
                Text("\(filteredBooks.count) books found")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Book list
                ForEach(filteredBooks) { book in
                    NavigationLink {
                        BookDetailView(book: book)
                    } label: {
                        BookListRowView(book: book)
                    }
                    .buttonStyle(.plain)
                }

                // Empty state
                if filteredBooks.isEmpty {
                    ContentUnavailableView(
                        "No Books Found",
                        systemImage: "book.closed",
                        description: Text("There are no books in this category yet.")
                    )
                    .padding(.top, 60)
                }
            }
            .padding()
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
