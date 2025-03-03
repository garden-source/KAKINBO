// ContentView.swift (リファクタリング後)
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel: KAKINBOViewModel
    
    init() {
        // ViewModelの初期化はinitで行う（SwiftUI Viewのライフサイクルに合わせるため）
        _viewModel = StateObject(wrappedValue: KAKINBOViewModel(context: ModelContext(...)))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // TOTAL 表示
                TotalView(total: viewModel.totalSum)
                
                // TODAY 表示
                TodayView(
                    todaySum: viewModel.todaySum,
                    onPrevious: {
                        viewModel.undo()
                    },
                    onNext: {
                        viewModel.redo()
                    }
                )

                // AmountGridView
                AmountGridView(amounts: viewModel.presets, onTap: { preset in
                    guard let amount = preset.amount else {
                        print("空白ボタンが押されました")
                        return
                    }
                    viewModel.addItem(amount: amount)
                }, onLongPress: { preset in
                    viewModel.editingPreset = preset
                    viewModel.editedValue = preset.amount.map { String($0) } ?? ""
                })
                
                Spacer()
                
                // 下部ナビゲーション
                BottomNavigationView(onCalendar: {}, onLevel3: {}, onMode2: {})
            }
            .navigationTitle("KA KIN BO")
            .navigationBarTitleDisplayMode(.inline)
        }
        // 編集用のシート表示
        .sheet(isPresented: Binding<Bool>(
            get: { viewModel.editingPreset != nil },
            set: { newValue in
                if !newValue { viewModel.editingPreset = nil }
            }
        )) {
            EditPresetSheet(
                editedValue: $viewModel.editedValue,
                onCancel: {
                    viewModel.editingPreset = nil
                },
                onSave: {
                    if let preset = viewModel.editingPreset {
                        viewModel.updatePreset(preset: preset, newValue: viewModel.editedValue)
                        viewModel.editingPreset = nil
                    }
                }
            )
        }
    }
}
