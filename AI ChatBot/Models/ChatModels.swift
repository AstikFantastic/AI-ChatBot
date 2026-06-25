import Foundation

struct ChatMessage: Codable {
    let message: String
    let personaId: String?
    let additionalPrompt: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case personaId = "persona_id"
        case additionalPrompt = "additional_prompt"
    }
}

struct ChatResponse: Codable {
    let chatId: String
    let assistantMessage: String
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case assistantMessage = "assistant_message"
    }
}

struct MessageBubble {
    let text: String
    let isUser: Bool
    let timestamp: Date
}

// MARK: - Chat History Message

struct ChatHistoryMessage: Codable {
    let role: String
    let content: String
    let messageSource: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
        case messageSource = "message_source"
        case createdAt = "created_at"
    }
    
    var isUser: Bool {
        return role == "user"
    }
    
    var date: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: createdAt)
    }
}

