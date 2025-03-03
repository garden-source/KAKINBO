// KAKINBO/Model/Item.swift
import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var amount: Int
    
    // undo/redo管理のため追加
    var isDeleted: Bool = false
    
    init(timestamp: Date, amount: Int) {
        self.timestamp = timestamp
        self.amount = amount
    }
    
    // モデルクラスに便利なスタティックメソッドを追加
    static func fetchTodayItems(context: ModelContext) -> [Item] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<Item> {
            !$0.isDeleted &&
            $0.timestamp >= startOfDay &&
            $0.timestamp < endOfDay
        }
        
        let descriptor = FetchDescriptor<Item>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching today items: \(error)")
            return []
        }
    }
    
    static func fetchAllActiveItems(context: ModelContext) -> [Item] {
        let predicate = #Predicate<Item> { !$0.isDeleted }
        let descriptor = FetchDescriptor<Item>(predicate: predicate)
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching active items: \(error)")
            return []
        }
    }
    
    // 最後に追加されたアイテムを取得（undo用）
    static func fetchLastTodayItem(context: ModelContext) -> Item? {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<Item> {
            !$0.isDeleted &&
            $0.timestamp >= startOfDay &&
            $0.timestamp < endOfDay
        }
        
        var descriptor = FetchDescriptor<Item>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        
        do {
            let items = try context.fetch(descriptor)
            return items.first
        } catch {
            print("Error fetching last today item: \(error)")
            return nil
        }
    }
    
    // 最後に削除されたアイテムを取得（redo用）
    static func fetchLastDeletedItem(context: ModelContext) -> Item? {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<Item> {
            $0.isDeleted &&
            $0.timestamp >= startOfDay &&
            $0.timestamp < endOfDay
        }
        
        var descriptor = FetchDescriptor<Item>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        
        do {
            let items = try context.fetch(descriptor)
            return items.first
        } catch {
            print("Error fetching last deleted item: \(error)")
            return nil
        }
    }
}
