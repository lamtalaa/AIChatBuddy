//
//  MainView.swift
//  AIChatBuddy
//
//  Created by Yassine Lamtalaa on 6/15/25.
//

import SwiftUI

struct MainView: View {
    @State private var showLogin = false
    @State private var showSignUp = false
    @State private var continueAsGuest = false

    var body: some View {
        NavigationStack {
            ZStack {
                Image("mainScreenArt")
                    .resizable()
                    .ignoresSafeArea()
//                    .overlay(Color.black.opacity(0.2))

                VStack(spacing: 40) {
                    Spacer()

                    // Logo or Title
                    Image("myAppIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .shadow(radius: 10)

                    Text("AI ChatBuddy")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .shadow(radius: 5)

                    Text("Playful AI that roasts, compliments & surprises you.")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil) // allow full wrapping
                        .fixedSize(horizontal: false, vertical: true) // avoid truncation
                        .padding(.horizontal)

                    Spacer()

                    VStack(spacing: 16) {
                        
                        GoogleSignInButtonView()
                        
                        Button {
                            showLogin = true
                        } label: {
                            Text("Login")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(colors: [Color.pink, Color.orange],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(radius: 5)
                        }

                        Button {
                            showSignUp = true
                        } label: {
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(colors: [Color.blue, Color.purple],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(radius: 5)
                        }

                        Button {
                            continueAsGuest = true
                        } label: {
                            Text("Continue as Guest")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(radius: 3)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: $showLogin) {
                    LoginView()
                }
                .navigationDestination(isPresented: $showSignUp) {
                    SignUpView()
                }
                .navigationDestination(isPresented: $continueAsGuest) {
                    ModeSelectionView(isGuest: true)
                }
            }
        }
    }
}
