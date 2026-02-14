// Copyright © 2025 Booket. All rights reserved

import UIKit

public final class BKChip: UIView {
    private var titleLabel = BKLabel2()
    private var countLabel = BKLabel2()
    private let labelContainer = UIView()
    public var onTap: (() -> Void)?
    
    public var isSelected: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    public var title: String = "" {
        didSet {
            titleLabel.setText(text: title)
        }
    }
    
    // swiftlint:disable empty_count
    public var count: Int = 0 {
        didSet {
            countLabel.setText(text: "\(count)")
            countLabel.isHidden = (count == 0)
        }
    }
    
    public init(title: String, count: Int = 0, onTap: (() -> Void)? = nil) {
        super.init(frame: .zero)
        self.title = title
        self.count = count
        self.onTap = onTap
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    private func setupUI() {
        setupViews()
        setupLayout()
        setupGesture()
        updateAppearance()
    }
    
    // swiftlint:disable empty_count
    private func setupViews() {
        titleLabel.setText(text: title)
        countLabel.setText(text: "\(count)")
        countLabel.setFontStyle(style: .label1(weight: .semiBold))
        countLabel.isHidden = (count == 0)

        backgroundColor = .bkBaseColor(.primary)

        labelContainer.addSubviews(titleLabel, countLabel)
        addSubviews(labelContainer)

        layer.borderWidth = 1
        layer.borderColor = UIColor.bkBorderColor(.primary).cgColor
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            if count == 0 {
                $0.trailing.equalToSuperview()
            }
        }

        countLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(BKSpacing.spacing1)
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(titleLabel)
        }

        labelContainer.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        self.snp.makeConstraints {
            $0.width.equalTo(labelContainer.snp.width).offset(BKSpacing.spacing3 * 2)
            $0.height.equalTo(36)
        }
    }
    
    private func updateAppearance() {
        if isSelected {
            backgroundColor = .bkBackgroundColor(.primary)
            layer.borderWidth = 0
            
            // 기존 라벨의 스타일만 업데이트
            titleLabel.setFontStyle(style: .label1(weight: .semiBold))
            titleLabel.setColor(color: .bkBaseColor(.primary))
            
            countLabel.setColor(color: .bkBaseColor(.primary))
        } else {
            backgroundColor = .bkBaseColor(.primary)
            layer.borderWidth = 1
            layer.borderColor = UIColor.bkBorderColor(.primary).cgColor
            
            titleLabel.setFontStyle(style: .label1(weight: .medium))
            titleLabel.setColor(color: .bkContentColor(.secondary))
            
            countLabel.setColor(color: .bkContentColor(.tertiary))
        }
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap)
        )
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}
