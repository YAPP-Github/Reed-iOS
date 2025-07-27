// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public final class BKCheckBox: UIControl {
    public enum CheckboxType {
        case round
        case roundStroke
        case rectangle
        case rectangleStroke
    }
    
    private let imageView = UIImageView()
    private let type: CheckboxType

    public var isChecked: Bool = false {
        didSet {
            updateImage()
        }
    }
    
    override public var isEnabled: Bool {
        didSet {
            isUserInteractionEnabled = isEnabled
            updateImage()
        }
    }

    public init(
        frame: CGRect = .zero,
        type: CheckboxType = .rectangle
    ) {
        self.type = type
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.size.equalTo(
                CGSize(
                    width: LayoutConstants.size,
                    height: LayoutConstants.size
                )
            )
        }
        imageView.image = type.defaultImage
        addTarget(self, action: #selector(toggleCheck), for: .touchUpInside)
        
        isAccessibilityElement = true
        accessibilityTraits = .button
        updateAccessibilityValue()
    }

    private func updateImage() {
        if isEnabled {
            imageView.image = isChecked
                ? type.checkedImage
                : type.defaultImage
        } else {
            imageView.image = type.disabledImage
        }
    }
}

private extension BKCheckBox {
    @objc private func toggleCheck() {
        isChecked.toggle()
        sendActions(for: .valueChanged)
    }
    
    func updateAccessibilityValue() {
        accessibilityValue = isChecked ? "선택됨" : "선택 안됨"
    }
    
    enum LayoutConstants {
        static let size: CGFloat = 24
    }
}

extension BKCheckBox.CheckboxType {
    var defaultImage: UIImage {
        switch self {
        case .round, .roundStroke:
            return BKImage.Checkbox.defaultRound
        case .rectangle, .rectangleStroke:
            return BKImage.Checkbox.defaultRectangle
        }
    }
    
    var checkedImage: UIImage {
        switch self {
        case .round:
            return BKImage.Checkbox.filled
        case .roundStroke:
            return BKImage.Checkbox.strokeRound
        case .rectangle:
            return BKImage.Checkbox.filledRectangle
        case .rectangleStroke:
            return BKImage.Checkbox.strokeRectangle
        }
    }
    
    var disabledImage: UIImage {
        switch self {
        case .round, .roundStroke:
            return BKImage.Checkbox.disabledRound
        case .rectangle, .rectangleStroke:
            return BKImage.Checkbox.disabledRectangle
        }
    }
}
