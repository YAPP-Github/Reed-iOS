// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class BookDetailViewHeader: BaseView {
    var onTapSortButton: (() -> Void)?
    
    private let titleLabel = BKLabel(
        fontStyle: .headline2(weight: .semiBold),
        highlightColor: .bkContentColor(.tertiary)
    )
    
    private let sortButtonStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = LayoutConstants.sortButtonStackSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    private let sortStateLabel = BKLabel2(
        text: "페이지 순",
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.secondary)
    )
    
    private let sortArrowImageView = UIImageView(image: BKImage.Icon.chevronDown)
    
    override func setupView() {
        addSubviews(titleLabel, sortButtonStack)
        [sortStateLabel, sortArrowImageView].forEach(sortButtonStack.addArrangedSubview)
    }
    
    override func configure() {
        sortArrowImageView.tintColor = .bkContentColor(.secondary)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sortButtonTapped))
        sortButtonStack.addGestureRecognizer(tapGesture)
    }
    
    override func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
        }
        
        sortButtonStack.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
        }
    }
    
    func applyHeaderTitle(count: Int) {
        titleLabel.setText(text: "내 기록 모음 \(count)")
        titleLabel.highlightedWord = "\(count)"
    }
    
    func applyHeaderState(_ option: SortOption) {
        sortStateLabel.setText(text: option.rawValue)
    }
}

private extension BookDetailViewHeader {
    @objc func sortButtonTapped() {
        onTapSortButton?()
    }
    
    enum LayoutConstants {
        static let sortButtonStackSpacing = BKSpacing.spacing1
    }
}
