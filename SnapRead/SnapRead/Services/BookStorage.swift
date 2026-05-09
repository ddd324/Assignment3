import Foundation

// Manage local book storage
class BookStorage {

    static let shared = BookStorage()

    private let fileName = "books.json"

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    // Save books locally
    func saveBooks(_ books: [Book]) {
        do {
            let data = try JSONEncoder().encode(books)
            try data.write(to: fileURL)
        } catch {
            print("Save books error:", error)
        }
    }

    // Load books from local storage
    func loadBooks() -> [Book] {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([Book].self, from: data)
        } catch {
            return []
        }
    }

    // Check whether local book data exists
    func hasBooks() -> Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }

    // Remove local book data
    func clearBooks() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
