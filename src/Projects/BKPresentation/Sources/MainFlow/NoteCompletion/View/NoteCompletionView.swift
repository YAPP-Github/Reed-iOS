// Copyright © 2025 Booket. All rights reserved

import BKDesign
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
        stackView.alignment = .center
        return stackView
    }()
    
    private let collectedSentenceView = CollectedSentenceView()
    private let appreciationResultView = AppreciationResultView()
    
    override func setupView() {
        addSubview(containerView)
        containerView.addSubviews(resultView, divider, contentStack)
        [collectedSentenceView, appreciationResultView].forEach(contentStack.addArrangedSubview(_:))
    }
    
    /// 임시로 넣어둔 데이터들입니다.
    override func configure() {
        resultView.configure(
            title: "title",
            author: "author",
            publisher: "publisher"
        )
        
        collectedSentenceView.apply(sentence: """
        “소설가들은 늘 소재를 찾아 떠도는 존재 같지만, 실은 그 반대인 경우가 더 잦다.”
        """, page: 100)
        
        appreciationResultView.apply(
            emotion: .someEmotion1,
            creationDate: "2025.07.28",
            appreciation: """
            소설가들은 늘 소재를 찾아 떠도는 존재 같지만, 실은 그 반대인 경우가 더 잦다.
            """
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
