// SwipeCleanApp.swift
// Main Entry point of the SwiftUI application.

import SwiftUI
import SwiftData

@main
struct SwipeCleanApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(for: AppState.self, configurations: config)
        } catch {
            fatalError("Could not configure SwiftData container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(container)
        }
    }
}
