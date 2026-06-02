// SwipeCardView.swift
// Tactile card organizing view with gesture-driven physics.

import SwiftUI

struct SwipeCardView: View {
    @Bindable var state: AppState
    let theme: ThemeColors
    
    @State private var photos: [PhotoItem] = []
    @State private var currentIndex = 0
    @State private var cardOffsets: [String: CGSize] = [:] // Drag offset for each card ID
    @State private var showSummary = false
    
    // Quick statistics tracker for current session
    @State private var sessionMBDeleted = 0.0
    @State private var sessionCoinsEarned = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // 1. STORAGE PROGRESS METER
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("ストレージ空き容量")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(theme.textMain)
                    Spacer()
                    Text(String(format: "+%.1f MB 整理済", state.savedStorageMB))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(theme.accentKeep)
                }
                
                // Custom storage progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background (Cardboard)
                        Capsule()
                            .fill(theme.boardBg)
                            .frame(height: 8)
                        
                        // Storage Fill (Simulating filled space)
                        let baseFilledPercent = max(0.0, 78.0 - (state.savedStorageMB / 5.12))
                        Capsule()
                            .fill(theme.textMuted)
                            .frame(width: geometry.size.width * CGFloat(baseFilledPercent / 100.0), height: 8)
                        
                        // Newly Saved space indicator (Sage Green)
                        let savedPercent = (state.savedStorageMB / 5.12)
                        Capsule()
                            .fill(theme.accentKeep)
                            .frame(width: geometry.size.width * CGFloat(savedPercent / 100.0), height: 8)
                            .offset(x: geometry.size.width * CGFloat(baseFilledPercent / 100.0))
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 24)
            
            // 2. MAIN DECK / SUMMARY WORKSPACE
            ZStack {
                if showSummary {
                    summaryView
                } else if photos.isEmpty {
                    ProgressView()
                        .onAppear {
                            loadPhotos()
                        }
                } else {
                    // Render card stack (render top cards on top, meaning last in ZStack)
                    let maxIndex = min(photos.count, currentIndex + 3)
                    
                    ForEach((currentIndex..<maxIndex).reversed(), id: \.self) { idx in
                        let photo = photos[idx]
                        let isTopCard = idx == currentIndex
                        
                        photoCard(photo: photo, isTopCard: isTopCard)
                            .zIndex(Double(photos.count - idx))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "#f1ebd9"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(hex: "#e0d4c0"), lineWidth: 4)
                    )
                    .shadow(color: Color.black.opacity(0.02), radius: 10, y: 4)
            )
            .padding(.horizontal, 24)
            
            // 3. ACTION CONTROLLERS (Only visible when cards are present)
            if !showSummary && !photos.isEmpty {
                HStack(spacing: 24) {
                    // Trash (Left button)
                    Button(action: {
                        swipeManual(isKeep: false)
                    }) {
                        Image(systemName: "trash")
                            .font(.title2)
                            .foregroundColor(theme.accentDelete)
                            .frame(width: 60, height: 60)
                            .background(theme.accentDeleteBg)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(theme.accentDelete, lineWidth: 3))
                            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
                    }
                    
                    // Keep (Right button)
                    Button(action: {
                        swipeManual(isKeep: true)
                    }) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(theme.accentKeep)
                            .frame(width: 60, height: 60)
                            .background(theme.accentKeepBg)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(theme.accentKeep, lineWidth: 3))
                            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
                    }
                }
                .padding(.top, 8)
                
                Text("← 捨てる(フリック) | 残す(フリック) →")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textMuted)
                    .padding(.bottom, 8)
            }
        }
        .padding(.vertical, 10)
    }
    
    // Dynamic photo card builder
    private func photoCard(photo: PhotoItem, isTopCard: Bool) -> some View {
        let offset = cardOffsets[photo.id] ?? .zero
        let tilt = Double(offset.width * 0.05) // Degrees rotation
        
        let cardIdx = photos.firstIndex(of: photo) ?? 0
        let deckOffset = CGFloat(cardIdx - currentIndex)
        
        return VStack(spacing: 0) {
            // Image area
            ZStack(alignment: .topLeading) {
                if photo.imageUrlString == "local_asset" {
                    // Simulated local device asset
                    ZStack {
                        Color(hex: "#e8e3d9")
                        VStack(spacing: 8) {
                            Image(systemName: photo.isVideo ? "video.circle.fill" : "photo.fill")
                                .font(.system(size: 48))
                                .foregroundColor(theme.textMuted)
                            Text(photo.isVideo ? "大容量ビデオ" : "スクショ写真")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(theme.textMuted)
                        }
                    }
                } else {
                    // Online Unsplash asset
                    AsyncImage(url: URL(string: photo.imageUrlString)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            ZStack {
                                Color(hex: "#e8e3d9")
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(theme.textMuted)
                            }
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                // AI categorization tag
                HStack(spacing: 4) {
                    Text(photo.type.icon)
                    Text(photo.reason)
                        .font(.system(size: 11, weight: .bold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.9))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.04), radius: 4)
                .overlay(Capsule().stroke(theme.boardBg, lineWidth: 1.5))
                .padding(10)
                
                // Drag badges (Keep / Trash indicators overlay)
                if isTopCard {
                    ZStack {
                        if offset.width > 20 {
                            Text("KEEP")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(theme.accentKeep)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .border(theme.accentKeep, width: 4)
                                .rotationEffect(.degrees(15))
                                .opacity(Double(min(1.0, offset.width / 100.0)))
                                .padding(.leading, 120)
                                .padding(.top, 80)
                        }
                        
                        if offset.width < -20 {
                            Text("TRASH")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(theme.accentDelete)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .border(theme.accentDelete, width: 4)
                                .rotationEffect(.degrees(-15))
                                .opacity(Double(min(1.0, abs(offset.width) / 100.0)))
                                .padding(.trailing, 120)
                                .padding(.top, 80)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#efe8da"), lineWidth: 1))
            
            // Info Row
            HStack {
                Text(photo.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(theme.textMain)
                    .lineLimit(1)
                Spacer()
                Text(photo.date)
                    .font(.system(size: 11))
                    .foregroundColor(theme.textMuted)
            }
            .padding(.top, 12)
            
            // Footer Row
            HStack {
                Text(String(format: "%.1f MB", photo.sizeMB))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(theme.accentDelete)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(theme.accentDeleteBg)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Spacer()
                Text("🪙 +\(photo.coinsReward)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "#c08726"))
            }
            .padding(.top, 8)
        }
        .padding(14)
        .background(theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.06), radius: 10, y: 3)
        .frame(width: 280, height: 380)
        
        // Tilt/Offset physics
        .rotationEffect(.degrees(isTopCard ? tilt : Double((cardIdx % 2 == 0 ? 1.5 : -1.5) * deckOffset)))
        .offset(
            x: isTopCard ? offset.width : 0,
            y: isTopCard ? offset.height : (deckOffset * 8)
        )
        .scaleEffect(isTopCard ? 1.0 : CGFloat(1.0 - deckOffset * 0.03))
        
        // Drag Gesture (only on the top card)
        .gesture(
            isTopCard ?
            DragGesture()
                .onChanged { value in
                    cardOffsets[photo.id] = value.translation
                    // Programmatic friction noise tick as we drag
                    if abs(value.translation.width).truncatingRemainder(dividingBy: 40) < 5 {
                        CozyAudioSynth.shared.playPaperShuffle()
                    }
                }
                .onEnded { value in
                    let threshold: CGFloat = 120.0
                    if value.translation.width > threshold {
                        // Keep (Right)
                        swipeAction(photo: photo, isKeep: true)
                    } else if value.translation.width < -threshold {
                        // Trash (Left)
                        swipeAction(photo: photo, isKeep: false)
                    } else {
                        // Snap back
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            cardOffsets[photo.id] = .zero
                        }
                    }
                }
            : nil
        )
    }
    
    // Completed Screen
    private var summaryView: some View {
        VStack(spacing: 20) {
            Text("🎉")
                .font(.system(size: 56))
            
            Text("おかたづけ完了！")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(theme.textMain)
            
            Text("スッキリきれいに整いました")
                .font(.subheadline)
                .foregroundColor(theme.textMuted)
            
            HStack(spacing: 16) {
                // MB Saved Card
                VStack(spacing: 4) {
                    Text(String(format: "%.1f MB", sessionMBDeleted))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(theme.textMain)
                    Text("削減した容量")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(theme.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(theme.boardBg, lineWidth: 2))
                
                // Coins Earned Card
                VStack(spacing: 4) {
                    Text("+\(sessionCoinsEarned)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#c08726"))
                    Text("獲得したコイン")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(theme.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(theme.boardBg, lineWidth: 2))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Reload trigger
            Button(action: {
                CozyAudioSynth.shared.playClickSound()
                reloadRun()
            }) {
                Text("もう一度整理する 🔄")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(theme.textMain)
                    .frame(maxWidth: 180)
                    .padding()
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(theme.boardBg, lineWidth: 2))
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .transition(.scale.combined(with: .opacity))
    }
    
    // API scan loaders
    private func loadPhotos() {
        PhotoScanner.shared.scanPhotos { fetchedPhotos in
            DispatchQueue.main.async {
                self.photos = fetchedPhotos
                self.currentIndex = 0
                self.showSummary = false
                self.sessionMBDeleted = 0.0
                self.sessionCoinsEarned = 0
            }
        }
    }
    
    private func reloadRun() {
        showSummary = false
        photos = []
        loadPhotos()
    }
    
    // Core swipe action updates
    private func swipeAction(photo: PhotoItem, isKeep: Bool) {
        withAnimation(.easeOut(duration: 0.25)) {
            cardOffsets[photo.id] = CGSize(width: isKeep ? 500 : -500, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if isKeep {
                CozyAudioSynth.shared.playSnapSound()
                triggerImpactHaptic(style: .medium)
            } else {
                CozyAudioSynth.shared.playTrashSound()
                triggerPatternHaptic()
                
                // Update persistent data
                state.addSavedStorage(photo.sizeMB)
                state.earnCoins(photo.coinsReward)
                
                // Track session aggregates
                sessionMBDeleted += photo.sizeMB
                sessionCoinsEarned += photo.coinsReward
            }
            
            currentIndex += 1
            if currentIndex >= photos.count {
                withAnimation(.spring()) {
                    showSummary = true
                }
            }
        }
    }
    
    // Handle button manual triggers
    private func swipeManual(isKeep: Bool) {
        guard currentIndex < photos.count else { return }
        let photo = photos[currentIndex]
        
        // Show indicator overlay first
        withAnimation(.easeOut(duration: 0.1)) {
            cardOffsets[photo.id] = CGSize(width: isKeep ? 60 : -60, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            swipeAction(photo: photo, isKeep: isKeep)
        }
    }
    
    // Haptics helper
    private func triggerImpactHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    private func triggerPatternHaptic() {
        // Simulates crinkly paper feel
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let gen2 = UIImpactFeedbackGenerator(style: .light)
            gen2.impactOccurred()
        }
    }
}
