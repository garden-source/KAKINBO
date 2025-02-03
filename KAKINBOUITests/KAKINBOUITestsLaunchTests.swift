//
//  KAKINBOUITestsLaunchTests.swift
//  KAKINBOUITests
//
//  Created by Apple on 2025/01/31.
//

import XCTest

final class KAKINBOUITestsLaunchTests: XCTestCase {

    // 複数のアプリ構成でテストを実行する場合に、各ターゲットで個別に実行する設定です
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        // 失敗時にすぐテストを中断する設定
        continueAfterFailure = false
    }

    // アプリ起動時の動作を検証するテスト
    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        // ここで、起動直後に必要な初期状態の検証が可能です
        // 例: ログイン画面の特定の要素が存在するか確認する
        // let loginButton = app.buttons["loginButtonIdentifier"]
        // XCTAssertTrue(loginButton.exists, "ログインボタンが見つかりません。")
        
        // 起動時のスクリーンショットを撮影し、テストレポートに添付します
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways  // テスト完了後もスクリーンショットを保存
        add(attachment)
    }
    
    // オプション: 起動パフォーマンスを測定するテスト
//    @MainActor
//    func testLaunchPerformance() throws {
//        if #available(iOS 13.0, *) {
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
