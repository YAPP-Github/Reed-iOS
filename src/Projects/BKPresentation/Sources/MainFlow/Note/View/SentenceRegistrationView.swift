// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

struct SentenceRegistrationForm {
    let page: String
    let sentence: String
}

final class SentenceRegistrationView: BaseView {
    private let containerView = UIView()
    private let titleLabel = BKLabel(
        text: """
        기록하고 싶은 페이지와 
        문장을 등록해보세요
        """,
        fontStyle: .heading1(weight: .bold)
    )
    
    private let pageField = BKTextFieldView(
        labelText: "책 페이지",
        placeholder: "기록하고 싶은 페이지를 작성해보세요"
    )
    
    private let sentenceTextView = BKTextView(
        labelText: "문장 기록",
        placeholder: "기록하고 싶은 문장을 작성해보세요"
    )
    
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
        button.leftIcon = BKImage.Icon.maximize
        button.title = "문장 스캔하기"
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        registerButton.layer.cornerRadius = registerButton.bounds.height / 2
        registerButton.layer.masksToBounds = true
        registerButton.clipsToBounds = true
    }
    
    override func setupView() {
        addSubviews(
            titleLabel,
            pageField,
            sentenceTextView,
            registerButton
        )
    }
    
    override func configure() {
        titleLabel.numberOfLines = .zero
    }
    
    override func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        pageField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
                .offset(LayoutConstants.pageFieldOffset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        sentenceTextView.snp.makeConstraints {
            $0.top.equalTo(pageField.snp.bottom)
                .offset(LayoutConstants.sentenceViewOffset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        registerButton.snp.makeConstraints {
            $0.top.equalTo(sentenceTextView.snp.bottom)
                .offset(LayoutConstants.buttonOffset)
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.bottom.equalToSuperview()
        }
    }
}

extension SentenceRegistrationView: RegistrationFormProvidable {
    func registrationForm() -> RegistrationForm? {
        return .sentence(SentenceRegistrationForm(
            page: pageField.text,
            sentence: sentenceTextView.text
        ))
    }
}

private extension SentenceRegistrationView {
    enum LayoutConstants {
        static let horizontalInset = BKInset.inset5
        static let buttonBorderWidth = BKBorder.border1
        static let pageFieldOffset: CGFloat = 40
        static let sentenceViewOffset: CGFloat = 32
        static let buttonOffset: CGFloat = 12
        static let buttonHeight: CGFloat = 38
    }
}
