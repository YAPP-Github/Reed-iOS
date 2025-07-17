// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import SnapKit
import UIKit

final class SearchView: BaseView {
    let eventPublisher = PassthroughSubject<SearchViewEvent, Never>()
    
    private let searchBar = BKSearchTextField(
        placeholder: "도서 검색 후 내 서재에 담아보세요.",
        type: .brand
    )
    
    private let divider = BKDivider(type: .medium)
    private let header = SearchSectionHeaderView()
    
    private lazy var collectionView: UICollectionView = {
        return setupCollectionView()
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<SearchSection, SearchItem> = {
        return setupDataSource()
    }()
    
    enum SearchSection: Hashable {
        case recent
        case result
    }
    
    override func setupView() {
        addSubviews(searchBar, divider, header, collectionView)
    }
    
    override func setupLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
                .inset(LayoutConstants.searchBarInset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
                .offset(LayoutConstants.searchBarInset + LayoutConstants.dividerOffset)
            $0.trailing.leading.equalToSuperview()
        }
        
        header.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
                .offset(LayoutConstants.dividerOffset)
            $0.leading.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom)
                .offset(LayoutConstants.headerOffset)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func applySnapshot(with state: SearchViewModel.State) {
        var snapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>()
        
        switch state.searchState {
        case .recent(let keywords):
            if keywords.isEmpty {
                collectionView.backgroundView = makeEmptyLabel("최근 검색어 내역이 없습니다.")
            } else {
                collectionView.backgroundView = nil
                header.setTitle(.recent)
                snapshot.appendSections([.recent])
                snapshot.appendItems(keywords.map { .keyword($0) }, toSection: .recent)
            }
            
        case .result(let results):
            if results.isEmpty {
                collectionView.backgroundView = makeEmptyLabel("검색어와 일치하는 도서가 없습니다.")
            } else {
                collectionView.backgroundView = nil
                header.setTitle(.result(count: results.count))
                snapshot.appendSections([.result])
                snapshot.appendItems(results.map { .result($0) }, toSection: .result)
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

private extension SearchView {
    func setupCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(RecentKeywordCell.self, forCellWithReuseIdentifier: RecentKeywordCell.identifier)
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.identifier)
        
        return collectionView
    }

    func setupDataSource() -> UICollectionViewDiffableDataSource<SearchSection, SearchItem> {
        let dataSource = UICollectionViewDiffableDataSource<SearchSection, SearchItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case .keyword(let keyword):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecentKeywordCell.identifier,
                    for: indexPath
                ) as? RecentKeywordCell else {
                    return UICollectionViewCell()
                }
                cell.configure(labelText: keyword)
                return cell
            case .result(let result):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SearchResultCell.identifier,
                    for: indexPath
                ) as? SearchResultCell else {
                    return UICollectionViewCell()
                }
                cell.configure(title: result.title, description: result.description, image: result.thumbnail)
                return cell
            }
        }
        
        return dataSource
    }

    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = .zero
        layout.sectionInset = .zero
        return layout
    }

    func makeEmptyLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }
}

private extension SearchView {
    enum LayoutConstants {
        static let searchBarInset = BKInset.inset3
        static let dividerOffset = BKInset.inset2
        static let horizontalInset = BKInset.inset5
        static let headerOffset = BKInset.inset1
    }
}
