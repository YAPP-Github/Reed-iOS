// Copyright © 2025 Booket. All rights reserved

import UIKit

// MARK: - Bottom Sheet Protocol
public protocol BKBottomSheetProtocol: AnyObject {
    var titleStyle: BKBottomSheetTitleStyle { get set }
    var contentView: UIView { get set }
    var buttonConfiguration: BKButtonGroup? { get set }
    var isDismissible: Bool { get set }
    var cornerRadius: CGFloat { get set }
    var preferredHeight: BKBottomSheetHeight { get set }
    
    func show(from viewController: UIViewController, animated: Bool)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

public enum BKBottomSheetHeight {
    case automatic
    case fixed(CGFloat)
}
