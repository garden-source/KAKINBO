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
    
    // 設定メニューの表示状態
    @State private var showSettings: Bool = false
    
    // アラートの表示状態
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertLevel: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // タブとモードに応じて表示を切り替え
                if selectedTab == 0 {
                    // メイン画面 - モードに応じて表示を切り替え
                    if currentMode == 1 {
                        // MODE1の表示
                        mainModeOneView
                    } else {
                        // MODE2の表示（アラート機能付き）
                        mainModeTwoView
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
            .navigationBarItems(leading:
                Button(action: {
                    showSettings.toggle()
                }) {
                    Image(systemName: "line.horizontal.3")
                        .font(.title)
                }
            )
            .sheet(isPresented: $showSettings) {
                NavigationView {
                    AlertSettingsView(
                        alertLevel1: $viewModel.alertLevel1,
                        alertLevel2: $viewModel.alertLevel2,
                        alertLevel3: $viewModel.alertLevel3
                    )
                    .navigationBarItems(trailing: Button("Done") {
                        showSettings = false
                    })
                }
            }
            .onAppear {
                // 表示時に月間データをロード
                viewModel.loadCurrentMonthData()
                
                // モード2の場合、アラートチェック
                checkAlertIfNeeded()
            }
            .onChange(of: viewModel.monthlyTotal) { _, _ in
                // 月間合計が変わったらアラートチェック
                checkAlertIfNeeded()
            }
            .onChange(of: currentMode) { _, _ in
                // モードが変わったらアラートチェック
                checkAlertIfNeeded()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("月間予算アラート"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
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
    
    // MODE1のメインビュー
    private var mainModeOneView: some View {
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
    }
    
    // MODE2のメインビュー（MODE1と同じだが、アラート機能が有効）
    private var mainModeTwoView: some View {
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
                    
                    // 金額入力後にアラートチェック
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        checkAlertIfNeeded()
                    }
                },
                onLongPress: { preset in
                    viewModel.editingPreset = preset
                    viewModel.editedValue = preset.amount.map { String($0) } ?? ""
                }
            )
            
            Spacer()
        }
    }
    
    // アラートが必要か確認
    private func checkAlertIfNeeded() {
        // モード2の場合のみアラートを表示
        if currentMode == 2 {
            if let alertInfo = viewModel.getAlertInfo() {
                alertMessage = alertInfo.message
                alertLevel = alertInfo.level
                showAlert = true
            }
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
