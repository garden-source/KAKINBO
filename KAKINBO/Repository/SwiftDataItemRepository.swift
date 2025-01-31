//
//  SwiftDataItemRepository.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//

import Foundation
import SwiftData

final class SwiftDataItemRepository: ItemRepositoryProtocol {
    //SwiftDataでデータを読み書きするための「コンテキスト」（ModelContext）を保持するためのプロパティ
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchAllItems() -> [Item] {
        do {
            let descriptor = FetchDescriptor<Item>()
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching items: \(error)")
            return []
        }
    }
    
    func addItem(amount: Int) {
        let newItem = Item(timestamp: Date(), amount: amount)
        context.insert(newItem)
        
        // SwiftData は自動保存が行われるが、必要に応じて明示的に保存も可能
        do {
            try context.save()
        } catch {
            print("Error saving item: \(error)")
        }
    }
}
