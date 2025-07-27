// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

enum TermsViewEvent {
    case agreeAllTapped
    case termTapped(index: Int)
     case showTermDetail(url: URL)
     case startButtonTapped
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
    
    let events = PassthroughSubject<TermsViewEvent, Never>()
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Term>!
    
    private let titleLabel = BKLabel(
        text: "약관 동의 후\n독서 기록을 남겨보세요",
        fontStyle: .title2(weight: .semiBold),
        alignment: .left
    )
    
    private let agreeAllAreaView = UIView()
    private let checkOnceBox = BKCheckBox(
        frame: .zero,
        type: .rectangle
    )
    
    private let agreeAllLabel = BKLabel(
        fontStyle: .headline1(weight: .semiBold),
        alignment: .left
    )
    
    private lazy var collectionView: UICollectionView = {
        let layout = createListLayout()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsSelection = false
        collectionView.isScrollEnabled = false
        
        collectionView.contentInset.left = BKSpacing.spacing2
        collectionView.contentInset.right = BKSpacing.spacing3
        
        return collectionView
    }()
    
    private let startButton = BKButton.primary(title: "시작하기", size: .large)
    
    override func setupView() {
        titleLabel.numberOfLines = 2
        
        setupAgreeAllAreaView()
        addSubviews(titleLabel, agreeAllAreaView, collectionView, startButton)
        
        startButton.isDisabled = true
        
        configureDataSource()
        setupActions()
    }
    
    override func configure() {
        
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
            $0.height.equalTo(156)
        }
        
        startButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(LayoutGuide.verticalPadding)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(LayoutGuide.innerViewHPadding)
        }
    }
    
    func update(with state: TermsViewModel.State) {
        checkOnceBox.isChecked = state.isAllAgreed
        startButton.isDisabled = !state.isStartButtonEnabled
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Term>()
        snapshot.appendSections([0])
        snapshot.appendItems(state.terms, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupActions() {
        let agreeAllTap = UITapGestureRecognizer(target: self, action: #selector(agreeAllAreaTapped))
        agreeAllAreaView.addGestureRecognizer(agreeAllTap)
        
         startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    @objc private func agreeAllAreaTapped() {
        events.send(.agreeAllTapped)
    }
    
    private func setupAgreeAllAreaView() {
        checkOnceBox.isEnabled = true
        agreeAllLabel.setText(text: "약관 전체동의")
        
        agreeAllAreaView.layer.borderWidth = 1
        agreeAllAreaView.layer.borderColor = UIColor.bkBorderColor(.brand).cgColor
        agreeAllAreaView.layer.cornerRadius = BKRadius.small
        
        agreeAllAreaView.addSubviews(checkOnceBox, agreeAllLabel)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<TermsItemCell, Term> { (cell, indexPath, term) in
            cell.configure(term)
            
            cell.onCheckTapped = { [weak self] in
                self?.events.send(.termTapped(index: indexPath.item))
            }
            
            cell.onDetailTapped = { [weak self] in
                if let url = term.url {
                    self?.events.send(.showTermDetail(url: url))
                }
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Term>(collectionView: collectionView) {
            (collectionView, indexPath, term) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: term)
        }
    }
    
    @objc private func startButtonTapped() {
        events.send(.startButtonTapped)
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
