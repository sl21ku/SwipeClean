// PhotoItem.swift
// Model representing a single photo or video to be cleaned up.

import Foundation

struct PhotoItem: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let imageUrlString: String // Sourced from Unsplash or local resource path
    let type: PhotoType
    let sizeMB: Double
    let coinsReward: Int
    let date: String
    let reason: String
    let isVideo: Bool

    enum PhotoType: String, Codable, Sendable {
        case blurry = "blurry"
        case duplicate = "duplicate"
        case screenshot = "screenshot"
        case largeVideo = "large_video"
        
        var displayName: String {
            switch self {
            case .blurry: return "ピンぼけ"
            case .duplicate: return "重複写真"
            case .screenshot: return "スクショ"
            case .largeVideo: return "大容量動画"
            }
        }
        
        var icon: String {
            switch self {
            case .blurry: return "📷"
            case .duplicate: return "👯"
            case .screenshot: return "📱"
            case .largeVideo: return "🎥"
            }
        }
    }
}
