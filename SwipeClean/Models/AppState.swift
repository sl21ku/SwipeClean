// AppState.swift
// Persistent state for SwipeClean coins, storage space, and unlocked themes.

import Foundation
import SwiftData

@Model
final class AppState {
    var coins: Int
    var savedStorageMB: Double
    var unlockedThemes: [String]
    var activeTheme: String
    
    init(coins: Int = 100, savedStorageMB: Double = 0.0, unlockedThemes: [String] = ["classic"], activeTheme: String = "classic") {
        self.coins = coins
        self.savedStorageMB = savedStorageMB
        self.unlockedThemes = unlockedThemes
        self.activeTheme = activeTheme
    }
    
    func earnCoins(_ amount: Int) {
        coins += amount
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        guard coins >= amount else { return false }
        coins -= amount
        return true
    }
    
    func addSavedStorage(_ mb: Double) {
        savedStorageMB += mb
    }
    
    func unlockTheme(_ theme: String) {
        if !unlockedThemes.contains(theme) {
            unlockedThemes.append(theme)
        }
    }
}
