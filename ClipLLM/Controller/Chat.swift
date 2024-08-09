import Foundation
import SwiftUI

@MainActor
class ChatController: ObservableObject{
    @Published var prompt: PromptModel = .init(prompt: "", model: "", system: "")
    @Published var sentPrompt: [String] = []
    @Published var receivedResponse: [String] = []
    @Published var errorModel: ErrorModel = .init(showError: false, errorTitle: "", errorMessage: "")
    @Published var body_content = ChatModel(model: "", messages: [])
    @Published var tags: tagsParent?

    let ollamaController = OllamaController()
    
    func getTags() {
        Task {
            do {
                self.errorModel.showError = false
                self.tags = try await ollamaController.getLocalModels()
                if(self.tags != nil){
                    if(self.tags!.models.count > 0){
                        self.prompt.model = self.tags!.models[0].name
                    }else{
                        self.prompt.model = ""
                        self.errorModel = noModelsError(error: nil)
                    }
                }else{
                    self.prompt.model = ""
                    self.errorModel = noModelsError(error: nil)
                }
            } catch let NetError.invalidURL(error) {
                self.errorModel = invalidURLError(error: error)
            } catch let NetError.invalidData(error) {
                self.errorModel = invalidTagsDataError(error: error)
            } catch let NetError.invalidResponse(error) {
                self.errorModel = invalidResponseError(error: error)
            } catch let NetError.unreachable(error) {
                self.errorModel = unreachableError(error: error)
            } catch {
                self.errorModel = genericError(error: error)
            }
        }
    }

    func send() {
        Task {
            do {
                self.errorModel.showError = false
                self.sentPrompt.append(self.prompt.prompt)
                self.receivedResponse.append("")
                
                print("Sending request")
                let endpoint = ollamaController.apiAddress + "/api/chat"
                
                guard let url = URL(string: endpoint) else {
                    throw NetError.invalidURL(error: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                self.body_content.model = self.prompt.model
                self.body_content.messages.append(ChatMessage(role: "system", content: self.prompt.system))
                self.body_content.messages.append(ChatMessage(role: "user", content: self.prompt.prompt))
                
                request.httpBody = try encoder.encode(self.body_content)
                
                let data: URLSession.AsyncBytes
                let response: URLResponse
                
                do {
                    let sessionConfig = URLSessionConfiguration.default
                    sessionConfig.timeoutIntervalForRequest = Double(ollamaController.timeoutRequest) ?? 60
                    sessionConfig.timeoutIntervalForResource = Double(ollamaController.timeoutResource) ?? 604800
                    (data, response) = try await URLSession(configuration: sessionConfig).bytes(for: request)
                } catch {
                    throw NetError.unreachable(error: error)
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetError.invalidResponse(error: nil)
                }
                
                for try await line in data.lines {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let data = line.data(using: .utf8)!
                    let decoded = try decoder.decode(ResponseModel.self, from: data)
                    
                    self.receivedResponse[self.receivedResponse.count - 1].append(decoded.message.content)
                }
                self.prompt.prompt = ""
            } catch let NetError.invalidURL(error) {
                errorModel = invalidURLError(error: error)
            } catch let NetError.invalidData(error) {
                errorModel = invalidDataError(error: error)
            } catch let NetError.invalidResponse(error) {
                errorModel = invalidResponseError(error: error)
            } catch let NetError.unreachable(error) {
                errorModel = unreachableError(error: error)
            } catch {
                self.errorModel = genericError(error: error)
            }
        }
    }
}
