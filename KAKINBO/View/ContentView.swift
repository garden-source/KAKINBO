// KAKINBO/View/ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    // SwiftDataのmodelContextを使用
    @Environment(\.modelContext) private var context
    
    // 削除されていないアイテムをクエリで取得
    @Query(filter: #Predicate<Item> { !$0.isDeleted })
    private var items: [Item]
    
    // プリセット値はそのまま使用
    @Query(sort: \Preset.index, order: .forward)
    private var presets: [Preset]
    
    // 編集用の状態
    @State private var editingPreset: Preset? = nil
    @State private var editedValue: String = ""
    
    // 計算プロパティで合計値を取得
    var totalSum: Int {
        items.map { $0.amount }.reduce(0, +)
    }
    
    var todaySum: Int {
        items.filter { Calendar.current.isDateInToday($0.timestamp) }
            .map { $0.amount }.reduce(0, +)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // TOTAL 表示
                TotalView(total: totalSum)
                
                // TODAY 表示 (undo/redoボタン付き)
                TodayView(
                    todaySum: todaySum,
                    onPrevious: {
                        undo()
                    },
                    onNext: {
                        redo()
                    }
                )

                // AmountGridView
                AmountGridView(amounts: presets, onTap: { preset in
                    guard let amount = preset.amount else {
                        print("空白ボタンが押されました")
                        return
                    }
                    addItem(amount: amount)
                }, onLongPress: { preset in
                    editingPreset = preset
                    editedValue = preset.amount.map { String($0) } ?? ""
                })
                
                Spacer()
                
                // 下部ナビゲーション
                BottomNavigationView(onCalendar: {},
                                     onLevel3: {},
                                     onMode2: {})
            }
            .navigationTitle("KA KIN BO")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if presets.isEmpty {
                    setupDefaultPresets()
                }
            }
        }
        // 編集用のシート表示
        .sheet(isPresented: Binding<Bool>(
            get: { editingPreset != nil },
            set: { newValue in
                if !newValue { editingPreset = nil }
            }
        )) {
            EditPresetSheet(editedValue: $editedValue, onCancel: {
                editingPreset = nil
            }, onSave: {
                let trimmed = editedValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed == "0" {
                    editingPreset?.amount = nil
                } else if let intValue = Int(trimmed), (2...6).contains(trimmed.count) {
                    editingPreset?.amount = intValue
                }
                editingPreset = nil
            })
        }
    }
    
    // アイテム追加関数
    private func addItem(amount: Int) {
        // 新規追加時は復活させたアイテムをすべて完全に削除（redo履歴クリア）
        clearRedoHistory()
        
        let newItem = Item(timestamp: Date(), amount: amount)
        context.insert(newItem)
    }
    
    // Undo操作
    private func undo() {
        if let lastItem = Item.fetchLastTodayItem(context: context) {
            lastItem.isDeleted = true
        }
    }
    
    // Redo操作
    private func redo() {
        if let lastDeletedItem = Item.fetchLastDeletedItem(context: context) {
            lastDeletedItem.isDeleted = false
        }
    }
    
    // 復活履歴をクリア
    private func clearRedoHistory() {
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
    private func setupDefaultPresets() {
        let defaultAmounts: [Int?] = [
            750, 1500, 3000, 7500, 15000, 150, 300,
            nil, nil
        ]
        
        for (idx, value) in defaultAmounts.enumerated() {
            let preset = Preset(index: idx, amount: value)
            context.insert(preset)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, Preset.self], inMemory: true)
}
