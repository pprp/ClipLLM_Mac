import SwiftUI
import AppKit
import Foundation
import Combine

struct ShortcutSetting: Identifiable {
    let id = UUID()
    var shortcut: String
    var function: String
    var isEditing: Bool = false
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


struct ContentView: View {
    @State private var clipboardContent: String = ""
    @State private var shortcutSettings: [ShortcutSetting] = [
        ShortcutSetting(shortcut: "⌘+⇧+S", function: "Summarize"),
        ShortcutSetting(shortcut: "⌘+⇧+T", function: "Translate"),
        ShortcutSetting(shortcut: "⌘+⇧+A", function: "Analyze"),
        ShortcutSetting(shortcut: "⌘+⇧+P", function: "Paraphrase"),
        ShortcutSetting(shortcut: "⌘+⇧+E", function: "Extract Key Points"),
        ShortcutSetting(shortcut: "⌘+⇧+R", function: "Proofread")
    ]
    @State private var editingShortcutIndex: Int? = nil
    @State private var shortcutListeningTimer: Timer?
    @State private var shortcutQueue: [(String, String)] = []
    @State private var isProcessingShortcut = false
    @State private var shortcutListener: ShortcutListener?
    @State private var isResponseVisible = false
    @State private var windowSize: CGSize = .zero

    // I will use the EnvironmentObject property wrapper to share data between this view and others
    @EnvironmentObject var appModel: DataInterface
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 10) {
                    // Prompt input and buttons
                    VStack(spacing: 10) {
                        TextField("Prompt", text: $appModel.prompt)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                        
                        HStack(spacing: 10) {
                            Spacer()
                            Button(action: appModel.sendPrompt) {
                                Text("Send")
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .keyboardShortcut(.return)
                            
                            Button(action: {
                                appModel.prompt = ""
                                appModel.response = ""
                            }) {
                                Text("Clear")
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .keyboardShortcut("c")
                            .tint(.gray)
                            Spacer()
                        }
                    }
                    .padding(.top)
                    
                    // Response area
                    VStack {
                        if isResponseVisible {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 10) {
                                    if appModel.isSending {
                                        ProgressView()
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding()
                                    } else if !appModel.response.isEmpty {
                                        Text(appModel.response)
                                            .font(.body)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                    }
                                }
                            }
                        } else {
                            Text("Response will appear here")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                    }
                    .frame(height: 150)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Shortcuts display
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Available Shortcuts")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(shortcutSettings.indices, id: \.self) { index in
                                HStack(spacing: 4) {
                                    Text(shortcutSettings[index].isEditing ? "Press Now" : shortcutSettings[index].shortcut)
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(shortcutSettings[index].isEditing ? Color.yellow.opacity(0.3) : Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                        .onTapGesture {
                                            editShortcut(index)
                                        }
                                    
                                    Text(shortcutSettings[index].function)
                                        .font(.system(size: 11))
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Clipboard content panel
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Clipboard Content")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ScrollView {
                            Text(clipboardContent)
                                .font(.system(size: 11))
                                .foregroundColor(.primary)
                        }
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(8)
                    }
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
                .frame(minHeight: geometry.size.height)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GeometryReader { geometry in
            Color.clear.preference(key: WindowSizeKey.self, value: geometry.size)
        })
        .onPreferenceChange(WindowSizeKey.self) { newSize in
            windowSize = newSize
        }
        .onAppear {
            setupShortcutListener()
            updateClipboardContent()
        }
        .onDisappear {
            shortcutListener?.stop()
        }
        .onReceive(timer) { _ in
            updateClipboardContent()
        }
    }

    private func updateClipboardContent() {
        if let text = Clipboard.getText() {
            clipboardContent = text
        } else {
            clipboardContent = "No text in clipboard"
        }
    }

    private func setupShortcutListener() {
        shortcutListener = ShortcutListener(shortcutSettings: $shortcutSettings) { function, clipboardContent in
            enqueueShortcut(function: function, clipboardContent: clipboardContent)
        }
        shortcutListener?.start()
    }

    private func enqueueShortcut(function: String, clipboardContent: String) {
        shortcutQueue.append((function, clipboardContent))
        processNextShortcutIfNeeded()
    }

    private func processNextShortcutIfNeeded() {
        guard !isProcessingShortcut, let (function, clipboardContent) = shortcutQueue.first else { return }
        
        isProcessingShortcut = true
        handleShortcut(for: function, clipboardContent: clipboardContent)
    }

    private func handleShortcut(for function: String, clipboardContent: String) {
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
            \(clipboardContent)
            
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
            \(clipboardContent)
            
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
            \(clipboardContent)
            
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
            \(clipboardContent)
            
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
            \(clipboardContent)
            
            Now, let's extract and present the key points in a structured format, followed by a brief summary of how these points relate to the overall message of the text.
            """
        case "Proofread":
            prompt = """
            Please proofread and correct the following text. Follow these steps:
            1. Read the entire text carefully.
            2. Check for spelling errors and typos.
            3. Identify and correct grammatical mistakes.
            4. Ensure proper punctuation and capitalization.
            5. Improve sentence structure and flow where necessary.
            6. Maintain the original meaning and tone.
            7. Provide a brief explanation of the changes made.

            Here's the text to proofread:
            \(clipboardContent)

            Please provide the corrected version of the text, followed by a list of the changes made and why they were necessary.
            """
        default:
            shortcutQueue.removeFirst()
            isProcessingShortcut = false
            processNextShortcutIfNeeded()
            return
        }
        
        appModel.prompt = prompt
        isResponseVisible = true
        appModel.sendPrompt()
        
        // Disable window resizing
        NSApp.keyWindow?.styleMask.remove(.resizable)
        
        // Wait for the response and update clipboard
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Adjust the delay as needed
            if !appModel.isSending {
                Clipboard.setText(appModel.response)
                
                // Reset prompt and response after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    appModel.prompt = ""
                    appModel.response = ""
                    isResponseVisible = false
                    shortcutQueue.removeFirst()
                    isProcessingShortcut = false
                    processNextShortcutIfNeeded()
                    
                    // Re-enable window resizing
                    NSApp.keyWindow?.styleMask.insert(.resizable)
                }
            } else {
                // If still sending, check again after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.handleShortcut(for: function, clipboardContent: clipboardContent)
                }
            }
        }
    }

    private func getTooltip(for function: String) -> String {
        switch function {
        case "Summarize":
            return "Condense the text into a brief summary"
        case "Translate":
            return "Convert the text to English"
        case "Analyze":
            return "Examine the text in depth"
        case "Paraphrase":
            return "Rewrite the text using different words"
        case "Extract Key Points":
            return "Identify and list the main ideas"
        case "Proofread":
            return "Check and correct any errors in the text"
        default:
            return ""
        }
    }

    private func editShortcut(_ index: Int) {
        editingShortcutIndex = index
        shortcutSettings[index].isEditing = true
        
        shortcutListener?.startListeningForNewShortcut { newShortcut in
            if !isShortcutConflicting(newShortcut, excludingIndex: index) {
                shortcutSettings[index].shortcut = newShortcut
            }
            finishEditingShortcut(index)
        }

        // Start the timer for 3 seconds
        shortcutListeningTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            finishEditingShortcut(index)
        }
    }

    private func finishEditingShortcut(_ index: Int) {
        shortcutListeningTimer?.invalidate()
        shortcutListeningTimer = nil
        
        if shortcutSettings[index].isEditing {
            shortcutSettings[index].isEditing = false
        }
        editingShortcutIndex = nil
        shortcutListener?.stopListeningForNewShortcut()
    }

    private func isShortcutConflicting(_ shortcut: String, excludingIndex: Int) -> Bool {
        return shortcutSettings.enumerated().contains { index, setting in
            index != excludingIndex && setting.shortcut == shortcut
        }
    }
}

class ShortcutListener {
    private var keyEventMonitor: Any?
    private var shortcutSettings: Binding<[ShortcutSetting]>
    private var onShortcutTriggered: (String, String) -> Void
    private var newShortcutHandler: ((String) -> Void)?

    init(shortcutSettings: Binding<[ShortcutSetting]>, onShortcutTriggered: @escaping (String, String) -> Void) {
        self.shortcutSettings = shortcutSettings
        self.onShortcutTriggered = onShortcutTriggered
    }

    func start() {
        keyEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }
    }

    func stop() {
        if let monitor = keyEventMonitor {
            NSEvent.removeMonitor(monitor)
            keyEventMonitor = nil
        }
    }

    func startListeningForNewShortcut(completion: @escaping (String) -> Void) {
        newShortcutHandler = completion
    }

    func stopListeningForNewShortcut() {
        newShortcutHandler = nil
    }

    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let shortcutString = shortcutToString(keyCode: event.keyCode, modifiers: modifiers)

        if let newShortcutHandler = newShortcutHandler {
            newShortcutHandler(shortcutString)
            return nil
        }

        if let setting = shortcutSettings.wrappedValue.first(where: { $0.shortcut == shortcutString }) {
            onShortcutTriggered(setting.function, Clipboard.getText() ?? "")
            return nil
        }

        return event
    }

    private func shortcutToString(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> String {
        var shortcut = ""
        if modifiers.contains(.command) { shortcut += "⌘+" }
        if modifiers.contains(.shift) { shortcut += "⇧+" }
        if modifiers.contains(.option) { shortcut += "⌥+" }
        if modifiers.contains(.control) { shortcut += "⌃+" }
        
        let key: String
        switch keyCode {
        case 0: key = "A"
        case 1: key = "S"
        case 2: key = "D"
        case 3: key = "F"
        case 4: key = "H"
        case 5: key = "G"
        case 6: key = "Z"
        case 7: key = "X"
        case 8: key = "C"
        case 9: key = "V"
        case 11: key = "B"
        case 12: key = "Q"
        case 13: key = "W"
        case 14: key = "E"
        case 15: key = "R"
        case 16: key = "Y"
        case 17: key = "T"
        case 31: key = "O"
        case 32: key = "U"
        case 34: key = "I"
        case 35: key = "P"
        case 37: key = "L"
        case 38: key = "J"
        case 40: key = "K"
        case 45: key = "N"
        case 46: key = "M"
        default: key = String(UnicodeScalar(keyCode + 0x61) ?? " ")
        }
        
        return shortcut + key
    }
}

struct WindowSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

#Preview {
    ContentView()
        .environmentObject(DataInterface())
}
