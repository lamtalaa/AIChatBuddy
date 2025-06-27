import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

struct GoogleSignInButtonView: View {
    @State private var navigateToModeSelection = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Button(action: handleGoogleSignIn) {
                    HStack(spacing: 12) {
                        Image("googleLogo")
                            .resizable()
                            .frame(width: 22, height: 22)

                        Text("Sign in with Google")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                }
            }
            .navigationDestination(isPresented: $navigateToModeSelection) {
                ModeSelectionView(isGuest: false)
            }
        }
    }

    func handleGoogleSignIn() {
        guard let presentingVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            print("❌ No root view controller")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            if let error = error {
                print("❌ Google Sign-In failed: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("❌ Missing ID Token")
                return
            }

            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("❌ Firebase Sign-In failed: \(error.localizedDescription)")
                } else {
                    print("✅ Google Sign-In successful for: \(authResult?.user.email ?? "Unknown")")
                    navigateToModeSelection = true
                }
            }
        }
    }
}
