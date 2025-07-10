// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public final class BKCheckBox: UIControl {
    public enum CheckboxType {
        case round
        case rectangle
    }
    
    private let imageView = UIImageView()
    private let type: CheckboxType

    var isChecked: Bool = false {
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
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(
            width: LayoutConstants.size,
            height: LayoutConstants.size
        )
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
        }
        imageView.image = type.defaultImage
        addTarget(self, action: #selector(toggleCheck), for: .touchUpInside)
    }

    @objc private func toggleCheck() {
        isChecked.toggle()
        sendActions(for: .valueChanged)
    }

    private func updateImage() {
        if isEnabled {
            imageView.image = isChecked
                ? type.checkedImage
                : type.unCheckedImage
        } else {
            imageView.image = type.disabledImage
        }
    }
}

private extension BKCheckBox {
    enum LayoutConstants {
        static let size: CGFloat = 24
    }
}

extension BKCheckBox.CheckboxType {
    var defaultImage: UIImage {
        switch self {
        case .round:
            return BKImage.Checkbox.defaultRound
        case .rectangle:
            return BKImage.Checkbox.defaultRectangle
        }
    }
    
    var checkedImage: UIImage {
        switch self {
        case .round:
            return BKImage.Checkbox.filled
        case .rectangle:
            return BKImage.Checkbox.filledRectangle
        }
    }
    
    var unCheckedImage: UIImage {
        switch self {
        case .round:
            return BKImage.Checkbox.strokeRound
        case .rectangle:
            return BKImage.Checkbox.strokeRectangle
        }
    }
    
    var disabledImage: UIImage {
        switch self {
        case .round:
            return BKImage.Checkbox.disabledRound
        case .rectangle:
            return BKImage.Checkbox.disabledRectangle
        }
    }
}
