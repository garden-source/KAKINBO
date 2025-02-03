//
//  AmountGridView.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//

import SwiftUI

struct AmountGridView: View {
    /// `Preset` の配列を受け取る
    let amounts: [Preset]
    
    /// ボタンが押されたときに呼ばれる
    ///   - 空白ボタンも押せるようにしたいので、Presetごと渡す
    var onTap: (Preset) -> Void
    
    /// 長押し時のアクション（全てのボタンで有効）
    var onLongPress: (Preset) -> Void

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 3)
        
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(amounts, id: \.index) { preset in
                // ここからクロージャの本体
                Button(action: {
                    onTap(preset)
                }) {
                    if let amount = preset.amount {
                        Text("\(amount)")
                            .font(.title3)
                            .frame(maxWidth: .infinity, minHeight: 60)
                    } else {
                        Text("長押しで\nボタン追加")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, minHeight: 60)
                    }
                }
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.black)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                        onLongPress(preset)
                    }
                )
            }
        }
        .padding()
    }
}

struct AmountGridView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyPresets: [Preset] = [
            .init(index: 0, amount: 750),
            .init(index: 1, amount: 1500),
            .init(index: 2, amount: nil) // 空白
        ]
        
        AmountGridView(amounts: dummyPresets, onTap: { preset in
            print("Tapped index=\(preset.index), amount=\(String(describing: preset.amount))")
        }, onLongPress: { preset in
            print("Long press on preset index \(preset.index)")
        })
    }
}
