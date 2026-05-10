import SwiftUI

// App tab types
enum AppTab {
    case home
    case myBooks
    case readers
    case profile
}

// Main tab view
struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    @State private var homeID = UUID()
    @State private var myBooksID = UUID()
    @State private var readersID = UUID()
    @State private var profileID = UUID()

    var body: some View {
        TabView(selection: tabBinding) {
            NavigationStack {
                HomeView()
            }
            .id(homeID)
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(AppTab.home)

            NavigationStack {
                MyBooksView()
            }
            .id(myBooksID)
            .tabItem {
                Image(systemName: "heart")
                Text("My Books")
            }
            .tag(AppTab.myBooks)

            NavigationStack {
                ReadersView()
            }
            .id(readersID)
            .tabItem {
                Image(systemName: "globe")
                Text("Readers")
            }
            .tag(AppTab.readers)

            NavigationStack {
                ProfileView()
            }
            .id(profileID)
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
            .tag(AppTab.profile)
        }
        .tint(.blue)
    }

    // Custom tab binding
    private var tabBinding: Binding<AppTab> {
        Binding(
            get: {
                selectedTab
            },
            set: { newTab in
                selectedTab = newTab
                resetTab(newTab)
            }
        )
    }

    // Reset selected tab
    private func resetTab(_ tab: AppTab) {
        switch tab {
        case .home:
            homeID = UUID()
        case .myBooks:
            myBooksID = UUID()
        case .readers:
            readersID = UUID()
        case .profile:
            profileID = UUID()
        }
    }
}
