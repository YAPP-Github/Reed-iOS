// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

/// 밑줄이 있는 텍스트 버튼 컴포넌트입니다.
///
/// 링크 스타일의 텍스트 버튼으로, 배경 없이 텍스트와 밑줄만 표시됩니다.
/// `BKButtonGroup`과 함께 사용할 수 있습니다.
public final class BKTextButton: UIControl {
    
    // MARK: - Public Properties
    
    /// 버튼에 표시될 텍스트
    public var title: String? {
        didSet {
            titleLabel.text = title
            invalidateIntrinsicContentSize()
        }
    }
    
    /// 버튼의 비활성화 여부
    public var isDisabled: Bool = false {
        didSet {
            isEnabled = !isDisabled
            updateColors()
        }
    }
    
    /// 버튼 크기 (폰트 크기에 영향)
    public var size: BKButtonSize = .small {
        didSet {
            titleLabel.font = size.font
            invalidateIntrinsicContentSize()
        }
    }
    
    /// 텍스트 및 밑줄 색상 설정
    public var foregroundColors: BKButtonColorSet = BKButtonColorSet(
        normal: .bkContentColor(.brand),
        pressed: .bkContentColor(.brand),
        disabled: .bkContentColor(.disable)
    ) {
        didSet {
            updateColors()
        }
    }
    
    // MARK: - Override Properties
    
    public override var isHighlighted: Bool {
        didSet {
            updateColors()
            animatePressedState()
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            updateColors()
        }
    }
    
    // MARK: - Private Properties
    
    private let titleLabel = UILabel()
    private let underlineView = UIView()
    
    private let animationDuration: TimeInterval = 0.15
    
    private var currentState: BKButtonState {
        BKButtonState(isEnabled: isEnabled, isHighlighted: isHighlighted)
    }
    
    // MARK: - Initialization
    
    public init(title: String? = nil, size: BKButtonSize = .small) {
        super.init(frame: .zero)
        self.title = title
        self.size = size
        setupViews()
        updateColors()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        updateColors()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        setupTitleLabel()
        setupUnderlineView()
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        
        titleLabel.text = title
        titleLabel.font = size.font
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupUnderlineView() {
        addSubview(underlineView)
        
        underlineView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(1)
            $0.leading.trailing.equalTo(titleLabel)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Update Methods
    
    private func updateColors() {
        let color = foregroundColors.color(for: currentState)
        titleLabel.textColor = color
        underlineView.backgroundColor = color
    }
    
    // MARK: - Animation
    
    private func animatePressedState() {
        let targetAlpha: CGFloat = isHighlighted ? 0.6 : 1.0
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                self.titleLabel.alpha = targetAlpha
                self.underlineView.alpha = targetAlpha
            }
        )
    }
    
    // MARK: - Intrinsic Content Size
    
    public override var intrinsicContentSize: CGSize {
        let labelSize = titleLabel.intrinsicContentSize
        // 라벨 높이 + 밑줄 오프셋(1) + 밑줄 높이(1)
        return CGSize(
            width: labelSize.width,
            height: labelSize.height + 2
        )
    }
}

// MARK: - Factory Methods
extension BKTextButton {
    /// 텍스트 버튼 생성
    public static func text(title: String, size: BKButtonSize = .small) -> BKTextButton {
        BKTextButton(title: title, size: size)
    }
}

/* 커스텀 색상세트 사용 시
 let customButton = BKTextButton(title: "커스텀", size: .small)
 customButton.foregroundColors = BKButtonColorSet(
     normal: .systemBlue,
     pressed: .systemBlue,
     disabled: .systemGray
 )
 */
