// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class CollectedSentenceView: BaseView {
    private let containerView = UIView()
    private let titleLabel = BKLabel(
        text: "수집한 문장",
        fontStyle: .body1(weight: .medium),
        color: .bkContentColor(.primary)
    )
    
    private let rootStackBackgroundView = UIView()
    private let rootStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.rootStackSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    private let collectedSentenceLabel = BKLabel(
        fontStyle: .label1(weight: .medium),
        alignment: .left
    )
    
    private let pageLabel = BKLabel(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.brand),
        alignment: .right
    )
    
    override func setupView() {
        addSubview(containerView)
        [collectedSentenceLabel, pageLabel].forEach(rootStack.addArrangedSubview(_:))
        rootStackBackgroundView.addSubview(rootStack)
        containerView.addSubviews(titleLabel, rootStackBackgroundView)
    }
    
    override func configure() {
        collectedSentenceLabel.numberOfLines = 0
        rootStackBackgroundView.backgroundColor = .bkBaseColor(.secondary)
        rootStackBackgroundView.layer.cornerRadius = LayoutConstants.rootStackRadius
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        rootStackBackgroundView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
                .offset(LayoutConstants.rootStackTopOffset)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        rootStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
                .inset(LayoutConstants.rootStackInset)
        }
        
        collectedSentenceLabel.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        
        pageLabel.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
    }
    
    func apply(
        sentence: String,
        page: Int
    ) {
        collectedSentenceLabel.setText(text: sentence)
        pageLabel.setText(text: "\(page)p")
    }
}

private extension CollectedSentenceView {
    enum LayoutConstants {
        static let rootStackSpacing = BKSpacing.spacing05
        static let rootStackInset = BKInset.inset4
        static let rootStackRadius = BKRadius.medium
        static let rootStackTopOffset = BKInset.inset2
    }
}
