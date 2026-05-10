import SwiftUI

// Login page
struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var username = ""
    @State private var password = ""
    @State private var showSignup = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "book.fill")
                    .font(.system(size: 58))
                    .foregroundStyle(.blue)

                Text("SnapRead")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)

                // Login form
                VStack(alignment: .leading, spacing: 14) {
                    Text("Username")
                        .font(.caption)
                        .fontWeight(.semibold)

                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.asciiCapable)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled(true)

                    Text("Password")
                        .font(.caption)
                        .fontWeight(.semibold)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal, 28)

                // Error message
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                // Sign in
                Button {
                    authViewModel.login(username: username, password: password)
                } label: {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal, 28)

                HStack {
                    Text("Don't have an account?")
                        .font(.caption)

                    // Open sign up page
                    Button("Sign Up") {
                        showSignup = true
                    }
                    .font(.caption)
                }

                Spacer()
            }
            .navigationDestination(isPresented: $showSignup) {
                SignupView()
            }
        }
    }
}


