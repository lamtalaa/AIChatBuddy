//
//  ModeSelectionView.swift
//  AIChatBuddy
//
//  Created by Yassine Lamtalaa on 5/28/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

struct ModeSelectionView: View {
    let isGuest: Bool
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @State private var showLoginView = false
    @State private var showLogoutAlert = false
    @State private var userName: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Image("mainScreenArt")
                    .resizable()
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()

                    if let userName = userName {
                        Text("Welcome, \(userName) 👋")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .transition(.opacity)
                    }
                    
                    Text("Tip: Sharing a bit about yourself makes the experience even better!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top)

                    ForEach(["Roast Me", "Compliment Me", "Surprise Me"], id: \.self) { mode in
                        NavigationLink(destination: ChatView(viewModel: ChatViewModel(mode: mode), isGuest: isGuest)) {
                            Text(mode)
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(gradientForMode(mode))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .padding(.horizontal)
                        }
                    }

                    VStack {
                        Spacer()
                        if !isGuest {
                            HStack(spacing: 16) {
                                NavigationLink(destination:
                                                ZStack {
                                    ProfileViewRepresentable()
                                        .edgesIgnoringSafeArea(.all)
                                }) {
                                    Text("Profile")
                                        .edgesIgnoringSafeArea(.all)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.pink.opacity(0.8), Color.orange.opacity(0.8)],
                                                startPoint: .topLeading, endPoint: .bottomTrailing
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                }

                                NavigationLink(destination:
                                                ZStack {
                                    HistoryViewRepresentable()
                                        .edgesIgnoringSafeArea(.all)
                                }) {
                                    Text("History")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                                                startPoint: .topLeading, endPoint: .bottomTrailing
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }

                    Spacer()
                }
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    if isGuest {
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
                }
                .toolbar {
                    if !isGuest {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showLogoutAlert = true
                            }) {
                                Text("Log Out")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.red.opacity(0.9), lineWidth: 1.5)
                                            .background(Color.white.opacity(0.05).cornerRadius(12))
                                    )
                                    .shadow(color: Color.red.opacity(0.3), radius: 3, x: 0, y: 1)
                            }
                        }
                    }
                }
                .onAppear {
                    guard let user = Auth.auth().currentUser else { return }

                    let uid = user.uid
                    let firestore = Firestore.firestore()

                    // 1. Try fetching name from Firestore
                    firestore.collection("users").document(uid).getDocument { document, error in
                        if let data = document?.data(), let firestoreName = data["name"] as? String, !firestoreName.isEmpty {
                            userName = firestoreName
                        } else {
                            // 2. Fallback to displayName from Google/Firebase
                            if let googleName = user.displayName, !googleName.isEmpty {
                                userName = googleName
                            } else {
                                userName = "Friend" // fallback default name
                            }
                        }
                    }
                }
                .fullScreenCover(isPresented: $showLoginView) {
                    MainView()
                }
                .alert("Are you sure you want to log out?", isPresented: $showLogoutAlert) {
                    Button("Log Out", role: .destructive, action: handleLogout)
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
    }

    func handleLogout() {
        // Sign out from Firebase
        do {
            try Auth.auth().signOut()

            // Sign out from Google
            if GIDSignIn.sharedInstance.currentUser != nil {
                GIDSignIn.sharedInstance.signOut()
            }

            // Optional: remove any saved local data
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()

            showLoginView = true
        } catch {
            print("❌ Logout failed: \(error.localizedDescription)")
        }
    }

    func gradientForMode(_ mode: String) -> LinearGradient {
        switch mode {
        case "Roast Me":
            return LinearGradient(colors: [Color.red, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Compliment Me":
            return LinearGradient(colors: [Color.pink, Color.cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Surprise Me":
            return LinearGradient(colors: [Color.purple, Color.yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [Color.gray], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}
