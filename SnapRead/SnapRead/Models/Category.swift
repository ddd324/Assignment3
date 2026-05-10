import Foundation

// Book Category Model
struct BookCategory: Identifiable {
    let id = UUID()
    let name: String
    let bookCount: Int
    let coverData: Data?
}
