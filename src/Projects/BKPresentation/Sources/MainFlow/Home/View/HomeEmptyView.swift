// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import SnapKit
import UIKit

final class HomeEmptyView: BaseView {
    let buttonTapped = PassthroughSubject<Void, Never>()
    
    private let shadowView = UIView()
    private let contentView = UIView()
    
    private let rootStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.rootStackSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    private let emptyImageView = UIImageView(image: BKImage.Graphics.emptyBook)
    
    private let labelStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.labelStackSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    private let titleLabel = BKLabel(
        text: "아직 등록된 책이 없어요",
        fontStyle: .headline1(weight: .semiBold)
    )
    
    private let subtitleLabel = BKLabel(
        text: "등록 후 나만의 독서 기록을 남겨 보세요.",
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.tertiary)
    )
    
    private let noteButton: BKButton = {
        let button = BKButton(style: .primary, size: .medium)
        button.title = "등록하기"
        return button
    }()
    
    override func setupView() {
        addSubview(shadowView)
        shadowView.addSubview(contentView)
        contentView.addSubview(rootStack)
        
        emptyImageView.frame.size = .init(width: 112, height: 112)
        
        [emptyImageView, labelStack, noteButton].forEach(rootStack.addArrangedSubview)
        [titleLabel, subtitleLabel].forEach(labelStack.addArrangedSubview)
    }
    
    override func configure() {
        clipsToBounds = false
        
        titleLabel.numberOfLines = 1
        subtitleLabel.numberOfLines = 1
        
        shadowView.layer.shadowColor = UIColor.bkShadowColor(.primary).cgColor
        shadowView.layer.shadowOffset = LayoutConstants.shadowOffset
        shadowView.layer.shadowRadius = LayoutConstants.shadowRadius
        shadowView.layer.shadowOpacity = LayoutConstants.shadowOpacity
        shadowView.clipsToBounds = false
        
        contentView.backgroundColor = .bkBaseColor(.primary)
        contentView.layer.cornerRadius = LayoutConstants.cornerRadius
        contentView.layer.borderWidth = LayoutConstants.borderWidth
        contentView.layer.borderColor = UIColor.bkBorderColor(.primary).cgColor
        contentView.clipsToBounds = true
        
        noteButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    override func setupLayout() {
        shadowView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
                .inset(LayoutConstants.topInset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        rootStack.snp.makeConstraints {
            $0.top.equalToSuperview()
                .inset(LayoutConstants.rootStackTopInset)
            $0.leading.trailing.bottom.equalToSuperview()
                .inset(LayoutConstants.rootStackCommonInset)
        }
        
        noteButton.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
    }
}

private extension HomeEmptyView {
    @objc private func didTapButton() {
        buttonTapped.send()
    }
    
    enum LayoutConstants {
        static let topInset = BKInset.inset3
        static let rootStackSpacing = BKSpacing.spacing6
        static let labelStackSpacing = BKSpacing.spacing1
        static let rootStackTopInset: CGFloat = 52
        static let rootStackCommonInset = BKInset.inset5
        static let cornerRadius = BKRadius.small
        static let borderWidth = BKBorder.border1
        static let shadowRadius = BKRadius.shadow
        static let horizontalInset = BKInset.inset5
        static let shadowOffset = CGSize(width: 0, height: 0)
        static let shadowOpacity: Float = 0.2
    }
}
