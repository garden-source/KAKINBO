//
//  ContentView.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//

import SwiftUI
import SwiftData

struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]
    // 合計金額や今日の金額をUI上に表示・更新したいので@Stateで管理
        @State private var total: Int = 137100
        @State private var today: Int = 0

        // ボタンで使用する金額のリスト
        private let amounts = [750, 1500, 3000, 7500, 15000, 150, 300]
        
        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    
                    // --- 1) TOTAL表示部分 ---
                    ZStack {
                        Color.green
                            .ignoresSafeArea(edges: .horizontal) // 横を画面端まで広げる
                        
                        VStack {
                            Text("TOTAL")
                                .font(.headline)
                                .padding(.top, 8)
                            
                            Text("¥\(total.formatted())")
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
                            
                            Text("¥\(today.formatted())")
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
                        // 左右の矢印ボタンを表示する場合の例
                        HStack {
                            Button(action: {
                                // 左矢印ボタンの処理
                                // 例: 日付を前日に変更するなど
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .padding()
                            }
                            Spacer()
                            Button(action: {
                                // 右矢印ボタンの処理
                                // 例: 日付を次の日に変更するなど
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
                                // ボタンタップ時の処理
                                today += amount
                                total += amount
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
                // ナビゲーションバーのタイトル設定
                .navigationTitle("KA KIN BO")
                .navigationBarTitleDisplayMode(.inline)
                // ※左上の「ハンバーガーメニュー」アイコンを表示したい場合は、
                // .toolbar { ... } でボタンを追加し、サイドメニューと連動させる方法があります。
            }
        }
    }

    // MARK: - プレビュー
    #Preview {
        ContentView()
            .modelContainer(for: Item.self, inMemory: true)
    }
