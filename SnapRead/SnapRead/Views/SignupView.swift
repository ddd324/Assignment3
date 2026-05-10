import SwiftUI
import PhotosUI

// Sign up page
struct SignupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var username = ""
    @State private var password = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var avatarData: Data?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "book.fill")
                .font(.system(size: 58))
                .foregroundStyle(.blue)

            Text("SnapRead")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.blue)

            VStack(spacing: 18) {
                Text("Create Account")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Select avatar
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let avatarData,
                       let uiImage = UIImage(data: avatarData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 76, height: 76)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 76, height: 76)
                            .background(.gray)
                            .clipShape(Circle())
                    }
                }

                // Sign up form
                VStack(alignment: .leading, spacing: 12) {
                    Text("Username")
                        .font(.caption)
                        .fontWeight(.semibold)

                    TextField("Enter your name", text: $username)
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

                // Error message
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                // Sign up
                Button {
                    authViewModel.signup(
                        username: username,
                        password: password,
                        avatarData: avatarData
                    )
                } label: {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 28)

            Spacer()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedItem) { newItem in
            Task {
                // Load selected image
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data),
                   let compressedData = image.jpegData(compressionQuality: 0.3) {
                    avatarData = compressedData
                }
            }
        }
    }
}

