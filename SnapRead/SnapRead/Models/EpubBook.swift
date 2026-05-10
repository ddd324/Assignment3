import Foundation

// Epub Book Model
struct EpubBook: Identifiable, Codable {
    let id: UUID
    let title: String
    let author: String
    let chapters: [String]
}
