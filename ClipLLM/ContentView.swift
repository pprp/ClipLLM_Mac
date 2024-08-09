import SwiftUI
import AppKit
import Foundation


//struct ShortcutSetting: Identifiable {
//    let id = UUID()
//    var shortcut: String
//    var function: String
//}
//
//class Clipboard {
//    static func getText() -> String? {
//        NSPasteboard.general.string(forType: .string)
//    }
//    
//    static func setText(_ text: String) {
//        let pasteboard = NSPasteboard.general
//        pasteboard.clearContents()
//        pasteboard.setString(text, forType: .string)
//    }
//}



//struct ContentView: View {
//    @State private var shortcutSettings: [ShortcutSetting] = [
//        ShortcutSetting(shortcut: "⌘+⇧+S", function: "Summarize"),
//        ShortcutSetting(shortcut: "⌘+⇧+T", function: "Translate"),
//        ShortcutSetting(shortcut: "⌘+⇧+A", function: "Analyze")
//    ]
//    
//    let availableShortcuts = ["⌘+⇧+S", "⌘+⇧+T", "⌘+⇧+A", "⌘+⇧+C", "⌘+⇧+V"]
//    let availableFunctions = ["Summarize", "Translate", "Analyze", "Paraphrase", "Extract Key Points"]
//    let availableModels = ["DeepSeek", "Ollama", "GPT-4"]
//    
//    @State private var selectedModel = "GPT-4"
//    @State private var apiKey = ""
//    @State private var promptText = ""
//    @StateObject var chatController = ChatController() 
//    
//    @EnvironmentObject var appModel: DataInterface
//
//    private var backgroundColor: Color = Color(.sRGB, white: 0.95, opacity: 1.0)
//    private var buttonGradient = LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
//
//
//    
//    var body: some View {
//        ScrollView { // Added ScrollView to make the content scrollable
//            VStack(spacing: 10) {
//                HStack(spacing: 20) {
//                    VStack(spacing: 20) {
//                        ForEach($shortcutSettings) { $setting in
//                            HStack {
//                                Picker("Function", selection: $setting.function) {
//                                    ForEach(availableFunctions, id: \.self) { function in
//                                        Text(function).tag(function)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(width: 180)
//                                .onChange(of: setting.function) { newValue in
//                                    // Update the promptText when function changes
//                                    promptText = getPromptForFunction(newValue)
//                                }
//                                
//                                Picker("Shortcut", selection: $setting.shortcut) {
//                                    ForEach(availableShortcuts, id: \.self) { shortcut in
//                                        Text(shortcut).tag(shortcut)
//                                    }
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                                .frame(width: 140)
//                            }
//                            .padding()
//                            .background(Color.secondary.opacity(0.1))
//                            .cornerRadius(10)
//                        }
//                    }
//                    
//                    TextEditor(text: $promptText)
//                        .frame(height: 165)
//                        .padding()
//                        .background(Color.secondary.opacity(0.1))
//                        .cornerRadius(10)
//                }
//                
//                HStack(spacing: 20) {
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Model Settings")
//                            .font(.headline)
//                        
//                        Picker("Model", selection: $selectedModel) {
//                            ForEach(availableModels, id: \.self) { model in
//                                Text(model).tag(model)
//                            }
//                        }
//                        .pickerStyle(SegmentedPickerStyle())
//                        
//                        if selectedModel == "DeepSeek" || selectedModel == "GPT-4" {
//                            SecureField("API Key", text: $apiKey)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .padding(.top, 5)
//                        }
//                    }
//                    .padding()
//                    .background(Color.secondary.opacity(0.1))
//                    .cornerRadius(10)
//                    
//                    Button(action: servingSettings) {
//                        HStack {
//                            Image(systemName: "tray.and.arrow.down")
//                            Text("Serving")
//                        }
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//                        .frame(minWidth: 80, minHeight: 80)
//                        .padding()
//                        .background(buttonGradient)
//                        .cornerRadius(10)
//                        .shadow(radius: 5)
//                    }
//                }
//            }
//            .padding(.top, 20) // Adjust this value to increase or decrease the top space
//            .frame(minWidth: 400, minHeight: 200)
//            .background(backgroundColor)
//            
//            // Button to send the current prompt. It triggers the sendPrompt function when clicked.
//            Button("Send"){
//                appModel.sendPrompt()
//            }
//            .keyboardShortcut(.return) // Assign the return key as a shortcut to activate this button. Cause Mac.
//            
//            // Button to clear the current prompt and response.
//            Button("Clear"){
//                appModel.prompt = "" // Clear the prompt string.
//                appModel.response = "" // Clear the response string.
//            }
//            .keyboardShortcut("c") // Assign the 'c' key as a shortcut to activate this button. So Command + C
//
//
//
//        }
//    }
//    
//    func getPromptForFunction(_ function: String) -> String {
//        switch function {
//        case "Summarize":
//            return "Please summarize the following text."
//        case "Translate":
//            return "Please translate the following text."
//        case "Analyze":
//            return "Please analyze the following text."
//        case "Paraphrase":
//            return "Please paraphrase the following text."
//        case "Extract Key Points":
//            return "Please extract key points from the following text."
//        default:
//            return ""
//        }
//    }
//
//    func servingSettings() {
//        // Implement saving logic here
//        print("Settings saved:")
//        for setting in shortcutSettings {
//            print("\(setting.shortcut) - \(setting.function)")
//        }
//        print("Selected Model: \(selectedModel)")
//        if selectedModel == "DeepSeek" || selectedModel == "GPT-4" {
//            print("API Key: \(apiKey)")
//        }
//        
//        
//    }
//}

struct ContentView: View {
    
    // I will use the EnvironmentObject property wrapper to share data between this view and others
     @EnvironmentObject var appModel: DataInterface
    
    var body: some View {
        VStack {
            
            // TextField for the user input .
            TextField("Prompt", text: $appModel.prompt)
                .textFieldStyle(.roundedBorder)
                .onSubmit(appModel.sendPrompt) // Send the prompt to Ollama and get a response
            
            // Divider draws a line separating elements
            Divider()
            
            // Use an if statement to conditionally display a view depending on if appModel.isSending.
            if appModel.isSending{
                ProgressView() // Display a progress bar while waiting for a response.
                    .padding()
            }else{
                Text(appModel.response) // Display the response text from appModel if not currently sending.
            }
            
           
            HStack{
                
                // Button to send the current prompt. It triggers the sendPrompt function when clicked.
                Button("Send"){
                    appModel.sendPrompt()
                }
                .keyboardShortcut(.return) // Assign the return key as a shortcut to activate this button. Cause Mac.
                
                // Button to clear the current prompt and response.
                Button("Clear"){
                    appModel.prompt = "" // Clear the prompt string.
                    appModel.response = "" // Clear the response string.
                }
                .keyboardShortcut("c") // Assign the 'c' key as a shortcut to activate this button. So Command + C
                
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(DataInterface())
}
