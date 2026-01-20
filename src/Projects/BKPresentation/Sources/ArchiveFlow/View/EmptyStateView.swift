// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import UIKit
import SnapKit

final class EmptyStateView: BaseView {
    var onTapActionButton: (() -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    private let titleLabel = BKLabel(
        text: "",
        fontStyle: .headline1(weight: .semiBold),
        color: .bkContentColor(.primary),
        alignment: .center
    )
    
    private let descriptionLabel = BKLabel(
        text: "",
        fontStyle: .body1(weight: .medium),
        color: .bkContentColor(.secondary),
        alignment: .center
    )
    
    private let actionButton: BKButton = {
        let button = BKButton(style: .secondary, size: .small)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, actionButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    override func setupView() {
        addSubview(stackView)
    }
    
    override func setupLayout() {
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }
        stackView.setCustomSpacing(16, after: descriptionLabel)
    }
    
    override func configure() {
        actionButton.isHidden = true
        actionButton.addTarget(self, action: #selector(tapActionButton), for: .touchUpInside)
        
        AccessModeCenter.shared.mode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mode in
                self?.apply(mode: mode)
            }
            .store(in: &cancellables)
        
        apply(mode: AccessModeCenter.shared.mode.value)
    }
}

private extension EmptyStateView {
    enum Constants {
        static let guestTitle = "아직 등록된 책이 없어요"
        static let guestSubtitle = "로그인 후 나만의 서재를 채워보세요"
        static let memberTitle = "아직 등록된 책이 없어요"
        static let memberSubtitle = "도서 등록 후 나만의 아카이브를 만들어보세요"
        static let loginButtonTitle = "로그인하기"
        static let requestButtonTitle = "문의하기"
    }
    
    func apply(mode: AppAccessMode) {
        switch mode {
        case .guest:
            titleLabel.setText(text: Constants.guestTitle)
            descriptionLabel.setText(text: Constants.guestSubtitle)
            actionButton.title = Constants.requestButtonTitle
        case .member:
            titleLabel.setText(text: Constants.memberTitle)
            descriptionLabel.setText(text: Constants.memberSubtitle)
            actionButton.title = Constants.loginButtonTitle
        }
    }
    
    @objc func tapActionButton() {
        onTapActionButton?()
    }
}
