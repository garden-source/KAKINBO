//
//  Item.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
