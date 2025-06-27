//
//  LoginView.swift
//  AIChatBuddy
//
//  Created by Yassine Lamtalaa on 6/13/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var isGuest = false
    @State private var showSignUp = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Image("mainScreenArt")
                    .resizable()
                    .ignoresSafeArea()
//                    .overlay(Color.black.opacity(0.2)) // subtle dark overlay for readability
                
                VStack(spacing: 30) {
                    Text("Welcome Back!")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 10)

                    VStack(spacing: 20) {
                        TextField("", text: $email, prompt: Text("Email").foregroundColor(.gray))
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                        SecureField("", text: $password, prompt: Text("Password").foregroundColor(.gray))
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 30)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.horizontal)
                    }

                    VStack(spacing: 15) {
                        // Login Button
                        Button {
                            loginUser()
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Login")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(colors: [Color.pink.opacity(0.85), Color.orange.opacity(0.85)],
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing)
                                    )
                                    .cornerRadius(14)
                                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                        
                    }
                    .padding(.horizontal, 30)

                    Spacer()
                }
                .padding(.top, 80)
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
            .navigationDestination(isPresented: $isLoggedIn) {
                ModeSelectionView(isGuest: false)
            }
            .navigationDestination(isPresented: $isGuest) {
                ModeSelectionView(isGuest: true)
            }
        }
    }
    
    private func loginUser() {
        errorMessage = ""
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true
            }
        }
    }
}
