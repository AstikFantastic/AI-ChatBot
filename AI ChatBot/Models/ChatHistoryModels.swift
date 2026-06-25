import Foundation

struct ChatHistoryItem: Codable {
    let chatId: String
    let title: String?
    let personaId: Int?
    let updatedAt: String
    let lastMessagePreview: String?
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case title
        case personaId = "persona_id"
        case updatedAt = "updated_at"
        case lastMessagePreview = "last_message_preview"
    }
    
    var date: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: updatedAt)
    }
    
    var displayTitle: String {
        return title ?? lastMessagePreview ?? "New Chat"
    }
}
