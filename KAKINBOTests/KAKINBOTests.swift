import SwiftUI
import XCTest
@testable import KAKINBO

final class KAKINBOTests: XCTestCase {

    var itemsStore: ItemsStore!

    override func setUpWithError() throws {
        // 各テストケース実行前に ItemsStore のインスタンスを生成する
        itemsStore = ItemsStore()
    }

    override func tearDownWithError() throws {
        // 各テストケース終了後にインスタンスを破棄する
        itemsStore = nil
    }

    // addItem と totalSum の動作確認テスト
    func testAddItemAndTotalSum() throws {
        // 初期状態では合計金額は0であるはず
        XCTAssertEqual(itemsStore.totalSum, 0, "初期状態の合計は0でなければなりません。")
        
        // 金額1000を追加
        itemsStore.addItem(amount: 1000)
        
        // 合計が1000になっていることを確認
        XCTAssertEqual(itemsStore.totalSum, 1000, "合計金額は追加した金額と一致するはずです。")
        
        // さらに金額2000を追加
        itemsStore.addItem(amount: 2000)
        
        // 合計は3000になるはず
        XCTAssertEqual(itemsStore.totalSum, 3000, "複数の追加後、合計金額は各金額の合計である必要があります。")
    }
    
    // 今日の日付に基づいた todaySum の動作確認テスト
    func testTodaySum() throws {
        // 初期状態では今日の合計も0であるはず
        XCTAssertEqual(itemsStore.todaySum, 0, "初期状態の今日の合計は0でなければなりません。")
        
        // 今日の日付のアイテムを追加
        itemsStore.addItem(amount: 1500)
        
        // 今日の合計が1500になっていることを確認
        XCTAssertEqual(itemsStore.todaySum, 1500, "今日の合計は追加した今日の日付の金額と一致するはずです。")
        
        // ※過去日付のアイテムを追加しても todaySum に含まれないかのテストも可能です
        // ただし、ItemsStore の現状の実装では日付を操作できないため、モックや別の方法でテストする必要があります。
    }
    
    // undo/redo の動作確認テスト
    func testUndoRedo() throws {
        // 初期状態で今日の合計は0
        XCTAssertEqual(itemsStore.todaySum, 0, "初期状態の今日の合計は0である必要があります。")
        
        // 複数のアイテムを追加
        itemsStore.addItem(amount: 1000)
        itemsStore.addItem(amount: 2000)
        // 現在、今日の合計は 3000 のはず
        XCTAssertEqual(itemsStore.todaySum, 3000, "合計金額は3000であるはずです。")
        
        // undo を実行すると、最後に追加された2000が取り消される
        itemsStore.undo()
        XCTAssertEqual(itemsStore.todaySum, 1000, "undo後、今日の合計は1000である必要があります。")
        
        // redo を実行すると、undoで取り消した2000が再追加される
        itemsStore.redo()
        XCTAssertEqual(itemsStore.todaySum, 3000, "redo後、今日の合計は再び3000になるはずです。")
    }

    // アイテムがない状態で undo を実行した場合のテスト
    func testUndoWithoutItems() throws {
        // 初期状態では今日のアイテムは空
        XCTAssertEqual(itemsStore.todayItems.count, 0, "初期状態では今日のアイテムは存在しません。")
        itemsStore.undo()
        // undo 実行後も状態は変わらないはず
        XCTAssertEqual(itemsStore.todayItems.count, 0, "アイテムが無い状態でundoしても件数は変わらない必要があります。")
    }

    // 新規入力後に redo スタックがクリアされることのテスト
    func testRedoStackClearedAfterNewAdd() throws {
        // 複数のアイテムを追加
        itemsStore.addItem(amount: 1000)
        itemsStore.addItem(amount: 2000)
        XCTAssertEqual(itemsStore.todaySum, 3000, "合計は3000であるはずです。")
        
        // undo で最新の2000を取り消す → 合計は1000になる
        itemsStore.undo()
        XCTAssertEqual(itemsStore.todaySum, 1000, "undo後の合計は1000である必要があります。")
        
        // ここで新たに3000を追加すると、redoスタックはクリアされるはず
        itemsStore.addItem(amount: 3000)
        // 現在、今日の合計は1000 + 3000 = 4000
        XCTAssertEqual(itemsStore.todaySum, 4000, "新規追加後、合計は4000になるはずです。")
        
        // redo を実行しても何も起こらないはず
        itemsStore.redo()
        XCTAssertEqual(itemsStore.todaySum, 4000, "redoは無効となり、合計は変更されない必要があります。")
    }
    
    func testSheetBindingBehavior() {
        // editingPreset を模擬する変数（nilならシート非表示）
        var editingPreset: Preset? = nil
        
        // ContentView 内で使われるシートの Binding を定義
        let binding = Binding<Bool>(
            get: { editingPreset != nil },
            set: { newValue in
                if !newValue {
                    editingPreset = nil
                }
            }
        )
        
        // 初期状態: editingPreset は nil なので binding.get() は false
        XCTAssertFalse(binding.wrappedValue, "初期状態ではシートは非表示 (false) であるべき")
        
        // 編集対象が設定された場合
        editingPreset = Preset(index: 0, amount: 1500)
        // get クロージャは true を返すはず
        XCTAssertTrue(binding.wrappedValue, "editingPreset に値があればシートは表示状態 (true) になる")
        
        // シートを閉じる操作を模擬（set に false を代入）
        binding.wrappedValue = false
        // このとき、set クロージャ内で editingPreset が nil に更新されるはず
        XCTAssertNil(editingPreset, "シートが閉じられると editingPreset は nil になる")
    }
}
