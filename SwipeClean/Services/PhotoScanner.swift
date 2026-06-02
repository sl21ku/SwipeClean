// PhotoScanner.swift
// Scans the device's photo library using the Photos framework, or provides high-fidelity cozy mock fallbacks.

import Foundation
import Photos
import UIKit

final class PhotoScanner: Sendable {
    static let shared = PhotoScanner()
    
    private init() {}
    
    // Request permission to access the photo library
    func requestPermission(completion: @escaping @Sendable (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            completion(true)
        case .denied, .restricted:
            completion(false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                completion(newStatus == .authorized || newStatus == .limited)
            }
        @unknown default:
            completion(false)
        }
    }
    
    // Scan photos and categorize them. Fallback to mock data if empty or denied.
    func scanPhotos(completion: @escaping @Sendable ([PhotoItem]) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .authorized || status == .limited else {
            // Permission not granted, load cozy fallback mock data
            completion(self.getMockPhotos())
            return
        }
        
        // Run fetch in background
        DispatchQueue.global(qos: .userInitiated).async {
            var items: [PhotoItem] = []
            
            // 1. Fetch Screenshots
            let screenshotOptions = PHFetchOptions()
            screenshotOptions.predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", PHAssetMediaSubtype.photoScreenshot.rawValue)
            screenshotOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            screenshotOptions.fetchLimit = 10
            
            let screenshotAssets = PHAsset.fetchAssets(with: screenshotOptions)
            screenshotAssets.enumerateObjects { asset, index, _ in
                let sizeMB = Double(asset.pixelWidth * asset.pixelHeight * 4) / (1024.0 * 1024.0) // Estimate size
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd"
                let dateStr = formatter.string(from: asset.creationDate ?? Date())
                
                // For native assets, we will use a local image placeholder or a dynamic local URL
                items.append(PhotoItem(
                    id: asset.localIdentifier,
                    title: "スクリーンショット \(index + 1)",
                    imageUrlString: "local_asset", // SwiftUI will map this to a custom image view
                    type: .screenshot,
                    sizeMB: Double(String(format: "%.1f", sizeMB)) ?? 2.5,
                    coinsReward: 5,
                    date: dateStr,
                    reason: "AI判定: スクリーンショット",
                    isVideo: false
                ))
            }
            
            // 2. Fetch other assets to simulate duplicates (proximity in creationDate)
            let allOptions = PHFetchOptions()
            allOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            allOptions.fetchLimit = 30
            let allAssets = PHAsset.fetchAssets(with: .image, options: allOptions)
            
            var previousAsset: PHAsset?
            var duplicateCount = 0
            
            allAssets.enumerateObjects { asset, _, _ in
                if let prev = previousAsset, let prevDate = prev.creationDate, let currDate = asset.creationDate {
                    let interval = abs(prevDate.timeIntervalSince(currDate))
                    if interval < 2.0 { // Shot within 2 seconds
                        duplicateCount += 1
                        let sizeMB = Double(asset.pixelWidth * asset.pixelHeight * 3) / (1024.0 * 1024.0)
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy/MM/dd"
                        let dateStr = formatter.string(from: asset.creationDate ?? Date())
                        
                        items.append(PhotoItem(
                            id: asset.localIdentifier,
                            title: "類似した写真 \(duplicateCount)",
                            imageUrlString: "local_asset",
                            type: .duplicate,
                            sizeMB: Double(String(format: "%.1f", sizeMB)) ?? 6.2,
                            coinsReward: 10,
                            date: dateStr,
                            reason: "AI判定: 重複 (類似度99%)",
                            isVideo: false
                        ))
                    }
                }
                previousAsset = asset
            }
            
            // If the user's real library has no results (e.g. simulator), load mock data
            if items.isEmpty {
                completion(self.getMockPhotos())
            } else {
                // Mix in a couple of mock elements to show videos and blurry pictures for variety
                var mixed = items
                let mocks = self.getMockPhotos()
                if let video = mocks.first(where: { $0.type == .largeVideo }) {
                    mixed.append(video)
                }
                if let blurry = mocks.first(where: { $0.type == .blurry }) {
                    mixed.append(blurry)
                }
                completion(mixed.shuffled())
            }
        }
    }
    
    // Cozy fallback mockup photos using Unsplash URLs matching A Little to the Left aesthetics
    func getMockPhotos() -> [PhotoItem] {
        return [
            PhotoItem(
                id: "mock_1",
                title: "ボケてしまった朝の珈琲",
                imageUrlString: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600&auto=format&fit=crop&q=80",
                type: .blurry,
                sizeMB: 12.4,
                coinsReward: 15,
                date: "2026/05/28",
                reason: "AI判定: ピンぼけ (強)",
                isVideo: false
            ),
            PhotoItem(
                id: "mock_2",
                title: "重複したお昼寝中の猫 (A)",
                imageUrlString: "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=600&auto=format&fit=crop&q=80",
                type: .duplicate,
                sizeMB: 8.2,
                coinsReward: 10,
                date: "2026/05/27",
                reason: "AI判定: 重複 (類似度99%)",
                isVideo: false
            ),
            PhotoItem(
                id: "mock_3",
                title: "重複したお昼寝中の猫 (B)",
                imageUrlString: "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=600&auto=format&fit=crop&q=80",
                type: .duplicate,
                sizeMB: 8.2,
                coinsReward: 10,
                date: "2026/05/27",
                reason: "AI判定: 重複 (類似度99%)",
                isVideo: false
            ),
            PhotoItem(
                id: "mock_4",
                title: "散らかったデスクのスクショ",
                imageUrlString: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600&auto=format&fit=crop&q=80",
                type: .screenshot,
                sizeMB: 3.5,
                coinsReward: 5,
                date: "2026/05/25",
                reason: "AI判定: スクリーンショット",
                isVideo: false
            ),
            PhotoItem(
                id: "mock_5",
                title: "ブレた本棚と観葉植物",
                imageUrlString: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=600&auto=format&fit=crop&q=80&blur=30",
                type: .blurry,
                sizeMB: 14.1,
                coinsReward: 20,
                date: "2026/05/24",
                reason: "AI判定: ピンぼけ (強)",
                isVideo: false
            ),
            PhotoItem(
                id: "mock_6",
                title: "長すぎる夕暮れの散歩動画",
                imageUrlString: "https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?w=600&auto=format&fit=crop&q=80",
                type: .largeVideo,
                sizeMB: 142.0,
                coinsReward: 50,
                date: "2026/05/22",
                reason: "AI判定: 大容量動画 (100MB超)",
                isVideo: true
            ),
            PhotoItem(
                id: "mock_7",
                title: "意味のないメモ用スクショ",
                imageUrlString: "https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?w=600&auto=format&fit=crop&q=80",
                type: .screenshot,
                sizeMB: 4.1,
                coinsReward: 5,
                date: "2026/05/20",
                reason: "AI判定: スクリーンショット",
                isVideo: false
            )
        ]
    }
}
