//
//  ItemRepositoryProtocol.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//  こういうメソッドを備えなさい」という“約束”


import Foundation

protocol ItemRepositoryProtocol {
    /// すべてのItemを取得
    func fetchAllItems() -> [Item]
    
    /// 新規Itemを追加
    func addItem(amount: Int)
}
