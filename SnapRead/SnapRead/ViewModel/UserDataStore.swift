import Foundation

// Store user-related data locally
class UserDataStore {
    static let shared = UserDataStore()

    private let commentsKey = "comments"
    private let followingKey = "following"
    private let progressKey = "readingProgress"
    private let recentKey = "recentBookKeys"
    private let chapterKey = "readingChapterIndex"

    // Create a stable book identifier
    func bookKey(_ book: Book) -> String {
        "\(book.title.lowercased())-\(book.author.lowercased())"
    }

    // Create a user-specific storage key
    func userKey(_ base: String, username: String) -> String {
        "\(username)_\(base)"
    }

    // Save reading progress
    func saveProgress(username: String, book: Book, progress: Double) {
        var dict = UserDefaults.standard.dictionary(
            forKey: userKey(progressKey, username: username)
        ) as? [String: Double] ?? [:]

        dict[bookKey(book)] = progress
        UserDefaults.standard.set(dict, forKey: userKey(progressKey, username: username))
    }

    // Load reading progress
    func loadProgress(username: String, book: Book) -> Double {
        let dict = UserDefaults.standard.dictionary(
            forKey: userKey(progressKey, username: username)
        ) as? [String: Double] ?? [:]

        return dict[bookKey(book)] ?? 0
    }

    // Save recently viewed books
    func saveRecentlyViewed(username: String, books: [Book]) {
        let keys = books.map { bookKey($0) }
        UserDefaults.standard.set(keys, forKey: userKey(recentKey, username: username))
    }

    // Load recently viewed books
    func loadRecentlyViewed(username: String, allBooks: [Book]) -> [Book] {
        let keys = UserDefaults.standard.stringArray(
            forKey: userKey(recentKey, username: username)
        ) ?? []

        return keys.compactMap { key in
            allBooks.first { bookKey($0) == key }
        }
    }

    // Save a new comment
    func saveComment(_ comment: BookComment) {
        var comments = loadAllComments()
        comments.insert(comment, at: 0)

        if let data = try? JSONEncoder().encode(comments) {
            UserDefaults.standard.set(data, forKey: commentsKey)
        }
    }

    // Load all comments
    func loadAllComments() -> [BookComment] {
        guard let data = UserDefaults.standard.data(forKey: commentsKey),
              let comments = try? JSONDecoder().decode([BookComment].self, from: data) else {
            return []
        }

        return comments
    }

    // Load comments for one book
    func loadComments(for book: Book) -> [BookComment] {
        let key = bookKey(book)
        return loadAllComments().filter { $0.bookKey == key }
    }

    // Follow another user
    func follow(currentUser: String, targetUser: String) {
        guard currentUser != targetUser else { return }

        var dict = loadFollowingDict()
        var list = dict[currentUser] ?? []

        if !list.contains(targetUser) {
            list.append(targetUser)
        }

        dict[currentUser] = list
        saveFollowingDict(dict)
    }

    // Unfollow a user
    func unfollow(currentUser: String, targetUser: String) {
        var dict = loadFollowingDict()
        dict[currentUser]?.removeAll { $0 == targetUser }
        saveFollowingDict(dict)
    }

    // Check follow state
    func isFollowing(currentUser: String, targetUser: String) -> Bool {
        let dict = loadFollowingDict()
        return dict[currentUser]?.contains(targetUser) ?? false
    }

    // Load followed users
    func loadFollowingUsers(currentUser: String) -> [String] {
        let dict = loadFollowingDict()
        return dict[currentUser] ?? []
    }

    // Load following relationships
    private func loadFollowingDict() -> [String: [String]] {
        guard let data = UserDefaults.standard.data(forKey: followingKey),
              let dict = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            return [:]
        }

        return dict
    }

    // Save following relationships
    private func saveFollowingDict(_ dict: [String: [String]]) {
        if let data = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(data, forKey: followingKey)
        }
    }

    // Save last reading chapter
    func saveChapter(username: String, book: Book, chapterIndex: Int) {
        var dict = UserDefaults.standard.dictionary(
            forKey: userKey(chapterKey, username: username)
        ) as? [String: Int] ?? [:]

        dict[bookKey(book)] = chapterIndex

        UserDefaults.standard.set(
            dict,
            forKey: userKey(chapterKey, username: username)
        )
    }

    // Load last reading chapter
    func loadChapter(username: String, book: Book) -> Int {
        let dict = UserDefaults.standard.dictionary(
            forKey: userKey(chapterKey, username: username)
        ) as? [String: Int] ?? [:]

        return dict[bookKey(book)] ?? 0
    }

    // Load user avatar
    func loadUserAvatar(username: String) -> Data? {
        let key = "user_\(username)_avatar"
        return UserDefaults.standard.data(forKey: key)
    }
}
