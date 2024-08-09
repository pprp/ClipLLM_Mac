//
//  ClipLLMApp.swift
//  ClipLLM
//
//  Created by peyton on 8/8/2024.
//

//import SwiftUI
//
//@main
//struct ClipLLMApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

import SwiftUI

@main
struct ClipLLMApp: App {
    var body: some Scene {
        
        //Create instance of Data Interface for the app
        @StateObject var appModel = DataInterface()
        
        //Create a Menu Bar for our app and have it have the brain icon
        MenuBarExtra("My Mac LLAMA Bar", systemImage: "brain"){
            //When Clicked The Menu Bar Will Show the content View
            ContentView()
                .environment(appModel)

        }
        //This modifier lets us show a Window in the Menu Bar
        .menuBarExtraStyle(.window)
        
        
    }
}
