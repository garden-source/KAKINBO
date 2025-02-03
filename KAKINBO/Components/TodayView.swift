//
//  TodayView.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//

import SwiftUI

struct TodayView: View {
    // 値を入れないのであれば自動でイニシャライザ
    let todaySum: Int
    var onPrevious: () -> Void = {}
    var onNext: () -> Void = {}

    var body: some View {
        ZStack {
            Color.green
                .ignoresSafeArea(edges: .horizontal)
            VStack {
                Text("TODAY")
                    .font(.headline)
                    .padding(.top, 8)
                Text("¥\(todaySum)")
                    .font(.title)
                    .padding(.top, 4)
                Text("YEN")
                    .font(.subheadline)
                    .padding(.bottom, 8)
            }
            .foregroundColor(.black)
        }
        .frame(height: 100)
        .overlay(
            HStack {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding()
                }
                Spacer()
                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .padding()
                }
            }
            .padding(.horizontal, 16)
        )
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView(todaySum: 7890)
    }
}
