import SwiftUI

// User profile page
struct ProfileView: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookViewModel: BookViewModel
    @EnvironmentObject var readerViewModel: ReaderViewModel

    @State private var myCommentCount = 0
    @State private var followingCount = 0
    @State private var followersCount = 0

    var body: some View {

        ScrollView {

            VStack(spacing: 26) {

                avatarView

                Text(
                    authViewModel.username.isEmpty
                    ? "User"
                    : authViewModel.username
                )
                .font(.title)
                .fontWeight(.bold)

                HStack(spacing: 34) {

                    ProfileStatView(
                        title: "Following",
                        value: "\(followingCount)"
                    )

                    ProfileStatView(
                        title: "Followers",
                        value: "\(followersCount)"
                    )
                }

                VStack(spacing: 0) {

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
                .clipShape(
                    RoundedRectangle(cornerRadius: 24)
                )

                Button {

                    authViewModel.logout()

                } label: {

                    Text("Log Out")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.red)
                        .foregroundStyle(.white)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 14)
                        )
                }
                .padding(.top, 14)
            }
            .padding()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)

        // Load profile statistics
        .onAppear {
            loadProfileData()
        }
    }

    // Avatar display view
    private var avatarView: some View {

        Group {

            if let data = authViewModel.avatarData,
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

    // Refresh profile statistics
    private func loadProfileData() {

        let currentUser = authViewModel.username

        myCommentCount = UserDataStore.shared
            .loadAllComments()
            .filter {
                $0.username == currentUser
            }
            .count

        followingCount = UserDataStore.shared
            .loadFollowingUsers(
                currentUser: currentUser
            )
            .count

        followersCount = UserDataStore.shared
            .loadFollowersUsers(
                currentUser: currentUser
            )
            .count
    }
}

// Display profile statistic item
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

// Display one summary row on profile page
struct ProfileSummaryRow: View {

    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String

    var body: some View {

        HStack(spacing: 14) {

            ZStack {

                Circle()
                    .fill(iconColor.opacity(0.15))

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            .frame(width: 40, height: 40)

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()

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
