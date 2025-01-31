//
//  ContentViewModel.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//

import Foundation
import SwiftUI  // Combine を含む

final class ContentViewModel: ObservableObject {
    /// 画面表示に必要な Item 一覧
    @Published var items: [Item] = []
    
    /// 合計金額
    var totalSum: Int {
        items.map(\.amount).reduce(0, +)
    }
    
    /// 今日の合計金額
    var todaySum: Int {
        items
            .filter { Calendar.current.isDateInToday($0.timestamp) }
            .map(\.amount)
            .reduce(0, +)
    }
    
    private let repository: ItemRepositoryProtocol
    
    init(repository: ItemRepositoryProtocol) {
        self.repository = repository
        loadItems()
    }
    
    /// Repository 経由でデータを再取得
    func loadItems() {
        items = repository.fetchAllItems()
    }
    
    /// 新しい課金Itemを追加
    func addItem(amount: Int) {
        repository.addItem(amount: amount)
        // 追加後に再フェッチ
        loadItems()
    }
    
    // 「日付を変更して再読み込み」「削除」などの処理が増える場合はここに実装
}
