import Foundation

// Book comment model
struct BookComment: Identifiable, Codable {

    let id: UUID
    let bookKey: String
    let username: String
    let content: String
    let date: Date

    // Initialize comment data
    init(
        id: UUID = UUID(),
        bookKey: String,
        username: String,
        content: String,
        date: Date = Date()
    ) {
        self.id = id
        self.bookKey = bookKey
        self.username = username
        self.content = content
        self.date = date
    }
}
