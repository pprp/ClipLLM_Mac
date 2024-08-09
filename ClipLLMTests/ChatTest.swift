import XCTest
@testable import ClipLLM

@MainActor
class ChatControllerTests: XCTestCase {
    
    var chatController: ChatController!
    
    override func setUpWithError() throws {
        chatController = ChatController()
        Task {
            do {
                _ = try await chatController.ollamaController.getLocalModels()
            } catch {
                XCTFail("getLocalModels() threw an error: \(error)")
            }
        }
    }

    override func tearDownWithError() throws {
        chatController = nil
    }

    func testSendSuccess() async throws {
        // Mock the necessary data
        chatController.prompt = PromptModel(prompt: "Hello", model: "testModel", system: "testSystem")
        
        // Set the OllamaController properties for testing
        chatController.ollamaController.apiAddress = "http://127.0.0.1"
        chatController.ollamaController.timeoutRequest = "60"
        chatController.ollamaController.timeoutResource = "604800"
        
        // Call the send function
        await chatController.send()
        
        // Check if the sentPrompt and receivedResponse are updated correctly
        print(chatController.body_content)
        
        let lastResponse = chatController.receivedResponse.last
        
        print(lastResponse)
    }
        
    // Add more tests for other error cases and edge cases
}
