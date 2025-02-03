//
//  AmountGridView.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//

import SwiftUI

struct AmountGridView: View {
    // 値を入れないのであれば自動でイニシャライザ
    let amounts: [Int]
    var onTap: (Int) -> Void

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 3)
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(amounts, id: \.self) { amount in
                Button(action: {
                    onTap(amount)
                }) {
                    Text("\(amount)")
                        .font(.title3)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
    }
}

struct AmountGridView_Previews: PreviewProvider {
    static var previews: some View {
        AmountGridView(amounts: [750, 1500, 3000, 7500, 15000, 150, 300]) { amount in
            print("Tapped \(amount)")
        }
    }
}
