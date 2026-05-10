import SwiftUI

// Book detail page
struct BookDetailView: View {
    @EnvironmentObject var bookViewModel: BookViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    let book: Book

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
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
                            .padding(20)
                            .foregroundStyle(.blue)
                    }
                }
                .frame(width: 130, height: 190)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 4)

                VStack(spacing: 6) {

                    // Book title
                    Text(book.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    // Author
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Category
                    Text(book.category)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }

                // Book information
                HStack(spacing: 28) {
                    InfoItem(title: "Words", value: "\(book.wordCount)")
                    InfoItem(
                        title: "Progress",
                        value: "\(Int(bookViewModel.progress(for: book, username: authViewModel.username) * 100))%"
                    )
                    InfoItem(title: "Chapters", value: "\(book.chapters.count)")
                }

                HStack(spacing: 14) {

                    // Add or remove from My Books
                    Button {
                        if bookViewModel.isInMyBooks(book) {
                            bookViewModel.removeFromMyBooks(book, username: authViewModel.username)
                        } else {
                            bookViewModel.addToMyBooks(book, username: authViewModel.username)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: bookViewModel.isInMyBooks(book) ? "heart.fill" : "heart")
                                .font(.system(size: 18, weight: .semibold))

                            Text("My Books")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(bookViewModel.isInMyBooks(book) ? Color.red.opacity(0.15) : Color(.systemGray6))
                        )
                        .foregroundStyle(bookViewModel.isInMyBooks(book) ? .red : .primary)
                    }

                    // Open reading page
                    NavigationLink {
                        ReadingView(book: book)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 18, weight: .semibold))

                            Text("Read")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.green, Color.green.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .green.opacity(0.25), radius: 6, y: 3)
                    }
                }

                // Book description
                VStack(alignment: .leading, spacing: 10) {
                    Text("Description")
                        .font(.headline)

                    Text(book.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

            }
            .padding()
        }
        .navigationTitle("Book Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Info item component
struct InfoItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
