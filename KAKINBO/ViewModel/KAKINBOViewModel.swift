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
    @Published var monthlyItems: [Item] = []
    
    // 計算プロパティ
    var totalSum: Int {
        items.map { $0.amount }.reduce(0, +)
    }
    
    var todaySum: Int {
        items.filter { Calendar.current.isDateInToday($0.timestamp) }
            .map { $0.amount }.reduce(0, +)
    }
    
    // 月間合計を計算プロパティとして実装
    var monthlyTotal: Int {
        return monthlyItems.map { $0.amount }.reduce(0, +)
    }
    
    init() {
        // アラート設定のデフォルト値を設定
        self._alertLevel1 = Published(initialValue: UserDefaults.standard.integer(forKey: "alertLevel1"))
        self._alertLevel2 = Published(initialValue: UserDefaults.standard.integer(forKey: "alertLevel2"))
        self._alertLevel3 = Published(initialValue: UserDefaults.standard.integer(forKey: "alertLevel3"))
        
        // デフォルト値が0の場合は初期値を設定
        if alertLevel1 == 0 {
            alertLevel1 = 15000
        }
        if alertLevel2 == 0 {
            alertLevel2 = 50000
        }
        if alertLevel3 == 0 {
            alertLevel3 = 100000
        }
    }
    
    func setModelContext(_ context: ModelContext) {
        self.context = context
        // contextが設定されたらデータをロード
        loadItems()
        loadPresets()
        loadCurrentMonthData()
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
    
    // 指定された月のアイテムをロードする
    func loadItemsForMonth(_ date: Date) {
        guard let context = self.context else { return }
        
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        let predicate = #Predicate<Item> {
            !$0.isDeleted &&
            $0.timestamp >= startOfMonth &&
            $0.timestamp < nextMonth
        }
        
        let descriptor = FetchDescriptor<Item>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp)]
        )
        
        do {
            self.monthlyItems = try context.fetch(descriptor)
            // 変更通知を発行
            objectWillChange.send()
        } catch {
            print("Error loading items for month: \(error)")
        }
    }
    
    // 現在の月のデータを読み込む
    func loadCurrentMonthData() {
        let currentDate = Date()
        loadItemsForMonth(currentDate)
    }
    
    // 指定された日の合計金額を取得
    func getDaySum(for date: Date) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let dayItems = monthlyItems.filter { item in
            item.timestamp >= startOfDay && item.timestamp < nextDay
        }
        
        return dayItems.map { $0.amount }.reduce(0, +)
    }
    
    // 指定された日の金額を更新または追加
    func updateOrAddItemForDate(date: Date, amount: Int) {
        guard let context = self.context else { return }
        
        // その日の開始と終了
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // その日の既存のアイテムを取得
        let existingItems = monthlyItems.filter { item in
            item.timestamp >= startOfDay && item.timestamp < nextDay
        }
        
        // 既存のアイテムを全て削除（論理削除）
        for item in existingItems {
            item.isDeleted = true
        }
        
        // 新しいアイテムを追加
        let newItem = Item(timestamp: date, amount: amount)
        context.insert(newItem)
        
        // 月間データを再読み込み
        loadItemsForMonth(date)
        
        // 全体のデータも更新
        loadItems()
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
        
        // 月間データも更新
        loadCurrentMonthData()
        
        // 変更を発行して画面を更新
        objectWillChange.send()
    }
    
    // Undo操作
    func undo() {
        guard let context = self.context else { return }
        
        if let lastItem = Item.fetchLastTodayItem(context: context) {
            lastItem.isDeleted = true
            loadItems()
            loadCurrentMonthData() // 月間データも更新
            objectWillChange.send()
        }
    }
    
    // Redo操作
    func redo() {
        guard let context = self.context else { return }
        
        if let lastDeletedItem = Item.fetchLastDeletedItem(context: context) {
            lastDeletedItem.isDeleted = false
            loadItems()
            loadCurrentMonthData() // 月間データも更新
            objectWillChange.send()
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
    
    // undo/redoが可能かどうかを確認する関数
    func canUndo() -> Bool {
        guard let context = self.context else { return false }
        return Item.fetchLastTodayItem(context: context) != nil
    }
    
    func canRedo() -> Bool {
        guard let context = self.context else { return false }
        return Item.fetchLastDeletedItem(context: context) != nil
    }
    
    // アラート関連のプロパティをUserDefaultsに保存/読み込み
    @Published var alertLevel1: Int {
        didSet {
            UserDefaults.standard.set(alertLevel1, forKey: "alertLevel1")
        }
    }
    
    @Published var alertLevel2: Int {
        didSet {
            UserDefaults.standard.set(alertLevel2, forKey: "alertLevel2")
        }
    }
    
    @Published var alertLevel3: Int {
        didSet {
            UserDefaults.standard.set(alertLevel3, forKey: "alertLevel3")
        }
    }
    
    // アラートメッセージとレベルを保持する構造体
    struct AlertInfo {
        let message: String
        let level: Int  // 1, 2, 3
    }
    
    // 月間合計に基づいたアラート情報を取得（モード2のとき使用）
    func getAlertInfo() -> AlertInfo? {
        // 月間合計が設定値を超えているか確認
        if monthlyTotal >= alertLevel3 {
            return AlertInfo(message: "⚠️ 月間支出が\(alertLevel3)円を超えています！", level: 3)
        } else if monthlyTotal >= alertLevel2 {
            return AlertInfo(message: "⚠️ 月間支出が\(alertLevel2)円を超えています", level: 2)
        } else if monthlyTotal >= alertLevel1 {
            return AlertInfo(message: "月間支出が\(alertLevel1)円を超えています", level: 1)
        }
        
        return nil  // アラート表示不要
    }
    
    // UserDefaultsからアラート設定値を読み込む
    func loadAlertSettings() {
        // デフォルト値を設定
        if UserDefaults.standard.object(forKey: "alertLevel1") == nil {
            UserDefaults.standard.set(15000, forKey: "alertLevel1")
            UserDefaults.standard.set(50000, forKey: "alertLevel2")
            UserDefaults.standard.set(100000, forKey: "alertLevel3")
        }
        
        // 保存値を読み込む
        self._alertLevel1 = Published(initialValue: UserDefaults.standard.integer(forKey: "alertLevel1"))
        self._alertLevel2 = Published(initialValue: UserDefaults.standard.integer(forKey: "alertLevel2"))
        self._alertLevel3 = Published(initialValue: UserDefaults.standard.integer(forKey: "alertLevel3"))
    }
}

