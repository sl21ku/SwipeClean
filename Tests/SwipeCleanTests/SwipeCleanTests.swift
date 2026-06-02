// SwipeCleanTests.swift
// Unit tests for SwipeClean state logic and calculations.

import XCTest
@testable import SwipeClean

final class SwipeCleanTests: XCTestCase {
    
    func testInitialAppState() {
        let state = AppState()
        XCTAssertEqual(state.coins, 100)
        XCTAssertEqual(state.savedStorageMB, 0.0)
        XCTAssertEqual(state.unlockedThemes, ["classic"])
        XCTAssertEqual(state.activeTheme, "classic")
    }
    
    func testEarnCoins() {
        let state = AppState(coins: 100)
        state.earnCoins(50)
        XCTAssertEqual(state.coins, 150)
    }
    
    func testSpendCoinsSuccess() {
        let state = AppState(coins: 100)
        let success = state.spendCoins(30)
        XCTAssertTrue(success)
        XCTAssertEqual(state.coins, 70)
    }
    
    func testSpendCoinsFailure() {
        let state = AppState(coins: 50)
        let success = state.spendCoins(100)
        XCTAssertFalse(success)
        XCTAssertEqual(state.coins, 50) // Coins remain unchanged
    }
    
    func testAddSavedStorage() {
        let state = AppState(savedStorageMB: 10.0)
        state.addSavedStorage(24.5)
        XCTAssertEqual(state.savedStorageMB, 34.5)
    }
    
    func testUnlockTheme() {
        let state = AppState()
        state.unlockTheme("cyber")
        XCTAssertTrue(state.unlockedThemes.contains("cyber"))
        XCTAssertEqual(state.unlockedThemes.count, 2)
        
        // Unlocking duplicate theme shouldn't change array size
        state.unlockTheme("cyber")
        XCTAssertEqual(state.unlockedThemes.count, 2)
    }
}
