//
//  HistoryViewController.swift
//  AIChatBuddy
//
//  Redesigned to fetch, display, and delete Firestore conversations
//  Created by ChatGPT on 06/15/2025
//

import UIKit
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Simple model to represent a fetched conversation
struct Conversation {
    let id: String
    let mode: String
    let messages: [Message]
    let createdAt: Date
}

class HistoryViewController: UIViewController {
    
    private var conversations: [Conversation] = []
    private let tableView = UITableView()
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "mainScreenArt"))
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chat History"
        view.backgroundColor = .systemBackground
        
        setupBackground()
//        setupTranslucentViews()
        setupTableView()
        fetchConversations()
    }
    
//    fileprivate func getImage(withColor color: UIColor, andSize size: CGSize) -> UIImage {
//        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        color.setFill()
//        UIRectFill(rect)
//        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        return image
//    }
//    
//    fileprivate func setupTranslucentViews() {
//        let toolBar = self.navigationController?.toolbar
//        let navigationBar = self.navigationController?.navigationBar
//        let slightwhite = getImage(withColor: UIColor.white.withAlphaComponent (0.9), andSize: CGSize(width: 30, height: 30))
//        toolBar?.setBackgroundImage(slightwhite, forToolbarPosition: .any, barMetrics: .default)
//        toolBar?.setShadowImage(UIImage(), forToolbarPosition: .any)
//        navigationBar?.setBackgroundImage(slightwhite, for: .default)
//    }
//    func getImage() -> UIImage {
//        let size = CGSize(width: 1, height: 1)
//        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
//        UIColor.clear.setFill()
//        UIRectFill(CGRect(origin: .zero, size: size))
//        let transparentImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
//        UIGraphicsEndImageContext()
//        return transparentImage
//    }
//    
//    func setupTranslucentViews() {
//        let toolbar = self.navigationController?.toolbar
//        let navigationBar = self.navigationController?.navigationBar
//        
//        toolbar?.setBackgroundImage(getImage(), forToolbarPosition: .any, barMetrics: .default)
//        navigationBar?.setBackgroundImage(getImage(), for: .default)
//    }
    
    private func setupBackground() {
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ConversationCell")
        view.addSubview(tableView)
    }
    
    private func fetchConversations() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user.")
            return
        }
        let db = Firestore.firestore()
        db.collection("conversations")
          .whereField("userId", isEqualTo: uid)
          .order(by: "createdAt", descending: true)
          .getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching conversations: \(error)")
                return
            }
            self.conversations = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                guard let mode = data["mode"] as? String,
                      let rawMessages = data["messages"] as? [[String: Any]],
                      let timestamp = data["createdAt"] as? Timestamp else {
                    return nil
                }
                let date = timestamp.dateValue()
                let messages = rawMessages.compactMap { dict -> Message? in
                    guard let id = dict["id"] as? String,
                          let text = dict["text"] as? String,
                          let isUser = dict["isUser"] as? Bool,
                          let ts = dict["timestamp"] as? Timestamp else { return nil }
                    return Message(id: id, text: text, isUser: isUser, timestamp: ts.dateValue())
                }
                return Conversation(id: doc.documentID, mode: mode, messages: messages, createdAt: date)
            } ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath)
        let conv = conversations[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = conv.mode
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        content.secondaryText = formatter.string(from: conv.createdAt)
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // Enable swipe-to-delete in the table view
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let conv = conversations[indexPath.row]
            Firestore.firestore().collection("conversations").document(conv.id).delete { [weak self] error in
                if let error = error {
                    print("Error deleting conversation: \(error)")
                } else {
                    self?.conversations.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conv = conversations[indexPath.row]
        
        // Pass mode, messages, and conversationId
        let chatVM = ChatViewModel(mode: conv.mode, conversationId: conv.id)
        chatVM.messages = conv.messages
        
        let chatView = ChatView(viewModel: chatVM)
        let hostingVC = UIHostingController(rootView: chatView)
        hostingVC.title = conv.mode
        
        navigationController?.pushViewController(hostingVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

