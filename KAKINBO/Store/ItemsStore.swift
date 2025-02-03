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
    
    /// 全体の合計金額
    var totalSum: Int {
        items.map { $0.amount }.reduce(0, +)
    }
    
    /// 今日の合計金額
    var todaySum: Int {
        items.filter { Calendar.current.isDateInToday($0.timestamp) }
            .map { $0.amount }
            .reduce(0, +)
    }
    
    /// 新しい Item を追加する
    func addItem(amount: Int) {
        let newItem = Item(timestamp: Date(), amount: amount)
        items.append(newItem)
    }
    
    /// 必要に応じた読み込み処理
    func loadItems() {
        // 永続化などが必要な場合の読み込み処理を実装
    }
}
