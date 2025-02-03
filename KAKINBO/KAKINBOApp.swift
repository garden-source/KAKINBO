//
//  KAKINBOApp.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//

import SwiftUI
import SwiftData

@main
struct KAKINBOApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // グローバルな状態管理（唯一のソース・オブ・トゥルース）
    @StateObject private var itemsStore = ItemsStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(itemsStore)
        }
        .modelContainer(sharedModelContainer)
    }
}
