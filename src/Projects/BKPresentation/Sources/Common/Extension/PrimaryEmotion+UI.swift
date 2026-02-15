// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import UIKit

// MARK: - UI Properties (EmotionSeed, EmotionIcon 통합)

public extension PrimaryEmotion {
    /// 기본 이미지
    var image: UIImage {
        switch self {
        case .warmth: return BKImage.Graphics.warm
        case .joy: return BKImage.Graphics.joy
        case .insight: return BKImage.Graphics.insight
        case .sadness: return BKImage.Graphics.sad
        case .other: return BKImage.Graphics.Note.default
        }
    }

    /// 원형 이미지
    var circleImage: UIImage {
        switch self {
        case .warmth: return BKImage.Graphics.warmCircle
        case .joy: return BKImage.Graphics.joyCircle
        case .sadness: return BKImage.Graphics.sadCircle
        case .insight: return BKImage.Graphics.insightCircle
        case .other: return BKImage.Graphics.Note.default
        }
    }

    /// Note 화면용 이미지
    var noteImage: UIImage {
        switch self {
        case .warmth: return BKImage.Graphics.Note.warm
        case .joy: return BKImage.Graphics.Note.joy
        case .sadness: return BKImage.Graphics.Note.sad
        case .insight: return BKImage.Graphics.Note.insight
        case .other: return BKImage.Graphics.Note.default
        }
    }

    /// 감정 색상
    var color: UIColor {
        switch self {
        case .warmth: return .bkEmotionColor(.warmth)
        case .joy: return .bkEmotionColor(.joy)
        case .insight: return .bkEmotionColor(.insight)
        case .sadness: return .bkEmotionColor(.sadness)
        case .other: return .bkContentColor(.tertiary)
        }
    }

    /// 감정 베이스 색상
    var baseColor: UIColor {
        switch self {
        case .warmth: return .bkEmotionBaseColor(.warmth)
        case .joy: return .bkEmotionBaseColor(.joy)
        case .insight: return .bkEmotionBaseColor(.insight)
        case .sadness: return .bkEmotionBaseColor(.sadness)
        case .other: return .bkBaseColor(.secondary)
        }
    }

    /// 해시태그 형식
    var hashtag: String {
        return "#\(displayName)"
    }

    /// 공유 카드 배경 이미지
    var cardImage: UIImage {
        switch self {
        case .warmth: return BKImage.Graphics.warmCard
        case .joy: return BKImage.Graphics.joyCard
        case .insight: return BKImage.Graphics.insightCard
        case .sadness: return BKImage.Graphics.sadCard
        case .other: return BKImage.Graphics.etcCard
        }
    }

    /// 인스타 스토리 공유 시 배경 컬러
    var shareBackgroundColor: UIColor {
        switch self {
        case .warmth: return UIColor(hex: "FEFCF1")
        case .joy: return UIColor(hex: "FFF7F5")
        case .insight: return UIColor(hex: "FBF8FF")
        case .sadness: return UIColor(hex: "F4F8FF")
        case .other: return .white
        }
    }
}

// MARK: - Conversion from legacy Emotion

public extension PrimaryEmotion {
    /// 기존 Emotion에서 변환
    init?(from legacyEmotion: Emotion) {
        switch legacyEmotion {
        case .warmth: self = .warmth
        case .joy: self = .joy
        case .sad: self = .sadness
        case .insight: self = .insight
        case .other: self = .other
        }
    }

    /// 기존 Emotion으로 변환 (하위 호환성)
    var toLegacyEmotion: Emotion {
        switch self {
        case .warmth: return .warmth
        case .joy: return .joy
        case .sadness: return .sad
        case .insight: return .insight
        case .other: return .other
        }
    }
}

// MARK: - Conversion from Seed

public extension PrimaryEmotion {
    /// Seed 이름에서 변환
    static func from(seedName: String) -> Self? {
        switch seedName.lowercased() {
        case "warmth", "따뜻함": return .warmth
        case "joy", "즐거움": return .joy
        case "sad", "sadness", "슬픔": return .sadness
        case "insight", "깨달음": return .insight
        default: return nil
        }
    }

    /// Seed 엔티티에서 변환
    static func from(seed: Seed) -> Self? {
        return from(seedName: seed.name)
    }

    /// 기본 4가지 감정 (other 제외)
    static var displayCases: [PrimaryEmotion] {
        return [.warmth, .joy, .sadness, .insight]
    }
}
