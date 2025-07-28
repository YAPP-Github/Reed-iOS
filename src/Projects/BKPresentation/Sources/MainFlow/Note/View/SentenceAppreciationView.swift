// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

struct SentenceAppreciationForm {
    let appreciation: String
}

final class SentenceAppreciationView: BaseView {
    private let containerView = UIView()
    private let titleLabel = BKLabel(
        text: "문장에 대한 감상을 남겨주세요",
        fontStyle: .heading1(weight: .bold)
    )
    
    private let subtitleLabel = BKLabel(
        text: "감상평 가이드로 쉽게 남길 수 있어요",
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.tertiary)
    )
    
    private let appreciationTextView = BKTextView(
        placeholder: "내용을 입력해주세요."
    )
    
    private let titleStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.titleStackSpacing
        stackView.alignment = .leading
        return stackView
    }()
    
    private let registerButton: BKButton = {
        let button = BKButton(
            style: .custom(
                background: BKButtonColorSet(
                    normal: .bkBaseColor(.primary),
                    pressed: .bkBaseColor(.primary),
                    disabled: .bkBaseColor(.primary)
                ),
                foreground: BKButtonColorSet(
                    normal: .bkContentColor(.brand),
                    pressed: .bkContentColor(.brand),
                    disabled: .bkContentColor(.brand)
                )
            )
        )
        button.layer.borderWidth = LayoutConstants.buttonBorderWidth
        button.layer.borderColor = UIColor.bkBorderColor(.brand).cgColor
        button.layer.cornerRadius = LayoutConstants.buttonHeight / 2
        button.leftIcon = BKImage.Icon.maximize
        button.title = "감상평 가이드"
        return button
    }()
    
    override func setupView() {
        addSubview(containerView)
        containerView.addSubviews(titleStack, appreciationTextView, registerButton)
        [titleLabel, subtitleLabel].forEach(titleStack.addArrangedSubview(_:))
    }
    
    override func configure() {
        titleLabel.numberOfLines = .zero
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        titleStack.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        appreciationTextView.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom)
                .offset(LayoutConstants.sentenceViewOffset)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        registerButton.snp.makeConstraints {
            $0.top.equalTo(appreciationTextView.snp.bottom)
                .offset(LayoutConstants.buttonOffset)
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.height.equalTo(38)
            $0.bottom.equalToSuperview()
        }
    }
}

extension SentenceAppreciationView: RegistrationFormProvidable {
    func registrationForm() -> RegistrationForm? {
        return .appreciation(SentenceAppreciationForm(
            appreciation: appreciationTextView.text
        ))
    }
}

private extension SentenceAppreciationView {
    enum LayoutConstants {
        static let horizontalInset = BKInset.inset5
        static let buttonBorderWidth = BKBorder.border1
        static let sentenceViewOffset: CGFloat = 40
        static let buttonOffset: CGFloat = 12
        static let buttonHeight: CGFloat = 38
        static let titleStackSpacing = BKSpacing.spacing1
    }
}
