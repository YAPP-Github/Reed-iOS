// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

struct SentenceRegistrationForm {
    let page: String
    let sentence: String
}

enum SentenceRegistrationEvent {
    case ocrScanTapped
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
    
    private let textScanButton = BKButton(
        style: .stroke,
        size: .rounded
    )
    
    override func setupView() {
        addSubviews(
            titleLabel,
            pageField,
            sentenceTextView,
            textScanButton
        )
    }
    
    override func configure() {
        titleLabel.numberOfLines = .zero
        textScanButton.title = "문장 스캔하기"
        textScanButton.leftIcon = BKImage.Icon.maximize
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
        
        textScanButton.snp.makeConstraints {
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
