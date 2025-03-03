// KAKINBO/View/ContentView.swift の更新版
import SwiftUI
import SwiftData

struct ContentView: View {
    // ViewModelをObservedObjectとして受け取る
    @ObservedObject var viewModel: KAKINBOViewModel
    
    // 現在選択されているタブ
    @State private var selectedTab: Int = 0
    
    // 現在のモード (1または2)
    @State private var currentMode: Int = 1
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // タブとモードに応じて表示を切り替え
                if selectedTab == 0 {
                    // メイン画面 - モードに応じて表示を切り替え
                    if currentMode == 1 {
                        // MODE1の表示
                        VStack(spacing: 0) {
                            // TOTAL 表示
                            TotalView(total: viewModel.totalSum)
                            
                            // MONTH 表示
                            MonthlyTotalView(monthlyTotal: viewModel.monthlyTotal)
                            
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
                        }
                    } else {
                        // MODE2の表示 (将来実装する別の画面)
                        VStack {
                            Text("MODE 2")
                                .font(.largeTitle)
                                .padding()
                            
                            Text("この機能は近日公開予定です")
                                .foregroundColor(.gray)
                            
                            Spacer()
                        }
                    }
                } else if selectedTab == 1 {
                    // カレンダー画面
                    CalendarView(viewModel: viewModel)
                        .padding(.top)
                }
                
                // 下部ナビゲーション（タブ切り替え用）
                BottomNavigationView(selectedTab: $selectedTab, currentMode: $currentMode)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // 表示時に月間データをロード
                viewModel.loadCurrentMonthData()
            }
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
    
    // タブとモードに応じたナビゲーションタイトルを返す
    private var navigationTitle: String {
        if selectedTab == 0 {
            return "KA KIN BO"
        } else {
            return "Calendar"
        }
    }
}

#Preview {
    let previewViewModel = KAKINBOViewModel()
    return ContentView(viewModel: previewViewModel)
        .modelContainer(for: [Item.self, Preset.self], inMemory: true)
}
