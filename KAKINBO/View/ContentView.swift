import SwiftUI
import SwiftData

struct ContentView: View {
    // アプリ全体の状態を管理する ItemsStore を参照
    @EnvironmentObject var itemsStore: ItemsStore
    
    /// 入力ボタンで使用する金額一覧
    private let amounts = [750, 1500, 3000, 7500, 15000, 150, 300]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // --- 1) TOTAL 表示コンポーネント ---
                TotalView(total: itemsStore.totalSum)
                
                // --- 2) TODAY 表示コンポーネント ---
                TodayView(todaySum: itemsStore.todaySum, onPrevious: {
                    // 左矢印の処理（例：過去の日付へ切り替え）
                }, onNext: {
                    // 右矢印の処理（例：未来の日付へ切り替え）
                })
                
                // --- 3) 金額入力ボタン群 ---
                AmountGridView(amounts: amounts) { amount in
                    // ItemsStore 経由で Item を追加
                    itemsStore.addItem(amount: amount)
                }
                
                Spacer()
                
                // --- 4) 下部ナビゲーションコンポーネント ---
                BottomNavigationView(onCalendar: {
                    // カレンダー画面への遷移
                }, onLevel3: {
                    // LEVEL3 画面への遷移
                }, onMode2: {
                    // モード切替など
                })
            }
            .navigationTitle("KA KIN BO")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ItemsStore())
}
