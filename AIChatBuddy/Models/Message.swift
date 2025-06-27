//
//  Message.swift
//  AIChatBuddy
//
//  Created by Yassine Lamtalaa on 5/28/25.
//

import Foundation

struct Message: Identifiable, Equatable, Codable {
    var id: String = UUID().uuidString
    var text: String
    let isUser: Bool
    var timestamp: Date = Date() // Add timestamp for ordering

    // Firestore-ready dictionary
    var asDictionary: [String: Any] {
        return [
            "id": id,
            "text": text,
            "isUser": isUser,
            "timestamp": timestamp
        ]
    }
}
