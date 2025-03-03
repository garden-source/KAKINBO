//
//  MonthlyTotalView.swift
//  KAKINBO
//
//  Created by Apple on 2025/03/03.
//

import SwiftUI

struct MonthlyTotalView: View {
    // 月間合計金額
    let monthlyTotal: Int

    var body: some View {
        ZStack {
            Color.green
                .ignoresSafeArea(edges: .horizontal)
            VStack {
                // MONTHを左に配置
                HStack {
                    Text("MONTH")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                // 金額は中央に表示
                Text("¥ \(monthlyTotal)")
                    .font(.title)
                    .padding(.top, 4)
                
                // YENを右側に配置
                HStack {
                    Spacer()
                    Text("YEN")
                        .font(.subheadline)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .foregroundColor(.black)
        }
        .frame(height: 100)
    }
}

struct MonthlyTotalView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyTotalView(monthlyTotal: 156000)
    }
}
