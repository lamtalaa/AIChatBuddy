//
//  ChatView.swift
//  AIChatBuddy
//
//  Created by Yassine Lamtalaa on 5/28/25.
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    var isGuest: Bool = false

    var body: some View {
        ZStack {
            Image(viewModel.mode)
                .resizable()
                .ignoresSafeArea()
//                .overlay(Color.black.opacity(0.2))

            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                    .onChange(of: viewModel.messages) {
                        scrollToBottom(with: proxy)
                    }
                    .onChange(of: isInputFocused) {
                        if isInputFocused {
                            scrollToBottom(with: proxy)
                        }
                    }
                    .onChange(of: viewModel.isLoading) {
                        if viewModel.isLoading {
                            scrollToBottom(with: proxy)
                        }
                    }
                }

                if viewModel.isLoading {
                    HStack {
                        TypingIndicatorView()
                            .padding(10)
                            .background(Color(.systemGray5).opacity(0.9))
                            .cornerRadius(16)
                            .frame(maxWidth: 200, alignment: .leading)

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                }

                HStack {
                    ZStack(alignment: .trailing) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.white))
                            .frame(height: 44)

                        HStack {
                            TextField("", text: $viewModel.inputText, prompt: Text("Type a message...").foregroundColor(.gray))
                                .background(Color.white)
                                .foregroundColor(.black)
                                .padding()
                                .focused($isInputFocused)

                            if !viewModel.inputText.isEmpty {
                                Button(action: {
                                    viewModel.sendMessage()
                                    isInputFocused = false
                                }) {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(.blue)
                                        .padding(.trailing, 10)
                                }
                                .transition(.opacity)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isInputFocused = false
            }
        }
//        .navigationTitle(viewModel.mode)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Custom styled title
            ToolbarItem(placement: .principal) {
                Text(viewModel.mode)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        gradientForMode(viewModel.mode)
                            .cornerRadius(20).opacity(0.6)
                    )
                    .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 2)
            }

            // Back button
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

            // Save Chat button (only for non-guests)
            if !isGuest {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.saveConversation()
                    }) {
                        Text("Save Chat")
                            .fontWeight(.bold)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: [Color.pink.opacity(0.85), Color.orange.opacity(0.85)],
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
        .onAppear {
            viewModel.loadUserProfile()
        }
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "Something went wrong."),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $viewModel.showSuccessAlert) {
            Alert(
                title: Text("Success"),
                message: Text("Conversation saved successfully."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func scrollToBottom(with proxy: ScrollViewProxy) {
        if let lastId = viewModel.messages.last?.id {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(lastId, anchor: .bottom)
                }
            }
        }
    }
    
    private func gradientForMode(_ mode: String) -> LinearGradient {
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
