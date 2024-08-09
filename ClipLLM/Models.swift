import Foundation

// Struct to decode the JSON response
struct Response: Codable {
    let model: String
    let created_at: String
    let message: Message
    let done: Bool
}

struct Message: Codable {
    let role: String
    let content: String
}

// Class for managing application data and network communication
class DataInterface: ObservableObject, Observable {
    
    // Store the current prompt as a modifiable string
    @Published var prompt: String = ""
    // Store the response to the prompt as a modifiable string
    @Published var response: String = ""
    // Track whether a network request is currently being sent
    @Published var isSending: Bool = false

    // Function to handle sending the prompt to a server
    func sendPrompt() {
        print("Started Send Prompt")  // Log the start of sending a prompt
        // Prevent sending if the prompt is empty or a request is already in progress
        guard !prompt.isEmpty, !isSending else { return }
        isSending = true  // Mark that a sending process has started
        
        // Define the server endpoint
        let urlString = "http://127.0.0.1:11434/api/chat"
        // Safely unwrap the URL constructed from the urlString
        guard let url = URL(string: urlString) else { return }
        
        // Prepare the network request with the URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"  // Set the HTTP method to POST
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")  // Set the content type to JSON
        let body: [String: Any] = [
            "model": "gemma2:2b",  // Specify the model to be used
            "messages": [
                ["role": "user", "content": prompt]  // Pass the prompt as a message
            ]
        ]
        // Encode the request body as JSON
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Start the data task with the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { DispatchQueue.main.async { self.isSending = false } }  // Ensure isSending is reset after operation
            if let error = error {
                DispatchQueue.main.async { self.response = "Error: \(error.localizedDescription)" }  // Handle errors by updating the response
                return
            }
            
            // Ensure data was received
            guard let data = data else {
                DispatchQueue.main.async { self.response = "No data received" }  // Handle the absence of data
                return
            }
            
            let decoder = JSONDecoder()  // Initialize JSON decoder
            var fullResponse = ""
            
            do {
                let lines = String(data: data, encoding: .utf8)?.components(separatedBy: .newlines) ?? []
                for line in lines where !line.isEmpty {
                    if let lineData = line.data(using: .utf8) {
                        let decodedResponse = try decoder.decode(Response.self, from: lineData)
                        fullResponse += decodedResponse.message.content
                    }
                }
                DispatchQueue.main.async {
                    self.response = fullResponse  // Set the response to the full content
                    print(self.response)  // Print the full response
                }
            } catch {
                DispatchQueue.main.async {
                    self.response = "Error decoding response: \(error.localizedDescription)"
                }
            }
        }.resume()  // Resume the task if it was suspended
    }
}
