import SwiftUI

// Home page
struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookViewModel: BookViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Hi \(authViewModel.username.isEmpty ? "Kristin" : authViewModel.username),")
                            .font(.title3)
                            .fontWeight(.bold)

                        Text("What would you like to read next?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Open categories
                    NavigationLink {
                        CategoriesView()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.system(size: 13))

                            Text("Categories")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.blue)
                        .clipShape(Capsule())
                        .shadow(color: .blue.opacity(0.25), radius: 4, x: 0, y: 2)
                    }
                }

                // Search books
                TextField("Search books...", text: $bookViewModel.searchText)
                    .textFieldStyle(.roundedBorder)

                // Search results
                if !bookViewModel.searchText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Search Results")
                            .font(.headline)

                        ForEach(bookViewModel.filteredSearchBooks) { book in
                            NavigationLink {
                                BookDetailView(book: book)
                            } label: {
                                BookListRowView(book: book)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Recommended books
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recommended for you")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(bookViewModel.recommendedBooks) { book in
                                NavigationLink {
                                    BookDetailView(book: book)
                                } label: {
                                    BookCardView(book: book)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                // Latest books
                VStack(alignment: .leading, spacing: 12) {
                    Text("Latest")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(bookViewModel.latestBooks) { book in
                                NavigationLink {
                                    BookDetailView(book: book)
                                } label: {
                                    BookCardView(book: book)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                // Recently viewed books
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recently Viewed")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(bookViewModel.recentlyViewedBooks) { book in
                                NavigationLink {
                                    BookDetailView(book: book)
                                } label: {
                                    BookCardView(book: book)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }
}

