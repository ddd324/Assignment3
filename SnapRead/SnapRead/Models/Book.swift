import Foundation

// Book model
struct Book: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let author: String
    let category: String
    let coverName: String
    let coverData: Data?
    let description: String
    let chapters: [String]
    let wordCount: Int
    var progress: Double

    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        category: String,
        coverName: String = "book.closed.fill",
        coverData: Data? = nil,
        description: String,
        chapters: [String],
        wordCount: Int,
        progress: Double = 0.0
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.category = category
        self.coverName = coverName
        self.coverData = coverData
        self.description = description
        self.chapters = chapters
        self.wordCount = wordCount
        self.progress = progress
    }
}
