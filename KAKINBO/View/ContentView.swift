//
//  ItemsStore.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//
//  ContentView の役割
//  全体レイアウトの管理
//  データの取得と状態管理


import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var itemsStore: ItemsStore
    
    // SwiftDataのmodelContextを使うためにEnvironmentを取得
    @Environment(\.modelContext) private var context
    
    // index順にソートして取得 (0番→1番→…)
    @Query(sort: \Preset.index, order: .forward)
    private var presets: [Preset]
    
    // 長押しで編集する対象の Preset と、入力用のテキストを保持
    @State private var editingPreset: Preset? = nil
    @State private var editedValue: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // TOTAL 表示
                TotalView(total: itemsStore.totalSum)
                
                // TODAY 表示 (undo/redoボタン付き)
                TodayView(
                    todaySum: itemsStore.todaySum,
                    onPrevious: {
                        itemsStore.undo()
                    },
                    onNext: {
                        itemsStore.redo()
                    }
                )

                // AmountGridView に通常タップと長押しの処理を渡す
                AmountGridView(amounts: presets, onTap: { preset in
                    guard let amount = preset.amount else {
                        print("空白ボタンが押されました")
                        return
                    }
                    itemsStore.addItem(amount: amount)
                }, onLongPress: { preset in
                    // 長押し時は編集対象を設定し、現在の値を入力用テキストに反映
                    editingPreset = preset
                    editedValue = preset.amount.map { String($0) } ?? ""
                })
                
                Spacer()
                
                // 下部ナビゲーション
                BottomNavigationView(onCalendar: {},
                                     onLevel3: {},
                                     onMode2: {})
            }
            .navigationTitle("KA KIN BO")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // View出現時などにチェックし、未作成の場合は挿入
                if presets.isEmpty {
                    setupDefaultPresets()
                }
            }
        }
        // 編集用のシート表示
        //isPresentedがtrueかfalseかを判定
        .sheet(isPresented: Binding<Bool>(
            //editingPreset が nil でない場合は true、nil であれば false を返します
            get: { editingPreset != nil },
            //.sheet の表示状態が変更されると、SwiftUI はその新しい状態（true または false）をこの set クロージャに渡します。
            set: { newValue in
                if !newValue { editingPreset = nil }
            }
        )) {
            EditPresetSheet(editedValue: $editedValue, onCancel: {
                editingPreset = nil
            }, onSave: {
                // 入力値のトリム
                let trimmed = editedValue.trimmingCharacters(in: .whitespacesAndNewlines)
                // もし"0"ならnilとする
                if trimmed == "0" {
                    editingPreset?.amount = nil
                } else if let intValue = Int(trimmed), (2...6).contains(trimmed.count) {
                    editingPreset?.amount = intValue
                }
                // 保存後はシートを閉じる
                editingPreset = nil
            })
        }
    }
    
    
    /// 初回起動(もしくは一度も作成されていない)時に、デフォルトデータを作る
    private func setupDefaultPresets() {
        let defaultAmounts: [Int?] = [
            750, 1500, 3000, 7500, 15000, 150, 300,
            nil,  // 8番目 ボタン（空白）
            nil   // 9番目 ボタン（空白）
        ]
        
        for (idx, value) in defaultAmounts.enumerated() {
            let preset = Preset(index: idx, amount: value)
            context.insert(preset)
        }
        // ここでcontextが自動的に保存される（トランザクション管理）。
        // 必要に応じて手動保存することも可能。
    }
}

#Preview {
    ContentView()
        .environmentObject(ItemsStore())
}
