// SwipeCleanUITests.swift
// UI Automation tests verifying screen flows and navigation in SwipeClean.

import XCTest

final class SwipeCleanUITests: XCTestCase {

    override func setUpWithError() throws {
        // Stop tests immediately if a failure occurs.
        continueAfterFailure = false
    }

    func testLaunchAndTabNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // 1. Verify existence of bottom tab buttons
        let organizerTab = app.buttons["整理する"]
        let casinoTab = app.buttons["おもちゃ"]
        let shopTab = app.buttons["ショップ"]

        XCTAssertTrue(organizerTab.exists, "Organizer tab button should exist")
        XCTAssertTrue(casinoTab.exists, "Casino tab button should exist")
        XCTAssertTrue(shopTab.exists, "Shop tab button should exist")

        // 2. Navigate to Casino View and check elements
        casinoTab.tap()
        let casinoHeader = app.staticTexts["木製スロットマシン 🧸"]
        XCTAssertTrue(casinoHeader.waitForExistence(timeout: 2.0), "Casino view should display header upon navigation")

        // 3. Navigate to Shop View and check elements
        shopTab.tap()
        let shopHeader = app.staticTexts["アンティークショップ 🕰️"]
        XCTAssertTrue(shopHeader.waitForExistence(timeout: 2.0), "Shop view should display header upon navigation")

        // 4. Return to Organizer View
        organizerTab.tap()
        let storageHeader = app.staticTexts["ストレージ空き容量"]
        XCTAssertTrue(storageHeader.waitForExistence(timeout: 2.0), "Organizer view should display storage header")
    }
}
