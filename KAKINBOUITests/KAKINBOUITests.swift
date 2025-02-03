import XCTest

final class KAKINBOUITests: XCTestCase {

    override func setUpWithError() throws {
        // テスト前に毎回実行される初期設定
        continueAfterFailure = false  // 失敗時にテストを即座に終了させる
    }

    override func tearDownWithError() throws {
        // テスト後のクリーンアップ処理
    }

    @MainActor
    func testTotalViewDisplayed() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 画面に「TOTAL」というテキストが表示されているか確認
        let totalLabel = app.staticTexts["TOTAL"]
        XCTAssertTrue(totalLabel.exists, "TOTALビューが表示されていません。")
    }
}
