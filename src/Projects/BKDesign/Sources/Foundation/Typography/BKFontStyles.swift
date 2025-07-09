// Copyright © 2025 Booket. All rights reserved

import UIKit

// MARK: - BKFontName
public enum BKFontName: String {
    case pretendardRegular = "Pretendard-Regular"
    case pretendardMedium = "Pretendard-Medium"
    case pretendardSemiBold = "Pretendard-SemiBold"
    case pretendardBold = "Pretendard-Bold"
    
    // 나중에 추가되면 여기에 네이밍 추가
}

// MARK: - BKFontWeight: 폰트 두께 정의
public enum BKFontWeight: String {
    case regular = "Regular"
    case medium = "Medium"
    case semiBold = "SemiBold"
    case bold = "Bold"
    
    public func toFontName() -> BKFontName {
        switch self {
        case .regular: return .pretendardRegular
        case .medium: return .pretendardMedium
        case .semiBold: return .pretendardSemiBold
        case .bold: return .pretendardBold
        }
    }
}
