import SwiftUI

// Reading page
struct ReadingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var bookViewModel: BookViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    let book: Book

    @State private var chapterIndex = 0
    @State private var fontSize: CGFloat = 18
    @State private var showTOC = false
    @State private var showComments = false
    @State private var comments: [BookComment] = []
    @State private var newComment = ""
    @State private var theme: ReaderTheme = .light

    // Reading progress
    private var progress: Double {
        guard !book.chapters.isEmpty else { return 0 }
        return Double(chapterIndex + 1) / Double(book.chapters.count)
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {

                // Top toolbar
                topBar

                // Chapter pages
                TabView(selection: $chapterIndex) {
                    ForEach(book.chapters.indices, id: \.self) { index in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 22) {
                                Text("Chapter \(index + 1)")
                                    .font(.headline)
                                    .foregroundColor(theme.text)

                                Text(book.chapters[index])
                                    .font(.system(size: fontSize))
                                    .foregroundColor(theme.text)
                                    .lineSpacing(8)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 28)
                            .padding(.bottom, 50)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }

            // TOC overlay
            if showTOC {
                tocFullScreen
            }

            // Comments overlay
            if showComments {
                commentsFullScreen
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {

            // Load saved chapter
            let savedIndex = UserDataStore.shared.loadChapter(
                username: authViewModel.username,
                book: book
            )

            chapterIndex = savedIndex

            bookViewModel.markAsRecentlyViewed(book, username: authViewModel.username)
            comments = UserDataStore.shared.loadComments(for: book)

            saveProgress()
        }
        .onChange(of: chapterIndex) { newValue in

            // Save reading progress
            saveProgress()

            UserDataStore.shared.saveChapter(
                username: authViewModel.username,
                book: book,
                chapterIndex: newValue
            )
        }
    }

    // Save progress
    private func saveProgress() {
        bookViewModel.updateProgress(
            for: book,
            username: authViewModel.username,
            progress: progress
        )
    }
}

extension ReadingView {

    // Top toolbar
    var topBar: some View {
        HStack(spacing: 22) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .medium))
            }

            Spacer()

            // Open TOC
            Button {
                showTOC = true
            } label: {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 24))
            }

            // Open comments
            Button {
                showComments = true
            } label: {
                Image(systemName: "bubble.left")
                    .font(.system(size: 24))
            }

            // Change theme
            Button {
                theme.toggle()
                saveProgress()
            } label: {
                Image(systemName: "sun.max")
                    .font(.system(size: 24))
            }

            // Change font size
            Button {
                if fontSize < 30 {
                    fontSize += 2
                } else {
                    fontSize = 16
                }

                saveProgress()
            } label: {
                Text("A")
                    .font(.system(size: 28, weight: .bold))
            }
        }
        .foregroundColor(theme.text)
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .background(theme.background)
    }
}

extension ReadingView {

    // TOC screen
    var tocFullScreen: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    showTOC = false
                }

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Table of Contents")
                        .font(.title3)
                        .fontWeight(.bold)

                    Spacer()

                    Button {
                        showTOC = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()

                Divider()

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(book.chapters.indices, id: \.self) { index in

                            // Chapter button
                            Button {
                                chapterIndex = index
                                saveProgress()
                                showTOC = false
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Chapter \(index + 1)")
                                            .font(.headline)
                                            .foregroundStyle(index == chapterIndex ? .blue : .primary)

                                        Text(chapterPreview(for: index))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    if index == chapterIndex {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.blue)
                                    }
                                }
                                .padding()
                                .background(index == chapterIndex ? Color.blue.opacity(0.12) : Color.clear)
                            }
                            .buttonStyle(.plain)

                            Divider()
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal, 18)
            .padding(.vertical, 70)
        }
    }

    // Chapter preview text
    private func chapterPreview(for index: Int) -> String {
        guard book.chapters.indices.contains(index) else {
            return ""
        }

        return book.chapters[index]
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension ReadingView {

    // Comments screen
    var commentsFullScreen: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    showComments = false
                }

            VStack(spacing: 0) {
                HStack {
                    Text("Comments")
                        .font(.title3)
                        .fontWeight(.bold)

                    Spacer()

                    Button {
                        showComments = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()

                Divider()

                VStack(spacing: 10) {

                    // Comment input
                    TextEditor(text: $newComment)
                        .frame(height: 90)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Send comment
                    Button {
                        let text = newComment.trimmingCharacters(in: .whitespacesAndNewlines)

                        guard !text.isEmpty else {
                            return
                        }

                        let comment = BookComment(
                            bookKey: UserDataStore.shared.bookKey(book),
                            username: authViewModel.username,
                            content: text
                        )

                        UserDataStore.shared.saveComment(comment)
                        comments = UserDataStore.shared.loadComments(for: book)
                        newComment = ""
                    } label: {
                        Text("Send Comment")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()

                // Comment list
                ScrollView {
                    VStack(spacing: 16) {
                        if comments.isEmpty {
                            Text("No comments yet.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 40)
                        } else {
                            ForEach(comments) { comment in
                                ReaderStyleCommentCard(
                                    username: comment.username,
                                    date: formatDate(comment.date),
                                    content: comment.content,
                                    book: book
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal, 18)
            .padding(.vertical, 70)
        }
    }

    // Format date
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Comment card view
struct ReaderStyleCommentCard: View {
    let username: String
    let date: String
    let content: String
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {

                // User avatar
                Group {
                    if let data = UserDataStore.shared.loadUserAvatar(username: username),
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
                    Text(username)
                        .font(.headline)

                    Text(date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            // Comment text
            Text(content)
                .font(.body)

            // Book info
            HStack(spacing: 12) {
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
                        .lineLimit(1)

                    Text(book.author)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 4)
    }
}

// Reader themes
enum ReaderTheme {
    case light
    case dark
    case sepia

    var background: Color {
        switch self {
        case .light:
            return Color(.systemBackground)
        case .dark:
            return .black
        case .sepia:
            return Color(red: 0.95, green: 0.90, blue: 0.80)
        }
    }

    var text: Color {
        switch self {
        case .light:
            return .primary
        case .dark:
            return .white
        case .sepia:
            return .brown
        }
    }

    // Switch theme
    mutating func toggle() {
        switch self {
        case .light:
            self = .dark
        case .dark:
            self = .sepia
        case .sepia:
            self = .light
        }
    }
}
