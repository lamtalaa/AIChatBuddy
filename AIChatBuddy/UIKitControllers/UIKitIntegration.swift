//
//  UIKitIntegration.swift
//  AIChatBuddy
//
//  Created by Yassine Lamtalaa on 6/13/25.
//

import SwiftUI

struct ProfileViewRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ProfileViewController {
        return ProfileViewController()
    }
    func updateUIViewController(_ uiViewController: ProfileViewController, context: Context) { }
}

struct HistoryViewRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> HistoryViewController {
        return HistoryViewController()
    }
    func updateUIViewController(_ uiViewController: HistoryViewController, context: Context) { }
}
