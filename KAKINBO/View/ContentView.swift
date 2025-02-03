import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var itemsStore: ItemsStore
    
    // SwiftDataのmodelContextを使うためにEnvironmentを取得
    @Environment(\.modelContext) private var context
    
    // index順にソートして取得 (0番→1番→…)
    @Query(sort: \Preset.index, order: .forward)
    private var presets: [Preset]
    
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

                // もしPresetが空ならデフォルトを挿入しておく
                // onAppear あるいは .task などで1回だけ実行する
                mainContent
                
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
    }
    
    // メインコンテンツ部分 (AmountGridView など)
    private var mainContent: some View {
        // 9個のプリセットを表示（空白は amount=nil ）
        AmountGridView(amounts: presets) { preset in
            //ここからクロージャ本体
            guard let amount = preset.amount else {
                // amount=nil の空白ボタンを押した場合の仮実装
                // 今後、金額入力UIを実装する想定
                print("空白ボタンが押されました（今後実装予定）")
                return
            }
            // 金額がある場合はItemを追加
            itemsStore.addItem(amount: amount)
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
