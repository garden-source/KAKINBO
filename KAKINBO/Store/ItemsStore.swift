//
//  ItemsStore.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//

import Foundation
import SwiftUI

final class ItemsStore: ObservableObject {
    @Published var items: [Item] = []
    
    // undo/redo 用のスタック
    private var redoStack: [Item] = []
    
    /// 今日のアイテムだけを抽出
    var todayItems: [Item] {
        items.filter { Calendar.current.isDateInToday($0.timestamp) }
    }
    
    /// 全体の合計
    var totalSum: Int {
        items.map { $0.amount }.reduce(0, +)
    }
    
    /// 今日の合計
    var todaySum: Int {
        todayItems.map { $0.amount }.reduce(0, +)
    }
    
    /// 新しい Item を追加する
    func addItem(amount: Int) {
        // 新規追加の際は redo スタックはクリア（新たな操作が入った場合、redo 履歴は無効）
        redoStack.removeAll()
        let newItem = Item(timestamp: Date(), amount: amount)
        items.append(newItem)
    }
    
    /// undo：今日に追加した最新のアイテムを削除し、redo 用に保持する
    func undo() {
        // 今日の入力のうち、最後に追加したアイテムを探す
        guard let lastIndex = items.lastIndex(where: { Calendar.current.isDateInToday($0.timestamp) }) else {
            return
        }
        let removedItem = items.remove(at: lastIndex)
        redoStack.append(removedItem)
    }
    
    /// redo：undo で取り除いたアイテムを再度追加する
    func redo() {
        guard let item = redoStack.popLast() else { return }
        items.append(item)
    }
}
