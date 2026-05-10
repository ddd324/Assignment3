import SwiftUI

@main
struct SnapReadApp: App {

    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var bookViewModel = BookViewModel()
    @StateObject private var readerViewModel = ReaderViewModel()

    var body: some Scene {
        WindowGroup {

            // Main content view
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(bookViewModel)
                .environmentObject(readerViewModel)
        }
    }
}
