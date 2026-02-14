// Copyright © 2025 Booket. All rights reserved

import Foundation

/// 대분류 감정 (API V2 스펙)
public enum PrimaryEmotion: String, CaseIterable, Codable {
    case warmth = "WARMTH"
    case joy = "JOY"
    case sadness = "SADNESS"
    case insight = "INSIGHT"
    case other = "OTHER"

    /// 한글 표시명
    public var displayName: String {
        switch self {
        case .warmth: return "따뜻함"
        case .joy: return "즐거움"
        case .sadness: return "슬픔"
        case .insight: return "깨달음"
        case .other: return "기타"
        }
    }

    /// 설명
    public var description: String {
        switch self {
        case .warmth: return "공감과 위로가 된 순간"
        case .joy: return "흥미롭고 유쾌한 순간"
        case .sadness: return "눈물이 고인 순간"
        case .insight: return "생각이 깊어지는 순간"
        case .other: return "네 가지 감정으로 표현하기 어려울 때"
        }
    }
}
