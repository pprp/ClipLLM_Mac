import Foundation

struct PromptModel: Encodable {
    var prompt: String
    var model: String
    var system: String
}

struct ChatModel: Encodable{
    var model: String
    var messages: [ChatMessage]
}

struct ChatMessage :Encodable, Equatable, Hashable, Decodable{
    var role: String
    var content: String
    var images: [String]?
}