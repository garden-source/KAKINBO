// KAKINBO/KAKINBOApp.swift
import SwiftUI
import SwiftData

@main
struct KAKINBOApp: App {
    // モデルコンテナの設定
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Preset.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // アプリ全体で共有するViewModelを作成
    @StateObject private var viewModel = KAKINBOViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    // ViewModelにModelContextを設定
                    viewModel.setModelContext(ModelContext(sharedModelContainer))
                }
        }
    }
}
