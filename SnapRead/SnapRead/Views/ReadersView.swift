import SwiftUI

// Readers page
struct ReadersView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookViewModel: BookViewModel
    @EnvironmentObject var readerViewModel: ReaderViewModel

    @State private var allComments: [BookComment] = []

    // Filter comments
    var displayedComments: [BookComment] {
        switch readerViewModel.selectedTab {

        case .recommended:
            return allComments

        case .following:
            let followingUsers = UserDataStore.shared.loadFollowingUsers(
                currentUser: authViewModel.username
            )

            return allComments.filter {
                followingUsers.contains($0.username)
            }

        case .mine:
            return allComments.filter {
                $0.username == authViewModel.username
            }
        }
    }

    var body: some View {
        VStack {

            // Comment tabs
            Picker("Reader Tab", selection: $readerViewModel.selectedTab) {
                ForEach(ReaderTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            var emptyTitle: String {
                switch readerViewModel.selectedTab {
                case .recommended:
                    return "No Comments Yet"
                case .following:
                    return "No Following Comments"
                case .mine:
                    return "No My Comments"
                }
            }

            var emptyDescription: String {
                switch readerViewModel.selectedTab {
                case .recommended:
                    return "Comments from readers will appear here."
                case .following:
                    return "Comments from people you follow will appear here."
                case .mine:
                    return "Your comments will appear here."
                }
            }

            // Empty state
            if displayedComments.isEmpty {
                ContentUnavailableView(
                    emptyTitle,
                    systemImage: "text.bubble",
                    description: Text(emptyDescription)
                )
                .padding(.top, 80)
            } else {

                // Comment list
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(displayedComments) { comment in
                            if let book = bookForComment(comment) {
                                ReaderCommentCard(
                                    comment: comment,
                                    book: book,
                                    currentUsername: authViewModel.username,
                                    refreshAction: loadComments
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Readers")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {

            // Load comments
            loadComments()
        }
    }

    // Load all comments
    private func loadComments() {
        allComments = UserDataStore.shared.loadAllComments()
    }

    // Find related book
    private func bookForComment(_ comment: BookComment) -> Book? {
        bookViewModel.books.first {
            UserDataStore.shared.bookKey($0) == comment.bookKey
        }
    }
}

// Comment card view
struct ReaderCommentCard: View {
    let comment: BookComment
    let book: Book
    let currentUsername: String
    let refreshAction: () -> Void

    // Check own comment
    var isOwnComment: Bool {
        comment.username == currentUsername
    }

    // Check follow status
    var isFollowing: Bool {
        UserDataStore.shared.isFollowing(
            currentUser: currentUsername,
            targetUser: comment.username
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {

                // User avatar
                Group {
                    if let data = UserDataStore.shared.loadUserAvatar(username: comment.username),
                       let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(6)
                            .foregroundStyle(.blue)
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(comment.username)
                        .font(.headline)

                    Text(formatDate(comment.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Follow button
                if !isOwnComment {
                    Button {
                        if isFollowing {
                            UserDataStore.shared.unfollow(
                                currentUser: currentUsername,
                                targetUser: comment.username
                            )
                        } else {
                            UserDataStore.shared.follow(
                                currentUser: currentUsername,
                                targetUser: comment.username
                            )
                        }

                        refreshAction()
                    } label: {
                        Text(isFollowing ? "Following" : "Follow")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isFollowing ? Color(.systemGray5) : Color.blue)
                            .foregroundColor(isFollowing ? Color.primary : Color.white)
                            .clipShape(Capsule())
                    }
                }
            }

            // Comment content
            Text(comment.content)
                .font(.body)

            // Book link
            NavigationLink {
                BookDetailView(book: book)
            } label: {
                HStack(spacing: 12) {

                    // Book cover
                    Group {
                        if let data = book.coverData,
                           let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "book.closed.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(10)
                                .foregroundStyle(.blue)
                        }
                    }
                    .frame(width: 52, height: 72)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(book.author)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 4)
    }

    // Format date
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
