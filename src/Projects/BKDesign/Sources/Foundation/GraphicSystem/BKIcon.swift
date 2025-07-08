// Copyright © 2025 Booket. All rights reserved

import UIKit

public enum BKIcon: String {
    case alert = "alert-circle"
    case appleLogo = "apple"
    case bellOff = "bell-off"
    case bell = "bell"
    case bookOpen = "book-open"
    case bookmark = "bookmark"
    case check = "check"
    case chevronDown = "chevron-down"
    case chevronUp = "chevron-up"
    case chevronLeft = "chevron-left"
    case chevronRight = "chevron-right"
    case editMemo = "edit"
    case edit = "edit-2"
    case editLine = "edit-3"
    case kakaoLogo = "kakao"
    case loader = "loader"
    case maximize = "maximize"
    case menu = "menu"
    case moreHorizontal = "more-horizontal"
    case moreVertical = "more-vertical"
    case plus = "plus"
    case search = "search"
    case settings = "settings"
    case star = "star"
    case xmark = "x"

    private static var bundle: Bundle {
        return Bundle.module // Swift Package일 경우
        // return Bundle(for: SomeClassInBKDesign.self) // Framework일 경우
    }
    
    /// 해당 아이콘 이름을 가진 UIImage를 반환합니다.
    public var image: UIImage? {
        return UIImage(named: self.rawValue, in: BKIcon.bundle, with: nil)
    }
}
