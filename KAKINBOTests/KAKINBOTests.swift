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
}
