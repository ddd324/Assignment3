import Foundation
import Combine

// Manage book data and reading state
class BookViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var categories: [BookCategory] = []
    @Published var myBooks: [Book] = []
    @Published var searchText: String = ""
    @Published var recentlyViewedBooks: [Book] = []

    private let myBooksKey = "myBooks"

    // Latest books list
    var latestBooks: [Book] {
        books.reversed()
    }

    // Load books from local storage or EPUB bundle
    init() {
        if BookStorage.shared.hasBooks() {
            self.books = BookStorage.shared.loadBooks()
        } else {
            let importedBooks = EpubParser.importEpubsFromBundle()
            self.books = importedBooks
            BookStorage.shared.saveBooks(importedBooks)
        }

        self.categories = generateCategories(from: books)
    }

    // Recommended books
    var recommendedBooks: [Book] {
        books
    }

    // Filter books by search text
    var filteredSearchBooks: [Book] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return books
        }

        return books.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.author.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    // Load user-related book data
    func loadUserData(username: String) {
        loadMyBooks(username: username)
        loadRecentlyViewedBooks(username: username)
        applySavedProgress(username: username)
    }

    // Get books by category
    func booksByCategory(_ category: String) -> [Book] {
        books.filter { $0.category == category }
    }

    // Add a book to My Books
    func addToMyBooks(_ book: Book, username: String) {
        if !myBooks.contains(where: { sameBook($0, book) }) {
            myBooks.append(book)
            saveMyBooks(username: username)
        }
    }

    // Remove a book from My Books
    func removeFromMyBooks(_ book: Book, username: String) {
        myBooks.removeAll { sameBook($0, book) }
        saveMyBooks(username: username)
    }

    // Check whether a book is in My Books
    func isInMyBooks(_ book: Book) -> Bool {
        myBooks.contains { sameBook($0, book) }
    }

    // Update reading progress
    func updateProgress(for book: Book, username: String, progress: Double) {
        UserDataStore.shared.saveProgress(username: username, book: book, progress: progress)

        if let index = books.firstIndex(where: { sameBook($0, book) }) {
            books[index].progress = progress
        }

        if let index = myBooks.firstIndex(where: { sameBook($0, book) }) {
            myBooks[index].progress = progress
            saveMyBooks(username: username)
        }

        if let index = recentlyViewedBooks.firstIndex(where: { sameBook($0, book) }) {
            recentlyViewedBooks[index].progress = progress
        }
    }

    // Load reading progress
    func progress(for book: Book, username: String) -> Double {
        UserDataStore.shared.loadProgress(username: username, book: book)
    }

    // Save recently viewed books
    func markAsRecentlyViewed(_ book: Book, username: String) {
        recentlyViewedBooks.removeAll { sameBook($0, book) }
        recentlyViewedBooks.insert(book, at: 0)

        if recentlyViewedBooks.count > 5 {
            recentlyViewedBooks = Array(recentlyViewedBooks.prefix(5))
        }

        UserDataStore.shared.saveRecentlyViewed(username: username, books: recentlyViewedBooks)
    }

    // Generate book categories
    private func generateCategories(from books: [Book]) -> [BookCategory] {
        let grouped = Dictionary(grouping: books, by: { $0.category })

        return grouped.map { category, books in
            BookCategory(
                name: category,
                bookCount: books.count,
                coverData: books.first?.coverData
            )
        }
        .sorted { $0.name < $1.name }
    }

    // Save My Books locally
    private func saveMyBooks(username: String) {
        if let data = try? JSONEncoder().encode(myBooks) {
            UserDefaults.standard.set(
                data,
                forKey: UserDataStore.shared.userKey(myBooksKey, username: username)
            )
        }
    }

    // Load My Books from local storage
    private func loadMyBooks(username: String) {
        guard let data = UserDefaults.standard.data(
            forKey: UserDataStore.shared.userKey(myBooksKey, username: username)
        ),
        let savedBooks = try? JSONDecoder().decode([Book].self, from: data) else {
            myBooks = []
            return
        }

        myBooks = savedBooks
    }

    // Load recently viewed books
    private func loadRecentlyViewedBooks(username: String) {
        recentlyViewedBooks = UserDataStore.shared.loadRecentlyViewed(
            username: username,
            allBooks: books
        )
    }

    // Apply saved reading progress
    private func applySavedProgress(username: String) {
        for index in books.indices {
            let progress = UserDataStore.shared.loadProgress(username: username, book: books[index])
            books[index].progress = progress
        }

        for index in myBooks.indices {
            let progress = UserDataStore.shared.loadProgress(username: username, book: myBooks[index])
            myBooks[index].progress = progress
        }
    }

    // Compare whether two books are the same
    private func sameBook(_ a: Book, _ b: Book) -> Bool {
        UserDataStore.shared.bookKey(a) == UserDataStore.shared.bookKey(b)
    }
}
