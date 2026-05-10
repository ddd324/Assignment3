import Foundation

// Reader Post Model
struct ReaderPost: Identifiable {
    let id = UUID()
    let username: String
    let avatarName: String
    let content: String
    let date: String
    let recommendedBook: Book
}
