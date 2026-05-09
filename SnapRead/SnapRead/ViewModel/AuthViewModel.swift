import Foundation
import Combine

// Manage local authentication state
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool
    @Published var username: String
    @Published var avatarData: Data?
    @Published var errorMessage: String = ""
    
    private let userKey = "localUser"
    private let loginKey = "isLoggedIn"
    
    // Load saved login status and user data
    init() {
        let savedLogin = UserDefaults.standard.bool(forKey: loginKey)
        let savedUserData = UserDefaults.standard.data(forKey: userKey)

        if savedLogin,
           let data = savedUserData,
           let user = try? JSONDecoder().decode(LocalUser.self, from: data) {

            self.isLoggedIn = true
            self.username = user.username
            self.avatarData = user.avatarData

        } else {
            self.isLoggedIn = false
            self.username = ""
            self.avatarData = nil
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

        let user = LocalUser(
            username: name,
            password: password,
            avatarData: avatarData
        )

        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }

        self.username = name
        self.avatarData = avatarData
        self.isLoggedIn = true

        UserDefaults.standard.set(true, forKey: loginKey)
        UserDefaults.standard.set(avatarData, forKey: "user_\(name)_avatar")

        errorMessage = ""
        return true
    }
    
    // Login with saved local user data
    func login(username: String, password: String) -> Bool {
        let name = username.trimmingCharacters(in: .whitespaces)

        guard let savedUser = loadLocalUser() else {
            errorMessage = "No account found. Please sign up first."
            return false
        }

        guard savedUser.username == name && savedUser.password == password else {
            errorMessage = "Incorrect username or password."
            return false
        }

        NotificationCenter.default.post(name: Notification.Name("UserLoggedIn"), object: nil)

        self.username = savedUser.username
        self.avatarData = savedUser.avatarData
        self.isLoggedIn = true

        UserDefaults.standard.set(true, forKey: loginKey)

        errorMessage = ""
        return true
    }
    
    // Clear current login state
    func logout() {
        isLoggedIn = false
        username = ""
        avatarData = nil
        UserDefaults.standard.set(false, forKey: loginKey)
    }

    // Load saved local user
    private func loadLocalUser() -> LocalUser? {
        guard let data = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(LocalUser.self, from: data) else {
            return nil
        }

        return user
    }
    
}
