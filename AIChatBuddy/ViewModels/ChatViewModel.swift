import Foundation
import FirebaseFirestore
import FirebaseAuth
import OpenAIService

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var showSuccessAlert: Bool = false

    let mode: String
    private let service: OpenAIService
    private var profile: UserProfile?
    private var conversationId: String?

    init(mode: String, profile: UserProfile? = nil, service: OpenAIService = OpenAIService(), conversationId: String? = nil) {
        self.mode = mode
        self.profile = profile
        self.service = service
        self.conversationId = conversationId
    }

    func setProfile(_ profile: UserProfile) {
        self.profile = profile
    }

    func setConversationId(_ id: String) {
        self.conversationId = id
    }

    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let userMessage = Message(text: inputText, isUser: true)
        messages.append(userMessage)
        inputText = ""

        Task {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                isLoading = true

                let prompt = generatePrompt(for: mode, input: userMessage.text)
                let response = try await service.sendMessage(prompt: prompt)

                let randomDelay = UInt64(Int.random(in: 3...5)) * 1_000_000_000
                try await Task.sleep(nanoseconds: randomDelay)

                let aiMessage = Message(text: response, isUser: false)
                messages.append(aiMessage)
            } catch let error as OpenAIServiceError {
                handleError(error)
            } catch {
                errorMessage = "Unexpected error: \(error.localizedDescription)"
                showErrorAlert = true
            }

            isLoading = false
        }
    }
    
    func loadUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated."
            self.showErrorAlert = true
            return
        }

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                self.showErrorAlert = true
                return
            }

            guard let data = snapshot?.data() else {
                self.errorMessage = "User profile not found."
                self.showErrorAlert = true
                return
            }

            let profile = UserProfile(
                name: data["name"] as? String ?? "",
                age: data["age"] as? String ?? "",
                gender: data["gender"] as? String ?? "",
                occupation: data["occupation"] as? String ?? "",
                location: data["location"] as? String ?? "",
                bio: data["bio"] as? String ?? ""
            )
            self.profile = profile
        }
    }

    func saveConversation() {
        
        guard !messages.isEmpty else {
                errorMessage = "Conversation is empty."
                showErrorAlert = true
                return
            }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated."
            showErrorAlert = true
            return
        }

        let db = Firestore.firestore()
        let messagesArray = messages.map { $0.asDictionary }

        var data: [String: Any] = [
            "userId": uid,
            "mode": mode,
            "messages": messagesArray,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        if let conversationId = conversationId {
            db.collection("conversations").document(conversationId).updateData(data) { error in
                if let error = error {
                    self.errorMessage = "Failed to update: \(error.localizedDescription)"
                    self.showErrorAlert = true
                } else {
                    self.showSuccessAlert = true
                }
            }
        } else {
            let newRef = db.collection("conversations").document()
            data["createdAt"] = FieldValue.serverTimestamp()
            newRef.setData(data) { error in
                if let error = error {
                    self.errorMessage = "Failed to save: \(error.localizedDescription)"
                    self.showErrorAlert = true
                } else {
                    self.conversationId = newRef.documentID
                    self.showSuccessAlert = true
                }
            }
        }
    }

    private func handleError(_ error: OpenAIServiceError) {
        switch error {
        case .invalidURL:
            errorMessage = "Invalid API URL."
        case .networkError(let err):
            errorMessage = "Network error: \(err.localizedDescription)"
        case .noData:
            errorMessage = "No response received."
        case .decodingError(let err):
            errorMessage = "Decoding error: \(err.localizedDescription)"
        case .apiError(let code, let msg):
            errorMessage = "API error \(code): \(msg)"
        }
        showErrorAlert = true
    }

    private func generatePrompt(for mode: String, input: String) -> String {
        let context: String
        if let profile = profile {
            context = """
            USER PROFILE:
            Name: \(profile.name)
            Age: \(profile.age)
            Gender: \(profile.gender)
            Occupation: \(profile.occupation)
            Location: \(profile.location)
            Bio: \(profile.bio)
            """
        } else {
            context = "No profile info available."
        }

        switch mode {
        case "Roast Me":
            return """
            \(context)

            You are an absolutely savage roast master with zero filter. Think of the most brutal, insulting, and vicious roast you can possibly give—no politeness, no restraint. Use dark humor, curse words, personal jabs, and ruthless sarcasm based on the user's profile and the input they gave: "\(input)".

            Be clever, creative, and merciless — go for the jugular and make it hurt (while still being funny). Channel your inner roast demon.
            you may include curse words like "f*ck", "sh*t", "b*tch", "asshole", etc. Be as savage as possible.
            Only bring up the USER PROFILE when it's relevant, natural, or helps enhance the reply.
            Make sure the response is not too long, but absolutely cutting and memorable.
            """

        case "Compliment Me":
            return """
            \(context)

            You are a world-class compliment expert. Your job is to make this user feel like the most admired, special, and powerful human being on Earth.

            Create a heartfelt, over-the-top, poetic compliment that flatters them using their profile info and their input: "\(input)". Make them feel like a god among mortals, the center of the universe, someone everyone wishes they could be. Use metaphors, emotion, and pure admiration. Make it unforgettable.
            Only bring up the USER PROFILE when it's relevant, natural, or helps enhance the reply.
            Make sure to use simple language and the response is not too long, but absolutely cutting and memorable.
            """

        case "Surprise Me":
            return """
            \(context)

            You are a wild, unpredictable, and creative AI that generates something *surprisingly personal* based on the user's profile and their input: "\(input)".

            It could be a hilarious scenario involving them, an unexpected secret about their future, a fictional letter from their pet, a fake news headline about them, or a poem from an alternate universe. The only rule: it must be original, tailored to their profile, and **genuinely surprising**.
            Only bring up the USER PROFILE when it's relevant, natural, or helps enhance the reply.
            Make sure the response is not too long, but absolutely cutting and memorable.
            """

        default:
            return input
        }
    }
}
