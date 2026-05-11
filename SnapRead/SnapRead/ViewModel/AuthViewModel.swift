import Foundation
import Combine

// Manage local authentication state
class AuthViewModel: ObservableObject {

    @Published var isLoggedIn: Bool
    @Published var username: String
    @Published var avatarData: Data?
    @Published var errorMessage: String = ""

    private let usersKey = "localUsers"
    private let oldUserKey = "localUser"
    private let loginKey = "isLoggedIn"
    private let currentUserKey = "currentUser"

    // Load saved login status and current user data
    init() {
        self.isLoggedIn = false
        self.username = ""
        self.avatarData = nil

        migrateOldUserIfNeeded()

        let savedLogin = UserDefaults.standard.bool(forKey: loginKey)
        let savedUsername = UserDefaults.standard.string(forKey: currentUserKey) ?? ""
        let users = loadUsers()

        if savedLogin,
           let user = users[savedUsername] {
            self.isLoggedIn = true
            self.username = user.username
            self.avatarData = user.avatarData
        }
    }

    // Register a new local user
    func signup(username: String, password: String, avatarData: Data?) -> Bool {
        let name = username.trimmingCharacters(in: .whitespaces)

        guard !name.isEmpty else {
            errorMessage = "Please enter username."
            return false
        }

        guard password.count >= 4 else {
            errorMessage = "Password must be at least 4 characters."
            return false
        }

        guard avatarData != nil else {
            errorMessage = "Please select an avatar."
            return false
        }

        var users = loadUsers()

        guard users[name] == nil else {
            errorMessage = "Username already exists."
            return false
        }

        let user = LocalUser(
            username: name,
            password: password,
            avatarData: avatarData
        )

        users[name] = user
        saveUsers(users)

        self.username = name
        self.avatarData = avatarData
        self.isLoggedIn = true

        UserDefaults.standard.set(true, forKey: loginKey)
        UserDefaults.standard.set(name, forKey: currentUserKey)
        UserDefaults.standard.set(avatarData, forKey: "user_\(name)_avatar")

        NotificationCenter.default.post(
            name: Notification.Name("UserLoggedIn"),
            object: nil
        )

        errorMessage = ""
        return true
    }

    // Login with saved local user data
    func login(username: String, password: String) -> Bool {
        let name = username.trimmingCharacters(in: .whitespaces)
        let users = loadUsers()

        guard let savedUser = users[name] else {
            errorMessage = "No account found. Please sign up first."
            return false
        }

        guard savedUser.password == password else {
            errorMessage = "Incorrect username or password."
            return false
        }

        self.username = savedUser.username
        self.avatarData = savedUser.avatarData
        self.isLoggedIn = true

        UserDefaults.standard.set(true, forKey: loginKey)
        UserDefaults.standard.set(savedUser.username, forKey: currentUserKey)
        UserDefaults.standard.set(savedUser.avatarData, forKey: "user_\(savedUser.username)_avatar")

        NotificationCenter.default.post(
            name: Notification.Name("UserLoggedIn"),
            object: nil
        )

        errorMessage = ""
        return true
    }

    // Clear current login state
    func logout() {
        isLoggedIn = false
        username = ""
        avatarData = nil
        errorMessage = ""

        UserDefaults.standard.set(false, forKey: loginKey)
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }

    // Load all saved users
    private func loadUsers() -> [String: LocalUser] {
        guard let data = UserDefaults.standard.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([String: LocalUser].self, from: data) else {
            return [:]
        }

        return users
    }

    // Save all users
    private func saveUsers(_ users: [String: LocalUser]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }

    // multi-user storage
    private func migrateOldUserIfNeeded() {
        var users = loadUsers()

        guard users.isEmpty,
              let oldData = UserDefaults.standard.data(forKey: oldUserKey),
              let oldUser = try? JSONDecoder().decode(LocalUser.self, from: oldData) else {
            return
        }

        users[oldUser.username] = oldUser
        saveUsers(users)

        UserDefaults.standard.set(oldUser.username, forKey: currentUserKey)

        if let avatarData = oldUser.avatarData {
            UserDefaults.standard.set(
                avatarData,
                forKey: "user_\(oldUser.username)_avatar"
            )
        }
    }
}
