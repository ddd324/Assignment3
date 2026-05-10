import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookViewModel: BookViewModel

    var body: some View {
        Group {
            // Show main app after login
            if authViewModel.isLoggedIn {
                MainTabView()
                    .onAppear {
                        bookViewModel.loadUserData(username: authViewModel.username)
                    }
            } else {
                LoginView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UserLoggedIn"))) { _ in
            // Reload user data
            bookViewModel.loadUserData(username: authViewModel.username)
        }
    }
}
