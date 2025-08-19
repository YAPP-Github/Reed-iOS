// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

enum Section {
    case main
}

struct BookDetailItem: Hashable {
    let id: String // book id임
    let recordId: String
    let note: String
    let emotion: EmotionSeed?
    let createdAt: Date
    let page: Int
    
    static func from(recordInfo: RecordInfo) -> Self {
        return Self(
            id: recordInfo.bookId,
            recordId: recordInfo.recordId,
            note: recordInfo.quote,
            emotion: EmotionSeed.from(emotion: recordInfo.emotionTags.first ?? .joy),
            createdAt: recordInfo.createdAt,
            page: recordInfo.pageNumber
        )
    }
}

enum SortOption: String, CaseIterable {
    case newest = "최신 등록순"
    case pageDescending = "페이지순"
    
    var sortingFunction: (BookDetailItem, BookDetailItem) -> Bool {
        switch self {
        case .newest:
            return { $0.createdAt > $1.createdAt }
        case .pageDescending:
            return { $0.page > $1.page }
        }
    }
}

final class BookDetailView: BaseView {
    let eventPublisher = PassthroughSubject<BookDetailViewEvent, Never>()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private var collectionViewHeightConstraint: Constraint?

    private let summaryView = BKBookSummaryView(style: .big)
    private let buttonGroup: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = LayoutConstants.buttonGroupSpacing
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()

    private var readingStateButton: BKButton = {
        let button = BKButton(style: .secondary, size: .medium)
        button.rightIcon = BKImage.Icon.chevronDown
        button.title = "초기 값"
        
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()

    private let addNoteButton: BKButton = {
        let button = BKButton()
        button.title = "독서 기록 추가"
        
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return button
    }()

    private let seedReportView = SeedReportView()
    private let divider = BKDivider(type: .medium)
    private let header = BookDetailViewHeader()

    private lazy var collectionView: UICollectionView = {
        return setupCollectionView()
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, BookDetailItem> = {
        return setupDataSource()
    }()
    
    private let emptyContainerView = UIView()
    private let emptyLabel: BKLabel = {
        let label = BKLabel(
            fontStyle: .body1(weight: .medium),
            color: .bkContentColor(.secondary),
            alignment: .center
        )
        label.numberOfLines = .zero
        label.setText(text: """
        첫 기록을 남겨 보세요!
        나만의 아카이브를 만들 수 있어요.
        """)
        return label
    }()
    
    private var currentSortOption: SortOption = .pageDescending

    override func setupView() {
        addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubviews(
            summaryView,
            buttonGroup,
            seedReportView,
            divider,
            header,
            collectionView,
            emptyContainerView
        )
        emptyContainerView.addSubview(emptyLabel)
        [readingStateButton, addNoteButton].forEach(buttonGroup.addArrangedSubview)
    }
    
    override func configure() {
        readingStateButton.addTarget(self, action: #selector(readingStateButtonTapped), for: .touchUpInside)
        header.onTapSortButton = { [weak self] in
            self?.eventPublisher.send(.didTapSortMenuButton(self?.currentSortOption))
        }
        addNoteButton.addTarget(self, action: #selector(addNoteButtonTapped), for: .touchUpInside)
    }

    override func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        summaryView.snp.makeConstraints {
            $0.top.equalToSuperview()
                .inset(LayoutConstants.summaryViewTopInset)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(LayoutConstants.summaryViewHeight)
        }

        buttonGroup.snp.makeConstraints {
            $0.top.equalTo(summaryView.snp.bottom)
                .offset(LayoutConstants.buttonGroupTopInset)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }

        seedReportView.snp.makeConstraints {
            $0.top.equalTo(buttonGroup.snp.bottom)
                .offset(LayoutConstants.seedReportViewTopInset)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }

        divider.snp.makeConstraints {
            $0.top.equalTo(seedReportView.snp.bottom)
                .offset(LayoutConstants.dividerVerticalOffset)
            $0.horizontalEdges.equalToSuperview()
        }
        
        header.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
                .offset(LayoutConstants.dividerVerticalOffset)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom)
                .offset(LayoutConstants.collectionViewTopOffset)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            collectionViewHeightConstraint = $0.height.equalTo(0).constraint
            $0.bottom.equalToSuperview()
        }
        
        emptyContainerView.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(LayoutConstants.dividerVerticalOffset)
            $0.horizontalEdges.equalToSuperview().inset(LayoutConstants.horizontalInset)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }

        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func applySnapshot(
        with items: [BookDetailItem],
        totalCount: Int,
        animating: Bool = true
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, BookDetailItem>()
        let sortedItems = items.sorted(by: currentSortOption.sortingFunction)
        snapshot.appendSections([.main])
        
        let isEmpty = sortedItems.isEmpty
        collectionView.isHidden = isEmpty
        emptyContainerView.isHidden = !isEmpty
        
        if !isEmpty {
            snapshot.appendItems(sortedItems, toSection: .main)
        }
        
        header.applyHeaderTitle(count: totalCount)
        dataSource.apply(snapshot, animatingDifferences: animating) { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            self.collectionViewHeightConstraint?.update(offset:
                self.collectionView.collectionViewLayout.collectionViewContentSize.height
            )
        }
    }
    
    func applySeedReport(with seeds: [Seed]) {
        seedReportView.applyReport(with: seeds)
    }
    
    func applySort(option: SortOption) {
        var snapshot = dataSource.snapshot()
        let currentItems = snapshot.itemIdentifiers(inSection: .main)
        let sortedItems = currentItems.sorted(by: option.sortingFunction)
        currentSortOption = option
        
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        snapshot.appendItems(sortedItems, toSection: .main)
        header.applyHeaderState(option)
        
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            self.collectionViewHeightConstraint?.update(offset:
                self.collectionView.collectionViewLayout.collectionViewContentSize.height
            )
        }
    }
    
    func configureInnerView(book: Book) {
        summaryView.configure(
            title: book.title,
            author: book.author,
            publisher: book.publisher,
            extraText: book.pubDate?.toKoreanYearString(),
            image: book.thumbnail
        )

        readingStateButton.title = book.userBookStatus?.displayName
    }
}

private extension BookDetailView {
    func setupCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: makeCollectionViewLayout()
        )
        collectionView.backgroundColor = .bkBaseColor(.primary)
        collectionView.alwaysBounceVertical = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            BookDetailViewCell.self,
            forCellWithReuseIdentifier: BookDetailViewCell.reuseIdentifier
        )
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        return collectionView
    }
    
    func makeCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = LayoutConstants.collectionViewCellSpacing
        layout.sectionInset = .zero
        return layout
    }
    
    func setupDataSource() -> UICollectionViewDiffableDataSource<Section, BookDetailItem> {
        let dataSource = UICollectionViewDiffableDataSource<Section, BookDetailItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BookDetailViewCell.reuseIdentifier,
                for: indexPath
            ) as? BookDetailViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: item)
            return cell
        }
        return dataSource
    }
}

extension BookDetailView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return CGSize(width: width, height: LayoutConstants.collectionViewCellMaxHeight)
        }
        
        let cell = BookDetailViewCell(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        cell.configure(with: item)
        
        let targetSize = CGSize(
            width: width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let fittingSize = cell.contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        return CGSize(width: width, height: fittingSize.height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        eventPublisher.send(.didTapCell(recordId: item.recordId))
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let count = dataSource.snapshot().numberOfItems
        if indexPath.item == count - 1, !dataSource.snapshot().itemIdentifiers.isEmpty {
            eventPublisher.send(.didReachBottom)
        }
    }
}

private extension BookDetailView {
    @objc func readingStateButtonTapped() {
        eventPublisher.send(.didTapStatusButton)
    }
    
    @objc func addNoteButtonTapped() {
        eventPublisher.send(.didTapAddNoteButton)
    }
    
    enum LayoutConstants {
        static let horizontalInset = BKInset.inset5
        static let summaryViewTopInset = BKInset.inset2
        static let summaryViewHeight: CGFloat = 98
        static let buttonGroupSpacing = BKSpacing.spacing2
        static let buttonGroupTopInset = BKInset.inset8
        static let seedReportViewTopInset = BKInset.inset8
        static let dividerVerticalOffset = BKInset.inset6
        static let collectionViewTopOffset = BKInset.inset4
        static let collectionViewCellMaxHeight: CGFloat = 180
        static let collectionViewCellSpacing = BKSpacing.spacing3
    }
}
