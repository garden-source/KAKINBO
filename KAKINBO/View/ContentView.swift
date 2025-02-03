import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var itemsStore: ItemsStore
    private let amounts = [750, 1500, 3000, 7500, 15000, 150, 300]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // TOTAL 表示（全体の合計）
                TotalView(total: itemsStore.totalSum)
                
                // TODAY 表示コンポーネント（今日の合計を表示）
                TodayView(
                    todaySum: itemsStore.todaySum,
                    onPrevious: {
                        // 左矢印で undo
                        itemsStore.undo()
                    },
                    onNext: {
                        // 右矢印で redo
                        itemsStore.redo()
                    }
                )
                
                // 金額入力ボタン
                AmountGridView(amounts: amounts) { amount in
                    itemsStore.addItem(amount: amount)
                }
                
                Spacer()
                
                // 下部ナビゲーション（必要に応じて）
                BottomNavigationView(onCalendar: {},
                                     onLevel3: {},
                                     onMode2: {})
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
