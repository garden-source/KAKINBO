// KAKINBO/View/ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    // ViewModelをObservedObjectとして受け取る
    @ObservedObject var viewModel: KAKINBOViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // TOTAL 表示
                TotalView(total: viewModel.totalSum)
                
                // TODAY 表示 (undo/redoボタン付き)
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
                AmountGridView(
                    amounts: viewModel.presets,
                    onTap: { preset in
                        guard let amount = preset.amount else {
                            print("空白ボタンが押されました")
                            return
                        }
                        viewModel.addItem(amount: amount)
                    },
                    onLongPress: { preset in
                        viewModel.editingPreset = preset
                        viewModel.editedValue = preset.amount.map { String($0) } ?? ""
                    }
                )
                
                Spacer()
                
                // 下部ナビゲーション
                BottomNavigationView(
                    onCalendar: {},
                    onLevel3: {},
                    onMode2: {}
                )
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

#Preview {
    let previewViewModel = KAKINBOViewModel()
    return ContentView(viewModel: previewViewModel)
        .modelContainer(for: [Item.self, Preset.self], inMemory: true)
}
