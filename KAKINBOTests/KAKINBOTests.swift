// KAKINBOTests/KAKINBOTests.swift
import SwiftUI
import XCTest
import SwiftData
@testable import KAKINBO

final class KAKINBOTests: XCTestCase {
    
    var viewModel: KAKINBOViewModel!
    var inMemoryContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUpWithError() throws {
        // テスト用のインメモリコンテナを作成
        let schema = Schema([Item.self, Preset.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        inMemoryContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(inMemoryContainer)

        // テスト用のViewModelを初期化
        viewModel = KAKINBOViewModel()
        viewModel.setModelContext(modelContext)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        modelContext = nil
        inMemoryContainer = nil
    }
    
    // addItem と totalSum の動作確認テスト
    func testAddItemAndTotalSum() throws {
        // 初期状態では合計金額は0であるはず
        XCTAssertEqual(viewModel.totalSum, 0, "初期状態の合計は0でなければなりません。")
        
        // 金額1000を追加
        viewModel.addItem(amount: 1000)
        
        // 合計が1000になっていることを確認
        XCTAssertEqual(viewModel.totalSum, 1000, "合計金額は追加した金額と一致するはずです。")
        
        // さらに金額2000を追加
        viewModel.addItem(amount: 2000)
        
        // 合計は3000になるはず
        XCTAssertEqual(viewModel.totalSum, 3000, "複数の追加後、合計金額は各金額の合計である必要があります。")
    }
    
    // 今日の日付に基づいた todaySum の動作確認テスト
    func testTodaySum() throws {
        // 初期状態では今日の合計も0であるはず
        XCTAssertEqual(viewModel.todaySum, 0, "初期状態の今日の合計は0でなければなりません。")
        
        // 今日の日付のアイテムを追加
        viewModel.addItem(amount: 1500)
        
        // 今日の合計が1500になっていることを確認
        XCTAssertEqual(viewModel.todaySum, 1500, "今日の合計は追加した今日の日付の金額と一致するはずです。")
    }
    
    // undo/redo の動作確認テスト
    func testUndoRedo() throws {
        // 初期状態で今日の合計は0
        XCTAssertEqual(viewModel.todaySum, 0, "初期状態の今日の合計は0である必要があります。")
        
        // 複数のアイテムを追加
        viewModel.addItem(amount: 1000)
        viewModel.addItem(amount: 2000)
        // 現在、今日の合計は 3000 のはず
        XCTAssertEqual(viewModel.todaySum, 3000, "合計金額は3000であるはずです。")
        
        // undo を実行すると、最後に追加された2000が取り消される
        viewModel.undo()
        XCTAssertEqual(viewModel.todaySum, 1000, "undo後、今日の合計は1000である必要があります。")
        
        // redo を実行すると、undoで取り消した2000が再追加される
        viewModel.redo()
        XCTAssertEqual(viewModel.todaySum, 3000, "redo後、今日の合計は再び3000になるはずです。")
    }
    
    // 新規入力後に redo スタックがクリアされることのテスト
    func testRedoStackClearedAfterNewAdd() throws {
        // 複数のアイテムを追加
        viewModel.addItem(amount: 1000)
        viewModel.addItem(amount: 2000)
        XCTAssertEqual(viewModel.todaySum, 3000, "合計は3000であるはずです。")
        
        // undo で最新の2000を取り消す → 合計は1000になる
        viewModel.undo()
        XCTAssertEqual(viewModel.todaySum, 1000, "undo後の合計は1000である必要があります。")
        
        // ここで新たに3000を追加すると、redoスタックはクリアされるはず
        viewModel.addItem(amount: 3000)
        // 現在、今日の合計は1000 + 3000 = 4000
        XCTAssertEqual(viewModel.todaySum, 4000, "新規追加後、合計は4000になるはずです。")
        
        // redo を実行しても何も起こらないはず（redoスタックがクリアされているため）
        viewModel.redo()
        XCTAssertEqual(viewModel.todaySum, 4000, "redoは無効となり、合計は変更されない必要があります。")
    }
    
    // プリセットのテスト
    func testPresetManagement() throws {
        // 初期プリセットが設定されていることを確認
        XCTAssertFalse(viewModel.presets.isEmpty, "初期プリセットが設定されているはずです。")
        
        // プリセットの更新テスト
        if let firstPreset = viewModel.presets.first {
            let originalValue = firstPreset.amount
            
            // プリセット値を更新
            viewModel.updatePreset(preset: firstPreset, newValue: "2500")
            
            // 更新されたことを確認
            XCTAssertEqual(firstPreset.amount, 2500, "プリセット値が正しく更新されるはずです。")
            XCTAssertNotEqual(firstPreset.amount, originalValue, "プリセット値が元の値から変更されているはずです。")
        } else {
            XCTFail("プリセットが存在しないため、テストを実行できません。")
        }
    }
    
    // シートバインディングのテスト
    func testEditingPresetBinding() {
        // 初期状態ではシートは表示されていない（editingPresetはnil）
        XCTAssertNil(viewModel.editingPreset, "初期状態では編集中のプリセットはnilのはずです。")
        
        // プリセットを設定
        let testPreset = Preset(index: 0, amount: 1000)
        viewModel.editingPreset = testPreset
        
        // プリセットが設定された
        XCTAssertNotNil(viewModel.editingPreset, "プリセットが設定されたらnilではないはずです。")
        
        // クリア
        viewModel.editingPreset = nil
        
        // nilに戻った
        XCTAssertNil(viewModel.editingPreset, "プリセットがクリアされたらnilに戻るはずです。")
    }
}
