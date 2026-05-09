import Foundation
import Combine

// Manage readers page state
class ReaderViewModel: ObservableObject {

    // All reader posts
    @Published var posts: [ReaderPost] = []

    // Current selected tab
    @Published var selectedTab: ReaderTab = .recommended
}

// Readers page tabs
enum ReaderTab: String, CaseIterable {

    case recommended = "Recommended"
    case following = "Following"
    case mine = "Mine"
}
