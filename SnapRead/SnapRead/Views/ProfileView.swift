import SwiftUI

// Profile page
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookViewModel: BookViewModel
    @EnvironmentObject var readerViewModel: ReaderViewModel

    @State private var myCommentCount = 0

    // Following count
    var followingCount: Int {
        UserDataStore.shared.loadFollowingUsers(currentUser: authViewModel.username).count
    }

    // Followers count
    var followersCount: Int {
        UserDataStore.shared.loadAllComments()
            .map { $0.username }
            .filter { username in
                UserDataStore.shared.isFollowing(
                    currentUser: username,
                    targetUser: authViewModel.username
                )
            }
            .count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 26) {

                // User avatar
                avatarView

                Text(authViewModel.username.isEmpty ? "User" : authViewModel.username)
                    .font(.title)
                    .fontWeight(.bold)

                // Profile stats
                HStack(spacing: 34) {
                    ProfileStatView(title: "Following", value: "\(followingCount)")
                    ProfileStatView(title: "Followers", value: "\(followersCount)")
                }

                VStack(spacing: 0) {

                    // Open My Books
                    NavigationLink {
                        MyBooksView()
                    } label: {
                        ProfileSummaryRow(
                            icon: "book.fill",
                            iconColor: .orange,
                            title: "Reading Books",
                            value: "\(bookViewModel.myBooks.count)",
                            subtitle: "Saved books"
                        )
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .padding(.leading, 76)

                    // Open comments page
                    NavigationLink {
                        ReadersView()
                            .onAppear {
                                readerViewModel.selectedTab = .mine
                            }
                    } label: {
                        ProfileSummaryRow(
                            icon: "text.bubble.fill",
                            iconColor: .pink,
                            title: "My Comments",
                            value: "\(myCommentCount)",
                            subtitle: "Posted comments"
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 24))

                // Logout button
                Button {
                    authViewModel.logout()
                } label: {
                    Text("Log Out")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.red)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 14)
            }
            .padding()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {

            // Load comment count
            loadMyCommentCount()
        }
    }

    // Avatar view
    private var avatarView: some View {
        Group {
            if let data = UserDataStore.shared.loadUserAvatar(username: authViewModel.username),
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .foregroundStyle(.blue)
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
    }

    // Count user comments
    private func loadMyCommentCount() {
        myCommentCount = UserDataStore.shared.loadAllComments()
            .filter { $0.username == authViewModel.username }
            .count
    }
}

// Profile stats view
struct ProfileStatView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// Summary row view
struct ProfileSummaryRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {

            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            .frame(width: 40, height: 40)

            // Title
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()

            // Value info
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
