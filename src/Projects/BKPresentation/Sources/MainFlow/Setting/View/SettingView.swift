// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import SnapKit
import UIKit

final class SettingView: BaseView {
    let eventPublisher = PassthroughSubject<SettingViewEvent, Never>()
    
    private lazy var collectionView: UICollectionView = {
        return makeCollectionView()
    }()
    
    private enum Section: Int, CaseIterable {
        case top
        case bottom
    }
    
    private var firstMenus: [FirstMenuItem] = []
    private var secondMenus: [SecondMenuItem] = []
    private var appVersion: String = ""

    override func setupView() {
        addSubview(collectionView)
    }
    
    override func configure() {
        configureCollectionView()
    }
    
    override func setupLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func apply(
        firstMenus: [FirstMenuItem],
        secondMenus: [SecondMenuItem]
    ) {
        self.firstMenus = firstMenus
        self.secondMenus = secondMenus
        collectionView.reloadData()
    }
    
    func setAppVersion(_ appVersion: String) {
        self.appVersion = appVersion
        collectionView.reloadData()
    }
}

private extension SettingView {
    func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, env in
            var cfg = UICollectionLayoutListConfiguration(appearance: .plain)
            cfg.footerMode      = sectionIndex == 0 ? .supplementary : .none
            cfg.showsSeparators = false
            let section = NSCollectionLayoutSection.list(using: cfg, layoutEnvironment: env)
            section.contentInsets = .init(
                top: BKInset.inset4,
                leading: 0,
                bottom: BKInset.inset4,
                trailing: 0
            )
            return section
        }
    }

    func makeCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: makeLayout()
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return collectionView
    }

    func configureCollectionView() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(
            SettingCell.self,
            forCellWithReuseIdentifier: SettingCell.identifier
        )
        collectionView.register(
            BKDividerFooterView.self,
            forSupplementaryViewOfKind: BKDividerFooterView.kind,
            withReuseIdentifier: BKDividerFooterView.identifier
        )
    }
}

extension SettingView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if indexPath.section == Section.bottom.rawValue {
            if indexPath.item == Section.top.rawValue {
                eventPublisher.send(.logoutButtonTapped)
            } else if indexPath.item == Section.bottom.rawValue {
                eventPublisher.send(.withdrawalButtonTapped)
            }
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        switch (indexPath.section, indexPath.item) {
        case (0, 3):
            return false
        default:
            return true
        }
    }
}

extension SettingView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return section == Section.top.rawValue
            ? firstMenus.count
            : secondMenus.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingCell.identifier,
            for: indexPath
        ) as? SettingCell else {
            return UICollectionViewCell()
        }

        let title: String = indexPath.section == Section.top.rawValue
            ? firstMenus[indexPath.item].title
            : secondMenus[indexPath.item].title
        
        switch (indexPath.section, indexPath.item) {
        case (Section.top.rawValue, FirstMenuItem.allCases.count - 1):
            cell.configure(title: title, style: .label, appVersion: appVersion)
        case (Section.bottom.rawValue, _):
            cell.configure(title: title, style: .none)
        default:
            cell.configure(title: title, style: .chevron)
        }
        
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: BKDividerFooterView.identifier,
            for: indexPath
        )

        footer.isHidden = indexPath.section != Section.top.rawValue
        return footer
    }
}
