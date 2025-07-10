// Copyright © 2025 Booket. All rights reserved

import UIKit

/// BKButton 스타일 버튼을 구성하기 위한 공통 인터페이스입니다.
///
/// 이 프로토콜은 버튼의 상태, 스타일, 크기, 텍스트 및 아이콘 속성을 정의하여
/// 일관된 UI 컴포넌트를 구현할 수 있도록 도와줍니다.
protocol BKButtonProtocol: AnyObject {

    /// 버튼의 활성화 여부를 나타냅니다.
    ///
    /// `true`인 경우 버튼은 비활성화 상태이며, 사용자와의 상호작용이 차단됩니다.
    var isDisabled: Bool { get set }

    /// 버튼의 스타일을 지정합니다.
    ///
    /// 스타일에 따라 배경색, 텍스트 색상 등이 달라집니다.
    var style: BKButtonStyle { get set }

    /// 버튼의 크기를 지정합니다.
    ///
    /// 크기에 따라 높이, 폰트, 패딩 값 등이 조정됩니다.
    var size: BKButtonSize { get set }

    /// 버튼에 표시될 텍스트입니다.
    var title: String? { get set }

    /// 버튼의 왼쪽에 표시될 아이콘 이미지입니다.
    var leftIcon: UIImage? { get set }

    /// 버튼의 오른쪽에 표시될 아이콘 이미지입니다.
    var rightIcon: UIImage? { get set }
}
