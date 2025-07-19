// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

enum TermsViewEvent {
    
}

final class TermsView: BaseView {
    
    // MARK: - Layout Metrics
    enum LayoutGuide {
        static let innerViewHPadding: CGFloat = BKSpacing.spacing4
        static let iconSize: CGFloat = BKSpacing.spacing6
        static let verticalPadding: CGFloat = BKSpacing.spacing5
        
        static let titleTopInset: CGFloat = 60
        static let agreeAreaTopInset: CGFloat = BKSpacing.spacing7
        static let agreeAreaHeight: CGFloat = 66
        
    }
    
    private let titleLabel = BKLabel(
        text: "약관 동의 후\n독서 기록을 남겨보세요",
        fontStyle: .title2(weight: .semiBold),
        alignment: .left
    )
    
    private let agreeAllAreaView = UIView()
    private let checkOnceBox = BKCheckBox(frame: .zero, type: .rectangle)
    
    private let agreeAllLabel = BKLabel(
        fontStyle: .headline1(weight: .semiBold),
        alignment: .left
    )
    
    private lazy var collectionView: UICollectionView = {
        let layout = createListLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.contentInset.left = BKSpacing.spacing2
        collectionView.contentInset.right = BKSpacing.spacing3
        
        return collectionView
    }()
    
    // MARK: - ViewModel로 이전 예정(뷰만 먼저 봄)
    private var terms: [TermsViewObject] = []
    
    override func setupView() {
        titleLabel.numberOfLines = 2
        
        setupAgreeAllAreaView()
        addSubviews(titleLabel, agreeAllAreaView, collectionView)
        
        collectionView.dataSource = self
        collectionView
            .register(TermsItemCell.self, forCellWithReuseIdentifier: TermsItemCell.identifier)
    }
    
    override func configure() {
        configure(terms: [
            TermsViewObject(title: "", URL: <#T##URL?#>)
        ])
    }
    
    override func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(LayoutGuide.titleTopInset)
            $0.leading.trailing.equalToSuperview().inset(LayoutGuide.verticalPadding)
        }
        
        checkOnceBox.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(LayoutGuide.innerViewHPadding)
            $0.width.height.equalTo(LayoutGuide.iconSize)
            $0.centerY.equalToSuperview()
        }
        
        agreeAllLabel.snp.makeConstraints {
            $0.leading.equalTo(checkOnceBox.snp.trailing).offset(LayoutGuide.innerViewHPadding)
            $0.top.bottom.equalToSuperview().inset(LayoutGuide.verticalPadding)
        }
        
        agreeAllAreaView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(LayoutGuide.agreeAreaTopInset)
            $0.leading.trailing.equalToSuperview().inset(LayoutGuide.verticalPadding)
            $0.height.equalTo(LayoutGuide.agreeAreaHeight)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(agreeAllAreaView.snp.bottom).offset(LayoutGuide.verticalPadding)
            $0.leading.trailing.equalToSuperview().inset(LayoutGuide.verticalPadding)
        }
        
    }
    
    private func setupAgreeAllAreaView() {
        checkOnceBox.isEnabled = true
        agreeAllLabel.setText(text: "약관 전체동의")
        
        agreeAllAreaView.layer.borderWidth = 1
        agreeAllAreaView.layer.borderColor = UIColor.bkBorderColor(.brand).cgColor
        agreeAllAreaView.layer.cornerRadius = BKRadius.small
        
        agreeAllAreaView.addSubviews(checkOnceBox, agreeAllLabel)
    }
    
    public func configure(terms: [TermsViewObject]) {
        self.terms = terms
        
        collectionView.reloadData()
    }
    
}

private extension TermsView {
    private func createListLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        var config = configuration
        config.showsSeparators = false
        config.backgroundColor = .clear

        let layout = UICollectionViewCompositionalLayout.list(using: config)

        layout.configuration.interSectionSpacing = BKSpacing.spacing3
        return layout
    }
}

extension TermsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return terms.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TermsItemCell.identifier, for: indexPath) as? TermsItemCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(terms[indexPath.item])
        
        return cell
    }
    
}
