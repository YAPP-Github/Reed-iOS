// Copyright © 2025 Booket. All rights reserved

import UIKit

/// 바텀시트의 타이틀 스타일을 정의합니다.
public enum BKBottomSheetTitleStyle {
    /// 타이틀 없음
    case none

    /// leading 정렬 - 타이틀만
    case title(_ title: String)

    /// leading 정렬 - 타이틀 + X 버튼
    case titleWithCloseButton(title: String)

    /// leading 정렬 - 타이틀 + 서브타이틀
    case titleWithSubtitle(title: String, subtitle: String)

    /// leading 정렬 - 타이틀 + 서브타이틀 + X 버튼
    case titleWithSubtitleAndCloseButton(title: String, subtitle: String)
}
