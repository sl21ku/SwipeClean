// SlotMachineView.swift
// Mechanical wooden toy slot machine view.

import SwiftUI

struct SlotMachineView: View {
    @Bindable var state: AppState
    let theme: ThemeColors
    
    @State private var isSpinning = false
    @State private var leverPulled = false
    
    // Reel items display lists
    @State private var reel0Symbols: [String] = ["🐱"]
    @State private var reel1Symbols: [String] = ["☕"]
    @State private var reel2Symbols: [String] = ["🍀"]
    
    // Reel scroll destination offsets
    @State private var reel0Offset: CGFloat = 0
    @State private var reel1Offset: CGFloat = 0
    @State private var reel2Offset: CGFloat = 0
    
    // Win banner overlay state
    @State private var winSymbol: String? = nil
    @State private var winPrize: Int = 0
    @State private var showWinBanner = false
    
    let slotItems = ["🐱", "☕", "🍀", "🧸", "🍂"]
    let itemHeight: CGFloat = 84.0
    
    var body: some View {
        VStack(spacing: 20) {
            // 1. CASINO VIEW INTRO HEADER
            VStack(spacing: 4) {
                Text("木製スロットマシン 🧸")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(theme.textMain)
                Text("コインを賭けておもちゃを動かそう")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textMuted)
            }
            .padding(.top, 10)
            
            Spacer()
            
            // 2. SLOT MACHINE CABINET
            ZStack(alignment: .trailing) {
                // Mechanical side Lever
                ZStack(alignment: .top) {
                    // Slot channel
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#a27b5c"))
                        .frame(width: 14, height: 70)
                    
                    // Lever Arm
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color(hex: "#866043"))
                            .frame(width: 6, height: 45)
                        
                        Circle()
                            .fill(theme.accentDelete)
                            .frame(width: 22, height: 22)
                            .shadow(color: Color.black.opacity(0.15), radius: 4)
                    }
                    .frame(width: 22, height: 67, alignment: .top)
                    .rotationEffect(.degrees(leverPulled ? 60 : 0), anchor: .top)
                    .animation(.easeInOut(duration: 0.15), value: leverPulled)
                    .offset(y: 5)
                }
                .offset(x: 28, y: -20)
                
                // Main Cabinet Box
                VStack(spacing: 16) {
                    // Reels Port (White viewport)
                    HStack(spacing: 12) {
                        reelColumn(symbols: reel0Symbols, offset: reel0Offset)
                        reelColumn(symbols: reel1Symbols, offset: reel1Offset)
                        reelColumn(symbols: reel2Symbols, offset: reel2Offset)
                    }
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .frame(height: 110)
                    .background(Color(hex: "#efe6dd"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "#a27b5c"), lineWidth: 3)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 5, y: 3)
                    .overlay(
                        // Red dash Win Line
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(theme.accentDelete.opacity(0.4))
                            .overlay(
                                Rectangle()
                                    .stroke(theme.accentDelete, style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                            )
                    )
                    
                    // Spin Control Buttons
                    VStack(spacing: 8) {
                        Text("消費: 🪙 10")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#a27b5c"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Button(action: {
                            spin()
                        }) {
                            Text(isSpinning ? "スピン中..." : "レバーを引く！")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isSpinning || state.coins < 10 ? theme.boardBg : theme.accentGold)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(isSpinning || state.coins < 10 ? theme.boardBg : Color(hex: "#c89547"), lineWidth: 3)
                                )
                                .shadow(color: Color.black.opacity(isSpinning ? 0 : 0.08), radius: 4, y: 2)
                        }
                        .disabled(isSpinning || state.coins < 10)
                        .buttonStyle(.plain)
                    }
                }
                .padding(18)
                .background(Color(hex: "#d4a373")) // Wooden cabinet body
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: "#a27b5c"), lineWidth: 6)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 15, y: 6)
            }
            .frame(width: 290)
            
            Spacer()
            
            // 3. COZY PAYTABLE BANNER
            VStack(spacing: 6) {
                Text("配当リスト (木のおもちゃ)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(theme.textMuted)
                
                HStack {
                    paytableItem(symbols: "🐱🐱🐱", payout: "x10")
                    Spacer()
                    paytableItem(symbols: "☕☕☕", payout: "x5")
                    Spacer()
                    paytableItem(symbols: "🍀🍀🍀", payout: "x3")
                }
                .padding(.horizontal, 16)
            }
            .padding(12)
            .background(theme.accentGoldBg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(theme.accentGold, lineWidth: 2))
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .overlay(
            ZStack {
                if showWinBanner, let sym = winSymbol {
                    winBannerView(symbol: sym, prize: winPrize)
                }
            }
        )
    }
    
    // Reel column layout
    private func reelColumn(symbols: [String], offset: CGFloat) -> some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                ForEach(symbols, id: \.self) { sym in
                    Text(sym)
                        .font(.system(size: 38))
                        .frame(width: 70, height: itemHeight)
                }
            }
            .offset(y: offset)
        }
        .frame(width: 70, height: itemHeight)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#d4a373"), lineWidth: 2))
        .shadow(color: Color.black.opacity(0.04), radius: 3, y: 2)
    }
    
    private func paytableItem(symbols: String, payout: String) -> some View {
        HStack(spacing: 4) {
            Text(symbols)
                .font(.caption)
            Text(payout)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#c08726"))
        }
    }
    
    // Custom Win Banner SwiftUI presentation
    private func winBannerView(symbol: String, prize: Int) -> some View {
        VStack(spacing: 6) {
            Text("🎉 \(symbol)\(symbol)\(symbol) 🎉")
                .font(.system(size: 32))
            Text("揃ったのだ！")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(theme.textMain)
            Text("🪙 +\(prize) 枚ゲット")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "#c08726"))
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .background(theme.accentGoldBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(theme.accentGold, lineWidth: 3))
        .shadow(color: Color.black.opacity(0.12), radius: 15, y: 6)
        .transition(.scale.combined(with: .opacity))
    }
    
    // Core spin execution and payout evaluation
    private func spin() {
        guard state.spendCoins(10) else { return }
        isSpinning = true
        
        // 1. Animate mechanical lever pull
        leverPulled = true
        CozyAudioSynth.shared.playClickSound()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            leverPulled = false
        }
        
        // 2. Determine win combination (35% success odds)
        let isWin = Double.random(in: 0...1) < 0.35
        var finalSymbol = ""
        
        if isWin {
            let roll = Double.random(in: 0...1)
            if roll < 0.2 { finalSymbol = "🐱" }
            else if roll < 0.55 { finalSymbol = "☕" }
            else { finalSymbol = "🍀" }
        }
        
        var results: [String] = []
        for r in 0..<3 {
            if isWin {
                results.append(finalSymbol)
            } else {
                var sym = slotItems.randomElement() ?? "🐱"
                if r == 2 && sym == results[0] && sym == results[1] {
                    // Prevent accidental win matches
                    sym = slotItems.first(where: { $0 != sym }) ?? "☕"
                }
                results.append(sym)
            }
        }
        
        // 3. Spin setup: Generate long dynamic reels
        let spinTime = 2.5
        let totalReelItems = [18, 24, 30] // Sequencing offsets
        
        var r0: [String] = []
        var r1: [String] = []
        var r2: [String] = []
        
        for idx in 0..<totalReelItems[0] {
            r0.append(idx == totalReelItems[0]-1 ? results[0] : (slotItems.randomElement() ?? "🐱"))
        }
        for idx in 0..<totalReelItems[1] {
            r1.append(idx == totalReelItems[1]-1 ? results[1] : (slotItems.randomElement() ?? "☕"))
        }
        for idx in 0..<totalReelItems[2] {
            r2.append(idx == totalReelItems[2]-1 ? results[2] : (slotItems.randomElement() ?? "🍀"))
        }
        
        reel0Symbols = r0
        reel1Symbols = r1
        reel2Symbols = r2
        
        // Reset scrolling frames
        reel0Offset = 0
        reel1Offset = 0
        reel2Offset = 0
        
        // 4. Play gear tick rhythm in background
        let tickInterval = 0.09
        let totalTicks = Int((spinTime - 0.3) / tickInterval)
        for t in 0..<totalTicks {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(t) * tickInterval) {
                if isSpinning {
                    CozyAudioSynth.shared.playSlotSpin()
                    triggerLightHaptic()
                }
            }
        }
        
        // 5. Trigger spring scrolling transitions
        withAnimation(.timingCurve(0.1, 0.8, 0.15, 1.0, duration: spinTime - 0.8)) {
            reel0Offset = -CGFloat(totalReelItems[0] - 1) * itemHeight
        }
        withAnimation(.timingCurve(0.1, 0.8, 0.15, 1.0, duration: spinTime - 0.4)) {
            reel1Offset = -CGFloat(totalReelItems[1] - 1) * itemHeight
        }
        withAnimation(.timingCurve(0.1, 0.8, 0.15, 1.0, duration: spinTime)) {
            reel2Offset = -CGFloat(totalReelItems[2] - 1) * itemHeight
        }
        
        // 6. Handle payouts
        DispatchQueue.main.asyncAfter(deadline: .now() + spinTime + 0.3) {
            isSpinning = false
            
            if isWin {
                CozyAudioSynth.shared.playWinChime()
                triggerWinHaptic()
                
                var prize = 0
                if finalSymbol == "🐱" { prize = 100 }
                else if finalSymbol == "☕" { prize = 50 }
                else if finalSymbol == "🍀" { prize = 30 }
                
                state.earnCoins(prize)
                
                // Show Banner
                winSymbol = finalSymbol
                winPrize = prize
                withAnimation(.spring()) {
                    showWinBanner = true
                }
                
                // Dismiss banner after 2s
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showWinBanner = false
                    }
                }
            } else {
                CozyAudioSynth.shared.playLoseSound()
                triggerSadHaptic()
            }
        }
    }
    
    // Haptics Helpers
    private func triggerLightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func triggerWinHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func triggerSadHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
