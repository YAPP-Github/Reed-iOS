// Copyright © 2025 Booket. All rights reserved

import UIKit

/// `tuist generate` 명령 사용 시, Derived/TuistAsset...swift 파일이 자동 생성됩니다.
/// 생성된 파일에 있는 요소 그대로 가져다 쓰시면 됩니다.
/// 추가로, 내부에 nested enum으로 네임스페이스를 나눴는데,
/// asset 추가 시 분류에 따라 네임스페이스 맞춰 추가해주시면 됩니다.
public enum BKImage {
    public enum Icon {
        public static let alertCircle = BKDesignAsset.alertCircle.image
        public static let apple = BKDesignAsset.apple.image
        public static let bellOff = BKDesignAsset.bellOff.image
        public static let bell = BKDesignAsset.bell.image
        public static let bookOpen = BKDesignAsset.bookOpen.image
        public static let bookmark = BKDesignAsset.bookmark.image
        public static let check = BKDesignAsset.check.image
        public static let chevronDown = BKDesignAsset.chevronDown.image
        public static let chevronLeft = BKDesignAsset.chevronLeft.image
        public static let chevronRight = BKDesignAsset.chevronRight.image
        public static let chevronUp = BKDesignAsset.chevronUp.image
        public static let edit2 = BKDesignAsset.edit2.image
        public static let edit3 = BKDesignAsset.edit3.image
        public static let edit = BKDesignAsset.edit.image
        public static let kakao = BKDesignAsset.kakao.image
        public static let loader = BKDesignAsset.loader.image
        public static let maximize = BKDesignAsset.maximize.image
        public static let menu = BKDesignAsset.menu.image
        public static let moreHorizontal = BKDesignAsset.moreHorizontal.image
        public static let moreVertical = BKDesignAsset.moreVertical.image
        public static let plus = BKDesignAsset.plus.image
        public static let search = BKDesignAsset.search.image
        public static let settings = BKDesignAsset.settings.image
        public static let star = BKDesignAsset.star.image
        public static let x = BKDesignAsset.x.image
        public static let xCircle = BKDesignAsset.xCircle.image
        public static let home = BKDesignAsset.home.image
        public static let archive = BKDesignAsset.folder.image
    }
    
    public enum Checkbox {
        public static let defaultRectangle = BKDesignAsset.checkboxDefaultRectangle.image
        public static let defaultRound = BKDesignAsset.checkboxDefaultRound.image
        public static let disabledRectangle = BKDesignAsset.checkboxDisabledRectangle.image
        public static let disabledRound = BKDesignAsset.checkboxDisabledRound.image
        public static let filledRectangle = BKDesignAsset.checkboxFilledRectangle.image
        public static let filled = BKDesignAsset.checkboxFilled.image
        public static let icononlyActiveRectangle = BKDesignAsset.checkboxIcononlyActiveRectangle.image
        public static let icononlyActiveRound = BKDesignAsset.checkboxIcononlyActiveRound.image
        public static let icononlyDefaultRectangle = BKDesignAsset.checkboxIcononlyDefaultRectangle.image
        public static let icononlyDefaultRound = BKDesignAsset.checkboxIcononlyDefaultRound.image
        public static let strokeRectangle = BKDesignAsset.checkboxStrokeRectangle.image
        public static let strokeRound = BKDesignAsset.checkboxStrokeRound.image
    }
    
    public enum Graphics {
        public static let mascot = BKDesignAsset.mascot.image
        public static let onboarding2 = BKDesignAsset.onboarding2.image
        public static let homeChar = BKDesignAsset.homeCharacter.image
        public static let empty = BKDesignAsset.empty.image
    }
}
