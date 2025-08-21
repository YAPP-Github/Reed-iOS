// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

final class SearchView: BaseView {
    enum CollectionLayoutMode {
        case beforeSearch
        case afterSearch
    }
    
    enum SearchSection: Hashable {
        case recent
        case result
    }
    
    let eventPublisher = PassthroughSubject<SearchViewEvent, Never>()
    
    private let searchBar = BKSearchTextField(
        placeholder: "도서 검색 후 내 서재에 담아보세요.",
        type: .normal
    )
    
    private let divider = BKDivider(type: .medium)
    private let header = SearchSectionHeaderView()
    
    private lazy var collectionView: UICollectionView = {
        return setupCollectionView()
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<SearchSection, SearchItem> = {
        return setupDataSource()
    }()
    
    private var layoutMode = CollectionLayoutMode.beforeSearch
    
    override func setupView() {
        addSubviews(searchBar, divider, header, collectionView)
    }
    
    override func configure() {
        searchBar.setOnReturn { [weak self] text in
            self?.eventPublisher.send(.search(text))
        }
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
    
    func setSearchBarPlaceholder(with placeholder: String) {
        searchBar.placeholder = placeholder
    }
    
    func setSearchBarText(with text: String) {
        searchBar.text = text
    }
    
    func applySnapshot(
        with state: SearchViewModel.SearchState,
        count: Int = 0
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>()
        
        switch state {
        case .recent(let state):
            if state.queries.isEmpty {
                collectionView.backgroundView = makeEmptyLabel(state.placeholder)
            } else {
                collectionView.backgroundView = nil
                header.setTitle(.recent)
                snapshot.appendSections([.recent])
                snapshot.appendItems(state.queries.map { .query($0) }, toSection: .recent)
            }
            
        case .result(let state):
            let isEmpty = state.books.isEmpty && state.bookInfos.isEmpty
            if isEmpty {
                header.layoutIfNeeded()
                let headerHeight = header.bounds.height
                let offset = -(headerHeight / 2.0)
                collectionView.backgroundView = makeEmptyLabel(state.placeholder, verticalOffset: offset)
                searchBar.setClearButtonMode(.whileEditing)
            } else {
                collectionView.backgroundView = nil
                snapshot.appendSections([.result])
                // Book과 BookInfo 모두 처리
                snapshot.appendItems(state.books.map { .result($0) }, toSection: .result)
                snapshot.appendItems(state.bookInfos.map { .libraryResult($0) }, toSection: .result)
                searchBar.setClearButtonMode(.always)
            }
            header.setTitle(.result(count: count))
            layoutMode = .afterSearch
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

private extension SearchView {
    func setupCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .bkBaseColor(.primary)
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = false
        collectionView.register(RecentKeywordCell.self, forCellWithReuseIdentifier: RecentKeywordCell.identifier)
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.identifier)
        
        return collectionView
    }

    func setupDataSource() -> UICollectionViewDiffableDataSource<SearchSection, SearchItem> {
        let dataSource = UICollectionViewDiffableDataSource<SearchSection, SearchItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case .query(let keyword):
                return self.makeRecentKeywordCell(in: collectionView, at: indexPath, keyword: keyword)
            case .result(let result):
                return self.makeSearchResultCell(in: collectionView, at: indexPath, book: result)
            case .libraryResult(let bookInfo):
                return self.makeLibraryResultCell(in: collectionView, at: indexPath, bookInfo: bookInfo)
            }
        }
        
        return dataSource
    }
    
    func makeRecentKeywordCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        keyword: String
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecentKeywordCell.identifier,
            for: indexPath
        ) as? RecentKeywordCell else {
            return UICollectionViewCell()
        }
        cell.configure(labelText: keyword)
        
        cell.onDeleteTapped = { [weak self] in
            self?.eventPublisher.send(.deleteRecentQuery(keyword))
        }
        cell.onQueryLabelTapped = { [weak self] in
            self?.eventPublisher.send(.search(keyword))
            self?.setSearchBarText(with: keyword)
        }
        
        return cell
    }
    
    func makeSearchResultCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        book: Book
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchResultCell.identifier,
            for: indexPath
        ) as? SearchResultCell else {
            return UICollectionViewCell()
        }
        
        switch book.userBookStatus {
        case .beforeRegistration, nil:
            cell.configure(
                title: book.title,
                description: .init(
                    author: book.author,
                    publisher: book.publisher
                ),
                image: book.thumbnail,
                canSelect: true,
                recordCount: book.recordCount
            )
            
        default:
            cell.configure(
                title: book.title,
                description: .init(
                    author: book.author,
                    publisher: book.publisher
                ),
                image: book.thumbnail,
                canSelect: false,
                recordCount: book.recordCount
            )
        }

        return cell
    }
    
    func makeLibraryResultCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        bookInfo: BookInfo
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchResultCell.identifier,
            for: indexPath
        ) as? SearchResultCell else {
            return UICollectionViewCell()
        }
        
        // BookInfo는 내 서재 도서 - 터치 가능하고 recordCount가 있으면 .record 스타일
        cell.configure(
            title: bookInfo.title,
            description: .init(
                author: bookInfo.author,
                publisher: bookInfo.publisher
            ),
            image: bookInfo.imageUrl,
            canSelect: true,
            recordCount: bookInfo.recordCount,
            isLibraryBook: true
        )

        return cell
    }

    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = .zero
        layout.sectionInset = .zero
        return layout
    }

    func makeEmptyLabel(
        _ text: String,
        verticalOffset: CGFloat = 0
    ) -> UIView {
        let container = UIView()
        container.backgroundColor = .bkBaseColor(.primary)

        let label = UILabel()
        label.text = text
        label.textColor = .bkContentColor(.secondary)
        label.textAlignment = .center

        container.addSubview(label)
        label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(verticalOffset)
        }

        return container
    }
    
    @objc func searchButtonTapped() {
        guard let text = searchBar.text, !text.isEmpty else { return }
        eventPublisher.send(.search(text))
    }
}

extension SearchView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        switch layoutMode {
        case .beforeSearch:
            return CGSize(
                width: collectionView.bounds.width,
                height: LayoutConstants.recentItemHeight
            )
        case .afterSearch:
            return CGSize(
                width: collectionView.bounds.width,
                height: LayoutConstants.resultItemHeight
            )
        }
    }
}

extension SearchView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard layoutMode == .afterSearch else { return }
        let section = indexPath.section
        let totalItems = collectionView.numberOfItems(inSection: section)
        if indexPath.item == totalItems - 1 {
            eventPublisher.send(.loadNextPage)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .result(let book):
            switch book.userBookStatus {
            case .beforeRegistration, nil:
                eventPublisher.send(.upsertBook(book.isbn))
            default:
                break
            }
            
        case .libraryResult(let bookInfo):
            eventPublisher.send(.goToBookDetail(isbn: bookInfo.isbn, userBookId: bookInfo.bookId))
            
        case .query: break
        }
    }
}

private extension SearchView {
    enum LayoutConstants {
        static let searchBarInset = BKInset.inset3
        static let dividerOffset = BKInset.inset2
        static let horizontalInset = BKInset.inset5
        static let headerOffset = BKInset.inset1
        static let recentItemHeight: CGFloat = 56
        static let resultItemHeight: CGFloat = 132
    }
}
