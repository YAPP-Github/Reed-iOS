// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import SnapKit
import UIKit

struct SentenceAppreciationForm {
    let appreciation: String
}

final class SentenceAppreciationView: BaseView {
    private let textDidChangeSubject = PassthroughSubject<Void, Never>()
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
    
    private let guideButton = BKButton(
        style: .stroke,
        size: .rounded
    )
    
    init(guideButtonAction: @escaping () -> Void) {
        super.init(frame: .zero)
        guideButton.addAction(UIAction { _ in
            guideButtonAction()
        }, for: .touchUpInside)
    }
    
    override func setupView() {
        addSubviews(titleStack, appreciationTextView, guideButton)
        [titleLabel, subtitleLabel].forEach(titleStack.addArrangedSubview(_:))
    }
    
    override func configure() {
        titleLabel.numberOfLines = .zero
        guideButton.leftIcon = BKImage.Icon.bookOpen
        guideButton.title = "감상평 가이드"
    }
    
    override func setupLayout() {
        titleStack.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        appreciationTextView.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom)
                .offset(LayoutConstants.sentenceViewOffset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        guideButton.snp.makeConstraints {
            $0.top.equalTo(appreciationTextView.snp.bottom)
                .offset(LayoutConstants.buttonOffset)
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.bottom.equalToSuperview()
        }
    }
    
    func setText(_ content: String) {
        appreciationTextView.setText(content)
    }
    
    func startEditingIfNeeded() {
        appreciationTextView.startEditing()
    }
}

extension SentenceAppreciationView: RegistrationFormProvidable, FormInputNotifiable {
    var inputChangedPublisher: AnyPublisher<Void, Never> {
        appreciationTextView.textDidChangePublisher
    }

    func registrationForm() -> RegistrationForm? {
        let trimmedSentence = appreciationTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSentence.isEmpty else {
            return nil
        }
        
        return .appreciation(SentenceAppreciationForm(
            appreciation: trimmedSentence
        ))
    }
}

private extension SentenceAppreciationView {
    enum LayoutConstants {
        static let horizontalInset = BKInset.inset5
        static let buttonBorderWidth = BKBorder.border1
        static let sentenceViewOffset: CGFloat = 40
        static let buttonOffset: CGFloat = 12
        static let titleStackSpacing = BKSpacing.spacing1
    }
}
