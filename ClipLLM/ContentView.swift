import SwiftUI
import AppKit
import Foundation


struct ShortcutSetting: Identifiable {
    let id = UUID()
    var shortcut: String
    var function: String
}

class Clipboard {
    static func getText() -> String? {
        NSPasteboard.general.string(forType: .string)
    }
    
    static func setText(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

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
    @State private var shortcutSettings: [ShortcutSetting] = [
        ShortcutSetting(shortcut: "⌘+⇧+S", function: "Summarize"),
        ShortcutSetting(shortcut: "⌘+⇧+T", function: "Translate"),
        ShortcutSetting(shortcut: "⌘+⇧+A", function: "Analyze"),
        ShortcutSetting(shortcut: "⌘+⇧+P", function: "Paraphrase"),
        ShortcutSetting(shortcut: "⌘+⇧+E", function: "Extract Key Points")
    ]
    
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
        .onAppear {
            setupShortcuts()
        }
    }

    private func setupShortcuts() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            let shortcutString = shortcutToString(keyCode: event.keyCode, modifiers: modifiers)
            
            if let setting = shortcutSettings.first(where: { $0.shortcut == shortcutString }) {
                handleShortcut(for: setting.function)
                return nil
            }
            
            return event
        }
    }

    private func shortcutToString(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> String {
        var shortcut = ""
        if modifiers.contains(.command) { shortcut += "⌘+" }
        if modifiers.contains(.shift) { shortcut += "⇧+" }
        if modifiers.contains(.option) { shortcut += "⌥+" }
        if modifiers.contains(.control) { shortcut += "⌃+" }
        
        let key = String(UnicodeScalar(keyCode + 0x61) ?? " ")
        return shortcut + key.uppercased()
    }

    private func handleShortcut(for function: String) {
        guard let clipboardText = Clipboard.getText() else { return }
        
        let prompt: String
        switch function {
        case "Summarize":
            prompt = """
            Please summarize the following text. Follow these steps:
            1. Read the text carefully.
            2. Identify the main topic and key ideas.
            3. Condense the information, removing unnecessary details.
            4. Organize the summary in a logical flow.
            5. Ensure the summary is about 25% of the original length.
            
            Here's the text to summarize:
            \(clipboardText)
            
            Now, let's think step by step to create a concise and informative summary.
            """
        case "Translate":
            prompt = """
            Please translate the following text to English. Follow these steps:
            1. Read the entire text to understand the context.
            2. Translate sentence by sentence, preserving the original meaning.
            3. Adjust for idiomatic expressions and cultural nuances.
            4. Ensure the translation flows naturally in English.
            5. Review the translation for accuracy and clarity.
            
            Here's the text to translate:
            \(clipboardText)
            
            Please provide both the original text and the English translation, then explain any challenging parts of the translation process.
            """
        case "Analyze":
            prompt = """
            Please analyze the following text. Use this approach:
            1. Read the text thoroughly.
            2. Identify the main theme or argument.
            3. Break down the text into its component parts.
            4. Examine the author's tone, style, and use of language.
            5. Consider any underlying assumptions or biases.
            6. Evaluate the strength of the arguments or evidence presented.
            7. Discuss the implications or significance of the text.
            
            Here's the text to analyze:
            \(clipboardText)
            
            Now, let's analyze this text step by step, providing insights and critical commentary.
            """
        case "Paraphrase":
            prompt = """
            Please paraphrase the following text. Follow these guidelines:
            1. Read and understand the original text completely.
            2. Identify the key ideas and concepts.
            3. Rewrite each sentence using different words and sentence structures.
            4. Maintain the original meaning and tone.
            5. Ensure the paraphrased version is approximately the same length as the original.
            6. Double-check that no part of the original text is copied verbatim.
            
            Here's the text to paraphrase:
            \(clipboardText)
            
            Please provide the paraphrased version and then explain the changes made to demonstrate how the meaning was preserved while the wording was altered.
            """
        case "Extract Key Points":
            prompt = """
            Please extract key points from the following text. Use this method:
            1. Carefully read the entire text.
            2. Identify the main topic or theme.
            3. Look for topic sentences, important facts, and crucial details.
            4. Distinguish between main ideas and supporting information.
            5. Organize the key points in a logical order.
            6. Ensure each key point is concise and clear.
            7. Provide a brief explanation for why each point is important.
            
            Here's the text to extract key points from:
            \(clipboardText)
            
            Now, let's extract and present the key points in a structured format, followed by a brief summary of how these points relate to the overall message of the text.
            """
        default:
            return
        }
        
        appModel.prompt = prompt
        appModel.sendPrompt()
        
        // Wait for the response and update clipboard
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Adjust the delay as needed
            if !appModel.isSending {
                Clipboard.setText(appModel.response)
            }
        }
    }


}

#Preview {
    ContentView()
        .environmentObject(DataInterface())
}
