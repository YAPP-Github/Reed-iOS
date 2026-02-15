// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

/// 삭제 버튼이 있는 선택된 상태의 Chip
/// EmotionRegistrationView에서 선택된 세부 감정을 표시하는 용도로 사용
public final class BKRemovableChip: UIView {
    private let titleLabel = BKLabel2()

    private let removeButton: UIImageView = {
        let imageView = UIImageView(image: BKImage.Icon.x)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .bkContentColor(.brand)
        return imageView
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()

    public var title: String = "" {
        didSet {
            titleLabel.setText(text: title)
        }
    }

    public var onRemove: (() -> Void)?

    public init(title: String, onRemove: (() -> Void)? = nil) {
        super.init(frame: .zero)
        self.title = title
        self.onRemove = onRemove
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        setupViews()
        setupLayout()
        setupGesture()
    }

    private func setupViews() {
        backgroundColor = UIColor(hex: "#E3F8E9")
        layer.cornerRadius = 14
        layer.borderWidth = 1
        layer.borderColor = UIColor.bkBorderColor(.brand).cgColor

        titleLabel.setText(text: title)
        titleLabel.setFontStyle(style: .label1(weight: .medium))
        titleLabel.setColor(color: .bkContentColor(.brand))

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(removeButton)
        addSubview(stackView)
    }

    private func setupLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 8))
        }

        removeButton.snp.makeConstraints {
            $0.size.equalTo(14)
        }
    }

    private func setupGesture() {
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        onRemove?()
    }
}
