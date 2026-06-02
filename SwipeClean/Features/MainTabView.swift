// MainTabView.swift
// Tab navigation container applying dynamic cozy themes.

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var appStates: [AppState]
    
    @State private var selectedTab = 0
    
    // Fallback state if database query is empty during loading
    @State private var localState = AppState()
    
    var state: AppState {
        appStates.first ?? localState
    }
    
    var body: some View {
        let theme = ThemeColors.getTheme(state.activeTheme)
        
        ZStack {
            // Warm cozy background
            theme.bg
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. TOP HEADER BAR
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SwipeClean 🧸")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(theme.textMain)
                        Text("おかたづけトイカジノ")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.textMuted)
                    }
                    
                    Spacer()
                    
                    // Coins Pill
                    HStack(spacing: 6) {
                        Text("🪙")
                        Text("\(state.coins)")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#c08726"))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(theme.accentGoldBg)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(theme.accentGold, lineWidth: 2)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                // 2. MAIN SUBVIEW SWITCHER
                Group {
                    switch selectedTab {
                    case 0:
                        SwipeCardView(state: state, theme: theme)
                    case 1:
                        SlotMachineView(state: state, theme: theme)
                    case 2:
                        ThemeShopView(state: state, theme: theme)
                    default:
                        SwipeCardView(state: state, theme: theme)
                    }
                }
                .frame(maxHeight: .infinity)
                
                // 3. BOTTOM TAB NAVIGATION BAR
                HStack {
                    Spacer()
                    tabButton(index: 0, title: "整理する", icon: "square.grid.2x2")
                    Spacer()
                    tabButton(index: 1, title: "おもちゃ", icon: "circle.circle")
                    Spacer()
                    tabButton(index: 2, title: "ショップ", icon: "bag")
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.85).ignoresSafeArea())
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.black.opacity(0.06)),
                    alignment: .top
                )
            }
        }
        .onAppear {
            seedDatabaseIfNeeded()
        }
    }
    
    private func seedDatabaseIfNeeded() {
        if appStates.isEmpty {
            let defaultState = AppState(coins: 100, savedStorageMB: 0.0, unlockedThemes: ["classic"], activeTheme: "classic")
            modelContext.insert(defaultState)
            do {
                try modelContext.save()
            } catch {
                print("Failed to save default state: \(error)")
            }
        }
    }
    
    private func tabButton(index: Int, title: String, icon: String) -> some View {
        let theme = ThemeColors.getTheme(state.activeTheme)
        let isActive = selectedTab == index
        
        return Button(action: {
            if selectedTab != index {
                selectedTab = index
                CozyAudioSynth.shared.playClickSound()
                triggerLightHaptic()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: isActive ? .bold : .medium))
                    .foregroundColor(isActive ? theme.textMain : theme.textMuted)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isActive ? theme.textMain : theme.textMuted)
            }
            .frame(width: 80)
        }
        .buttonStyle(.plain)
    }
    
    private func triggerLightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
