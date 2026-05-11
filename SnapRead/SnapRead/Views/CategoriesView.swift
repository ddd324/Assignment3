import SwiftUI

// Categories page
struct CategoriesView: View {
    @EnvironmentObject var bookViewModel: BookViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Show category list
                ForEach(bookViewModel.categories) { category in
                    NavigationLink {
                        FilterResultsView(categoryName: category.name)
                    } label: {
                        CategoryRowView(category: category)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Category row view
struct CategoryRowView: View {
    let category: BookCategory

    var body: some View {
        HStack(spacing: 14) {

            Group {

                // Show category cover
                if let data = category.coverData,
                   let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {

                    // Default image
                    Image(systemName: "books.vertical.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                        .foregroundStyle(.blue)
                }
            }
            .frame(width: 56, height: 76)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Category info
            VStack(alignment: .leading, spacing: 6) {
                Text(category.name)
                    .font(.headline)

                Text("\(category.bookCount) Books")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Arrow icon
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
