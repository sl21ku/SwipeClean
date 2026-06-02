// ThemeShopView.swift
// Shop layout for purchasing and applying cozy themes.

import SwiftUI

struct ThemeShopView: View {
    @Bindable var state: AppState
    let theme: ThemeColors
    
    // Grid configuration for shop shelves
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 4) {
                Text("アンティークショップ 🕰️")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(theme.textMain)
                Text("コインでおしゃれなテーマをアンロック")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textMuted)
            }
            .padding(.top, 10)
            
            // Grid List
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    shopItemCard(id: "classic", title: "クラシックコージー", desc: "標準の温かみのある紙と木のデザイン", cost: 0, colors: ["#f7f3eb", "#ecdccb"])
                    
                    shopItemCard(id: "cyber", title: "ミッドナイトネオン", desc: "深夜の近未来ゲーム部屋を模したネオンカラー", cost: 100, colors: ["#0f0913", "#271442"])
                    
                    shopItemCard(id: "forest", title: "深緑の森", desc: "針葉樹の深い緑と温かいランタンの灯火", cost: 200, colors: ["#1c261e", "#222e25"])
                    
                    shopItemCard(id: "pastel", title: "いちごミルク", desc: "甘くて可愛いパステルピンクの世界観", cost: 300, colors: ["#faf0f2", "#f5dfdf"])
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
            }
        }
    }
    
    private func shopItemCard(id: String, title: String, desc: String, cost: Int, colors: [String]) -> some View {
        let isUnlocked = state.unlockedThemes.contains(id)
        let isActive = state.activeTheme == id
        
        return VStack(spacing: 0) {
            // Visual Preview Frame
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: colors[0]), Color(hex: colors[1])]),
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                
                // Small photo card mockup floating inside preview
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: 45, height: 50)
                    .shadow(color: Color.black.opacity(0.06), radius: 3)
                    .overlay(
                        VStack(spacing: 2) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 37, height: 32)
                                .cornerRadius(2)
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 25, height: 4)
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 15, height: 3)
                        }
                    )
            }
            .frame(height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.boardBg, lineWidth: 2))
            .padding(.bottom, 10)
            
            // Description texts
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(theme.textMain)
                .lineLimit(1)
            
            Text(desc)
                .font(.system(size: 10))
                .foregroundColor(theme.textMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32)
                .padding(.top, 2)
                .padding(.bottom, 12)
            
            // Interaction button
            Button(action: {
                purchaseOrApply(id: id, cost: cost)
            }) {
                if isActive {
                    Text("適用中")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(theme.textMain)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(theme.accentGoldBg)
                        .cornerRadius(12)
                } else if isUnlocked {
                    Text("適用")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(theme.textMain)
                        .cornerRadius(12)
                } else {
                    Text("🪙 \(cost)枚")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(state.coins >= cost ? theme.textMain : theme.boardBg)
                        .cornerRadius(12)
                }
            }
            .disabled(isActive || (!isUnlocked && state.coins < cost))
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isActive ? theme.textMain : theme.boardBg, lineWidth: isActive ? 3 : 2)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 8, y: 3)
    }
    
    private func purchaseOrApply(id: String, cost: Int) {
        let isUnlocked = state.unlockedThemes.contains(id)
        
        if isUnlocked {
            CozyAudioSynth.shared.playClickSound()
            triggerLightHaptic()
            state.activeTheme = id
        } else {
            if state.coins >= cost {
                CozyAudioSynth.shared.playWinChime()
                triggerPurchaseHaptic()
                
                _ = state.spendCoins(cost)
                state.unlockTheme(id)
                state.activeTheme = id
            }
        }
    }
    
    private func triggerLightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func triggerPurchaseHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
