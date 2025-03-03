// KAKINBO/ViewModel/KAKINBOViewModel.swift
import SwiftUI
import SwiftData

class KAKINBOViewModel: ObservableObject {
    private var context: ModelContext?
    
    // 公開プロパティ
    @Published var items: [Item] = []
    @Published var presets: [Preset] = []
    @Published var editingPreset: Preset? = nil
    @Published var editedValue: String = ""
    
    // 計算プロパティ
    var totalSum: Int {
        items.map { $0.amount }.reduce(0, +)
    }
    
    var todaySum: Int {
        items.filter { Calendar.current.isDateInToday($0.timestamp) }
            .map { $0.amount }.reduce(0, +)
    }
    
    init() {
        // 空のイニシャライザ - contextは後から設定
    }
    
    func setModelContext(_ context: ModelContext) {
        self.context = context
        // contextが設定されたらデータをロード
        loadItems()
        loadPresets()
    }
    
    // データロード関数
    func loadItems() {
        guard let context = self.context else { return }
        
        // SwiftDataから、削除されていないアイテムを取得
        let predicate = #Predicate<Item> { !$0.isDeleted }
        let descriptor = FetchDescriptor<Item>(predicate: predicate)
        
        do {
            self.items = try context.fetch(descriptor)
        } catch {
            print("Error loading items: \(error)")
        }
    }
    
    func loadPresets() {
        guard let context = self.context else { return }
        
        // SwiftDataから、プリセットを順番に取得
        let descriptor = FetchDescriptor<Preset>(sortBy: [SortDescriptor(\.index, order: .forward)])
        
        do {
            self.presets = try context.fetch(descriptor)
            if presets.isEmpty {
                setupDefaultPresets()
            }
        } catch {
            print("Error loading presets: \(error)")
        }
    }
    
    // アイテム追加関数
    func addItem(amount: Int) {
        guard let context = self.context else { return }
        
        // 新規追加時は復活させたアイテムをすべて完全に削除（redo履歴クリア）
        clearRedoHistory()
        
        let newItem = Item(timestamp: Date(), amount: amount)
        context.insert(newItem)
        
        // リストの更新
        loadItems()
    }
    
    // Undo操作
    func undo() {
        guard let context = self.context else { return }
        
        if let lastItem = Item.fetchLastTodayItem(context: context) {
            lastItem.isDeleted = true
            loadItems()
        }
    }
    
    // Redo操作
    func redo() {
        guard let context = self.context else { return }
        
        if let lastDeletedItem = Item.fetchLastDeletedItem(context: context) {
            lastDeletedItem.isDeleted = false
            loadItems()
        }
    }
    
    // 復活履歴をクリア
    func clearRedoHistory() {
        guard let context = self.context else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<Item> {
            $0.isDeleted &&
            $0.timestamp >= startOfDay &&
            $0.timestamp < endOfDay
        }
        
        let descriptor = FetchDescriptor<Item>(predicate: predicate)
        
        do {
            let deletedItems = try context.fetch(descriptor)
            for item in deletedItems {
                context.delete(item)
            }
        } catch {
            print("Error clearing redo history: \(error)")
        }
    }
    
    // プリセット初期化
    func setupDefaultPresets() {
        guard let context = self.context else { return }
        
        let defaultAmounts: [Int?] = [
            750, 1500, 3000, 7500, 15000, 150, 300,
            nil, nil
        ]
        
        for (idx, value) in defaultAmounts.enumerated() {
            let preset = Preset(index: idx, amount: value)
            context.insert(preset)
        }
        
        loadPresets() // プリセットリストの更新
    }
    
    // プリセット更新ロジック
    func updatePreset(preset: Preset, newValue: String) {
        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed == "0" {
            preset.amount = nil
        } else if let intValue = Int(trimmed), (2...6).contains(trimmed.count) {
            preset.amount = intValue
        }
        loadPresets() // プリセットリストの更新
    }
}
