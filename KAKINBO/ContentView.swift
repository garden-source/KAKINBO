//
//  ContentView.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // SwiftData の ModelContext 参照（アイテムの追加/削除に必要）
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData から Item 一覧を取得
    @Query private var items: [Item]
    
    // ボタンで使用する金額のリスト
    private let amounts = [750, 1500, 3000, 7500, 15000, 150, 300]

    var body: some View {
        // 金額の計算：リスト(items)から都度合計を求める
        let totalSum = items.map(\.amount).reduce(0, +)
        
        // 「今日の」アイテムだけをフィルタして合計
        let todaySum = items
            .filter { Calendar.current.isDateInToday($0.timestamp) }
            .map(\.amount)
            .reduce(0, +)
        
        NavigationView {
            VStack(spacing: 0) {
                // --- 1) TOTAL表示部分 ---
                ZStack {
                    Color.green
                        .ignoresSafeArea(edges: .horizontal)
                    
                    VStack {
                        Text("TOTAL")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Text("¥\(totalSum)")
                            .font(.largeTitle)
                            .bold()
                            .padding(.top, 4)
                        
                        Text("YEN")
                            .font(.subheadline)
                            .padding(.bottom, 8)
                    }
                    .foregroundColor(.black)
                }
                .frame(height: 120)

                // --- 2) TODAY表示部分 ---
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
                    // 左右の矢印ボタン（未実装部分）
                    HStack {
                        Button(action: {
                            // 左矢印ボタンの処理（例: 日付を前日に変更するなど）
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .padding()
                        }
                        Spacer()
                        Button(action: {
                            // 右矢印ボタンの処理（例: 日付を翌日に変更するなど）
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .padding()
                        }
                    }
                    .padding(.horizontal, 16),
                    alignment: .center
                )

                // --- 3) 金額入力ボタン群 ---
                let columns = Array(repeating: GridItem(.flexible()), count: 3)
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(amounts, id: \.self) { amount in
                        Button(action: {
                            // 新しい Item を作成→modelContext.insert で保存
                            let newItem = Item(timestamp: Date(), amount: amount)
                            modelContext.insert(newItem)
                            // SwiftData は自動保存が基本ですが、必要に応じて手動 save() も可
                            // try? modelContext.save()
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
                
                Spacer()

                // --- 4) 下部ナビゲーションボタン ---
                HStack {
                    Button("CALENDAR") {
                        // カレンダー画面へ遷移など
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Button("LEVEL3") {
                        // LEVEL3画面へ遷移など
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Button("To Mode2") {
                        // 他のモードへ切り替えなど
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .navigationTitle("KA KIN BO")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - プレビュー
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
