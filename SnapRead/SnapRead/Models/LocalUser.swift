import Foundation

// Local User Model
struct LocalUser: Codable {
    let username: String
    let password: String
    let avatarData: Data?
}
