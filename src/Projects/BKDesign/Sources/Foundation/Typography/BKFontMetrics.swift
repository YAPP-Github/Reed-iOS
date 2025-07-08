// Copyright © 2025 Booket. All rights reserved

import UIKit

// MARK: - BKFontSize: 폰트 크기 정의
public enum BKFontSize: CGFloat {
    case pt11 = 11.0
    case pt12 = 12.0
    case pt13 = 13.0
    case pt14 = 14.0
    case pt15 = 15.0
    case pt16 = 16.0
    case pt17 = 17.0
    case pt18 = 18.0
    case pt20 = 20.0
    case pt22 = 22.0
    case pt24 = 24.0
    case pt28 = 28.0
}

// MARK: - BKLineHeight: 줄 높이 정의
public enum BKLineHeight: CGFloat {
    case percent127_3 = 1.273
    case percent133_4 = 1.334
    case percent134_4 = 1.344
    case percent135_8 = 1.358
    case percent136_4 = 1.364
    case percent138_5 = 1.385
    case percent141_2 = 1.412
    case percent142_9 = 1.429
    case percent144_5 = 1.445
    case percent146_7 = 1.467
    case percent157_1 = 1.571
    case percent162_5 = 1.625
    case percent140 = 1.400
    case percent150 = 1.500
    case percent160 = 1.600
    
    public func calculateAbsoluteLineHeight(for fontSize: CGFloat) -> CGFloat {
        return fontSize * self.rawValue
    }
}

// MARK: - BKLetterSpacing: 자간 정의
public enum BKLetterSpacing: CGFloat {
    case percentNegative2_36 = -0.0236
    case percentNegative2_3 = -0.023
    case percentNegative1_2 = -0.012
    case percentNegative1 = -0.01
    
    public func calculateAbsoluteLetterSpacing(for fontSize: CGFloat) -> CGFloat {
        return fontSize * self.rawValue
    }
}
