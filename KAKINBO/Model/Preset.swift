//
//  Preset.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//

import Foundation
import SwiftData

/// 金額ボタン用のプリセット値を管理するエンティティ
@Model
final class Preset {
    /// ボタンの順番（0〜8 の想定）
    var index: Int
    
    /// 金額。空白ボタンの場合はnil
    var amount: Int?

    init(index: Int, amount: Int?) {
        self.index = index
        self.amount = amount
    }
}
