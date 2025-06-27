import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss

    @State private var newUserName = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showSuccessAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Image("mainScreenArt")
                    .resizable()
                    .ignoresSafeArea()
//                    .overlay(Color.black.opacity(0.2))

                VStack(spacing: 20) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(radius: 10)

                    TextField("", text: $newUserName, prompt: Text("Email").foregroundColor(.gray))
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                    SecureField("", text: $newPassword, prompt: Text("Password").foregroundColor(.gray))
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                    SecureField("", text: $confirmPassword, prompt: Text("Confirm Password").foregroundColor(.gray))
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: signUp) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Sign Up")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(colors: [Color.blue, Color.purple],
                                                           startPoint: .topLeading,
                                                           endPoint: .bottomTrailing))
                                .cornerRadius(14)
                                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                    .disabled(isLoading)

                    Spacer()
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                                .fontWeight(.bold)
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.85), Color.blue.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .cornerRadius(12)
                        )
                        .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 2)
                    }
                }
            }
            .alert("Account Created", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your account has been successfully created.")
            }
        }
    }

    private func signUp() {
        errorMessage = nil

        guard !newUserName.isEmpty, !newPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true

        Auth.auth().createUser(withEmail: newUserName, password: newPassword) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    showSuccessAlert = true
                }
            }
        }
    }
}
