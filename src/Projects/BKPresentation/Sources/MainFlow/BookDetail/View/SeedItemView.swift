// Copyright © 2026 Booket. All rights reserved

import BKDesign
import BKDomain
import SnapKit
import UIKit

final class SeedItemView: BaseView {
    // MARK: - UI Components
    private let dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = LayoutConstants.dotRadius
        return view
    }()
    
    private let nameLabel = BKLabel(
        fontStyle: .label2(weight: .regular),
        color: .bkContentColor(.secondary),
        alignment: .center
    )
    
    private let countLabel = BKLabel(
        fontStyle: .caption1(weight: .regular),
        color: .bkContentColor(.tertiary),
        alignment: .center
    )

    override func setupView() {
        addSubviews(dotView, nameLabel, countLabel)
    }

    override func configure() {
        backgroundColor = .bkBaseColor(.primary)
        layer.cornerRadius = LayoutConstants.bgRadius
        clipsToBounds = true
    }
    
    override func setupLayout() {
        dotView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(LayoutConstants.dotToTopInset)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(LayoutConstants.dotSize)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(dotView.snp.bottom).offset(LayoutConstants.nameToDot)
            $0.centerX.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(LayoutConstants.countLabelBottomInset)
        }
    }

    func configure(with seed: Seed) {
        let emotion = EmotionSeed.from(seed: seed)
        dotView.backgroundColor = emotion?.graphTintColor
        nameLabel.setText(text: seed.name)
        countLabel.setText(text: "\(seed.count)개")
    }
}

private extension SeedItemView {
    enum LayoutConstants {
        static let dotRadius = BKRadius.xsmall
        static let bgRadius = BKRadius.medium
        static let dotToTopInset = BKSpacing.spacing3
        static let dotSize = CGSize(width: 10, height: 10)
        
        static let nameToDot = BKSpacing.spacing2
        static let countLabelBottomInset = BKSpacing.spacing2
    }
}
