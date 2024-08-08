import SwiftUI

struct ShortcutSetting: Identifiable {
    let id = UUID()
    var shortcut: String
    var function: String
}

struct ContentView: View {
    @State private var shortcutSettings: [ShortcutSetting] = [
        ShortcutSetting(shortcut: "⌘+⇧+S", function: "Summarize"),
        ShortcutSetting(shortcut: "⌘+⇧+T", function: "Translate"),
        ShortcutSetting(shortcut: "⌘+⇧+A", function: "Analyze")
    ]
    
    let availableShortcuts = ["⌘+⇧+S", "⌘+⇧+T", "⌘+⇧+A", "⌘+⇧+C", "⌘+⇧+V"]
    let availableFunctions = ["Summarize", "Translate", "Analyze", "Paraphrase", "Extract Key Points"]
    let availableModels = ["DeepSeek", "Ollama", "GPT-4"]
    
    @State private var selectedModel = "GPT-4"
    @State private var apiKey = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Image("AppLogo") // Replace with your actual logo image name
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text("ClipLLM Settings")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 20) {
                ForEach($shortcutSettings) { $setting in
                    HStack {
                        Picker("Shortcut", selection: $setting.shortcut) {
                            ForEach(availableShortcuts, id: \.self) { shortcut in
                                Text(shortcut).tag(shortcut)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                        
                        Picker("Function", selection: $setting.function) {
                            ForEach(availableFunctions, id: \.self) { function in
                                Text(function).tag(function)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 180)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Model Settings")
                    .font(.headline)
                
                Picker("Model", selection: $selectedModel) {
                    ForEach(availableModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if selectedModel == "DeepSeek" || selectedModel == "GPT-4" {
                    SecureField("API Key", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.top, 5)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
            
            Button(action: saveSettings) {
                Text("Save Settings")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(minWidth: 200)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    func saveSettings() {
        // Implement saving logic here
        print("Settings saved:")
        for setting in shortcutSettings {
            print("\(setting.shortcut) - \(setting.function)")
        }
        print("Selected Model: \(selectedModel)")
        if selectedModel == "DeepSeek" || selectedModel == "GPT-4" {
            print("API Key: \(apiKey)")
        }
    }
}

#Preview {
    ContentView()
}
