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

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 3)
        
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(amounts, id: \.index) { preset in
                // ここからクロージャの本体
                Button(action: {
                    onTap(preset)
                }) {
                    // amount が存在する場合は金額を表示、nilの場合は「長押しで\nボタン追加」と表示
                    if let amount = preset.amount {
                        Text("\(amount)")
                            .font(.title3)
                            .frame(maxWidth: .infinity, minHeight: 60)
                    } else {
                        Text("長押しで\nボタン追加")
                            .multilineTextAlignment(.center)
                            .font(.footnote) // 通常の金額表示より小さいフォント
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, minHeight: 60)
                    }
                }
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.black)
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
        
        AmountGridView(amounts: dummyPresets) { preset in
            print("Tapped index=\(preset.index), amount=\(String(describing: preset.amount))")
        }
    }
}
