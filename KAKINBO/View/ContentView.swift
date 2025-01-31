import SwiftUI
import SwiftData

struct ContentView: View {
    /// SwiftUI で ModelContext を取り出す
    @Environment(\.modelContext) private var modelContext
    
    /// MVVM の ViewModel
    @StateObject private var viewModel: ContentViewModel
    
    /// 入力ボタンで使用する金額一覧
    private let amounts = [750, 1500, 3000, 7500, 15000, 150, 300]
    
    // MARK: - イニシャライザ
    init() {
        // SwiftData用の ModelContainer を作り、そこから ModelContext を生成
        let container = try! ModelContainer(for: Item.self)
        let tempContext = ModelContext(container)
        
        // ここでは「仮の」ではなく、そのまま使える context で Repository を作成
        let repository = SwiftDataItemRepository(context: tempContext)
        
        // @StateObject にセットする
        _viewModel = StateObject(wrappedValue: ContentViewModel(repository: repository))
    }
    
    var body: some View {
        // ViewModel が公開しているプロパティを取得
        let totalSum = viewModel.totalSum
        let todaySum = viewModel.todaySum
        
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
                    // 左右の矢印ボタン（日付操作など）
                    HStack {
                        Button(action: {
                            // 左矢印ボタンの処理
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .padding()
                        }
                        Spacer()
                        Button(action: {
                            // 右矢印ボタンの処理
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
                            // ViewModel経由で Item 追加
                            viewModel.addItem(amount: amount)
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
        .onAppear {
            // 必要に応じて実際の modelContext を再注入したい場合は、
            // ViewModel 内に repository を置き換えるメソッドを用意するなどの対応を行う。
            // 例:
            // viewModel.replaceRepository(SwiftDataItemRepository(context: modelContext))
        }
    }
}

// MARK: - プレビュー
#Preview {
    // プレビュー用に in-memory Container を利用
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
