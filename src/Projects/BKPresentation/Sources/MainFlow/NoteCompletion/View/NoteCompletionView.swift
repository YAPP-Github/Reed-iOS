// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import SnapKit
import UIKit

final class NoteCompletionView: BaseView {
    private let containerView = UIView()
    private let resultView = BKBookSummaryView(style: .compact)
    private let divider = BKDivider(type: .medium)
    private let contentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.contentStackSpacing
        stackView.alignment = .fill
        return stackView
    }()
    
    private let collectedSentenceView = CollectedSentenceView()
    private let appreciationResultView = AppreciationResultView()
    
    override func setupView() {
        addSubview(containerView)
        containerView.addSubviews(resultView, divider, contentStack)
        [collectedSentenceView, appreciationResultView].forEach(contentStack.addArrangedSubview(_:))
    }
    
    func apply(
        recordInfo: RecordInfo
    ) {
        resultView.configure(
            title: recordInfo.bookTitle,
            author: recordInfo.author,
            publisher: recordInfo.bookPublisher,
            image: recordInfo.bookCoverImageUrl
        )
        
        collectedSentenceView.apply(
            sentence: recordInfo.quote,
            page: recordInfo.pageNumber
        )
        
        appreciationResultView.apply(
            emotion: EmotionIcon.from(emotion: recordInfo.emotionTags.first ?? .joy),
            creationDate: recordInfo.createdAt,
            appreciation: recordInfo.review
        )
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        resultView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(LayoutConstants.resultViewHeight)
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(resultView.snp.bottom)
                .offset(LayoutConstants.dividerTopOffset)
            $0.leading.trailing.equalToSuperview()
        }
        
        contentStack.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
                .offset(LayoutConstants.contentStackSpacing)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        collectedSentenceView.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        
        appreciationResultView.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
    }
}

private extension NoteCompletionView {
    enum LayoutConstants {
        static let contentStackSpacing = BKSpacing.spacing6
        static let horizontalInset = BKInset.inset5
        static let dividerTopOffset = BKInset.inset2
        static let resultViewHeight: CGFloat = 100
    }
}
