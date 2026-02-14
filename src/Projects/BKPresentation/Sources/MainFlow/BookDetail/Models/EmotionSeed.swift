// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import SnapKit
import UIKit

enum EmotionSeed: String, CaseIterable {
    case warmth = "따뜻함"
    case joy = "즐거움"
    case sad = "슬픔"
    case insight = "깨달음"
    case etc = "기타"
    
    var image: UIImage {
        switch self {
        case .warmth: return BKImage.Graphics.warm
        case .joy: return BKImage.Graphics.joy
        case .insight: return BKImage.Graphics.insight
        case .sad: return BKImage.Graphics.sad
        case .etc: return BKImage.Graphics.sad
        }
    }
    
    var circleImage: UIImage {
        switch self {
        case .warmth: return BKImage.Graphics.warmCircle
        case .joy: return BKImage.Graphics.joyCircle
        case .sad: return BKImage.Graphics.sadCircle
        case .insight: return BKImage.Graphics.insightCircle
        case .etc: return BKImage.Graphics.insightCircle
        }
    }
    
    var color: UIColor {
        switch self {
        case .warmth: return .bkEmotionColor(.warmth)
        case .joy: return .bkEmotionColor(.joy)
        case .insight: return .bkEmotionColor(.insight)
        case .sad: return .bkEmotionColor(.sadness)
        case .etc: return .bkEmotionColor(.etc)
        }
    }
    
    var baseColor: UIColor {
        switch self {
        case .warmth: return .bkEmotionBaseColor(.warmth)
        case .joy: return .bkEmotionBaseColor(.joy)
        case .insight: return .bkEmotionBaseColor(.insight)
        case .sad: return .bkEmotionBaseColor(.sadness)
        case .etc: return .bkEmotionColor(.etc)
        }
    }
    
    var graphTintColor: UIColor {
        switch self {
        case .warmth: return .bkEmotionGraphTintColor(.warmth)
        case .joy: return .bkEmotionGraphTintColor(.joy)
        case .insight: return .bkEmotionGraphTintColor(.insight)
        case .sad: return .bkEmotionGraphTintColor(.sadness)
        case .etc: return .bkEmotionGraphTintColor(.etc)
        }
    }
    
    static func from(emotion: Emotion) -> Self? {
        switch emotion {
        case .joy: return .joy
        case .sad: return .sad
        case .insight: return .insight
        case .warmth: return .warmth
        case .other: return .etc
        }
    }
    
    static func from(seedName: String) -> Self? {
        switch seedName {
        case "warmth", "따뜻함": return .warmth
        case "joy", "즐거움":   return .joy
        case "sad", "슬픔":     return .sad
        case "insight", "깨달음": return .insight
        case "etc", "기타": return .etc
        default: return nil
        }
    }
    
    static func from(seed: Seed) -> Self? {
        return from(seedName: seed.name)
    }
    
    /// 공유 카드에서 사용하는 배경 이미지
    var cardImage: UIImage {
        switch self {
        case .warmth: return BKImage.Graphics.warmCard
        case .joy: return BKImage.Graphics.joyCard
        case .insight: return BKImage.Graphics.insightCard
        case .sad: return BKImage.Graphics.sadCard
        case .etc: return BKImage.Graphics.etcCard
        }
    }
    
    /// 인스타 스토리 공유 시 설정하는 배경 컬러값
    var shareBackgroundColor: UIColor {
        switch self {
        case .warmth: return UIColor(hex: "FEFCF1")
        case .joy: return UIColor(hex: "FFF7F5")
        case .insight: return UIColor(hex: "FBF8FF")
        case .sad: return UIColor(hex: "F4F8FF")
        case .etc: return UIColor(hex: "F4F8FF")
        }
    }
    
    var descriptionText: String {
        switch self {
        case .etc:
            return "감정으로 문장만 기록했어요"
        default:
            return "감정을 많이 느꼈어요"
        }
    }
}
