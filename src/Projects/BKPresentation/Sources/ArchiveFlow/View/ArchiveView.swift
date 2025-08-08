// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

final class ArchiveView: BaseView, UIGestureRecognizerDelegate {
    private var eventPublisher = PassthroughSubject<ArchiveViewEvent, Never>()
    
    var events: AnyPublisher<ArchiveViewEvent, Never> {
        eventPublisher.eraseToAnyPublisher()
    }
    
    private let chipScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()
    
    private let chipStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = BKSpacing.spacing2
        stackView.alignment = .center
        return stackView
    }()
    
    private let chip1 = BKChip(title: "", count: 0)
    private let chip2 = BKChip(title: "", count: 0)
    private let chip3 = BKChip(title: "", count: 0)
    private let chip4 = BKChip(title: "", count: 0)
    
    private lazy var allChips: [BKChip] = [chip1, chip2, chip3, chip4]
    
    private lazy var bookCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.allowsSelection = true
        collectionView.delaysContentTouches = false
        collectionView.backgroundColor = .bkBaseColor(.primary)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            ArchiveCell.self,
            forCellWithReuseIdentifier: ArchiveCell.identifier
        )
        return collectionView
    }()
    
    private let emptyStateView: UIView = {
        let containerView = UIView()
        containerView.isUserInteractionEnabled = false
        
        let titleLabel = BKLabel(
            text: "아직 등록된 책이 없어요",
            fontStyle: .headline1(weight: .semiBold),
            color: .bkContentColor(.primary),
            alignment: .center
        )
        
        let descriptionLabel = BKLabel(
            text: "도서 등록 후 나만의 아카이브를 만들어보세요",
            fontStyle: .body1(weight: .medium),
            color: .bkContentColor(.secondary),
            alignment: .center
        )
        
        let stackView = UIStackView(
            arrangedSubviews: [titleLabel, descriptionLabel]
        )
        stackView.axis = .vertical
        stackView.spacing = BKSpacing.spacing2
        stackView.alignment = .center
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(BKSpacing.spacing5)
        }
        
        return containerView
    }()
    
    private var books: [ArchiveBook] = [] {
        didSet {
            updateEmptyState()
            bookCollectionView.reloadData()
        }
    }
    
    override func setupView() {
        super.setupView()
        backgroundColor = .bkBaseColor(.primary)
        
        setupChipActions()
        setupScrollView()
        addSubviews(chipScrollView, bookCollectionView, emptyStateView)
        setupLayout()
        updateEmptyState()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCollectionTap(_:)))
        tap.cancelsTouchesInView = false
        tap.delaysTouchesEnded = false
        tap.delegate = self
        bookCollectionView.addGestureRecognizer(tap)

        // didSelect 중복 방지
        bookCollectionView.allowsSelection = false
    }
    
    @objc private func handleCollectionTap(_ gr: UITapGestureRecognizer) {
        let p = gr.location(in: bookCollectionView)
        guard let indexPath = bookCollectionView.indexPathForItem(at: p) else { return }
        let book = books[indexPath.item]
        eventPublisher.send(.bookTapped(book: book))
    }
    
    private func setupChipActions() {
        allChips.enumerated().forEach { index, chip in
            chip.onTap = { [weak self] in
                self?.eventPublisher.send(.chipTapped(index: index))
            }
        }
    }
    
    private func setupScrollView() {
        chipScrollView.addSubview(chipStackView)
        chipStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(ArchiveLayoutGuide.chipViewHeight)
        }
        
        let leadingPadding = UIView()
        let trailingPadding = UIView()
        
        leadingPadding.snp.makeConstraints {
            $0.width
                .equalTo(
                    ArchiveLayoutGuide.chipSectionInset.leading - ArchiveLayoutGuide.chipSpacing
                )
        }
        
        trailingPadding.snp.makeConstraints {
            $0.width
                .equalTo(ArchiveLayoutGuide.chipSectionInset.leading - ArchiveLayoutGuide.chipSpacing)
        }
        
        chipStackView.addArrangedSubview(leadingPadding)
        allChips.forEach { chipStackView.addArrangedSubview($0) }
        chipStackView.addArrangedSubview(trailingPadding)
    }
    
    override func setupLayout() {
        chipScrollView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(BKSpacing.spacing3)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(ArchiveLayoutGuide.chipViewHeight)
        }
        
        bookCollectionView.snp.makeConstraints {
            $0.top.equalTo(chipScrollView.snp.bottom).offset(BKSpacing.spacing3)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        emptyStateView.snp.makeConstraints {
            $0.top.equalTo(chipScrollView.snp.bottom).offset(BKSpacing.spacing3)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func updateData(chips: [ChipData], books: [ArchiveBook]) {
        chips.enumerated().forEach { index, chipData in
            guard index < allChips.count else { return }
            allChips[index].title = chipData.title
            allChips[index].count = chipData.count
            allChips[index].isSelected = chipData.isSelected
        }
        
        self.books = books
    }
    
    private func updateEmptyState() {
        emptyStateView.isHidden = !books.isEmpty
        bookCollectionView.isHidden = books.isEmpty
        
        if books.isEmpty {
            bringSubviewToFront(emptyStateView)
        } else {
            bringSubviewToFront(bookCollectionView)
        }
    }
    
}

extension ArchiveView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ArchiveCell.identifier,
            for: indexPath
        ) as? ArchiveCell else {
            return UICollectionViewCell()
        }
        
        let book = books[indexPath.item]
        cell.configure(
            title: book.title,
            description: .init(
                author: book.author,
                publisher: book.publisher
            ),
            image: book.imageURL,
            recordCount: book.recordCount
        )
        
        cell.onTap = { [weak self] in
            guard let self else { return }
            let book = self.books[indexPath.item]
            self.eventPublisher.send(.bookTapped(book: book))
        }
        
        return cell
    }
    
    enum ArchiveLayoutGuide {
        static let cellHeight: CGFloat = 132
        static let chipSpacing: CGFloat = BKSpacing.spacing2
        static let chipViewHeight: CGFloat = 36
        static let chipSectionInset = NSDirectionalEdgeInsets(
            top: BKSpacing.spacing3,
            leading: BKSpacing.spacing5,
            bottom: BKSpacing.spacing3,
            trailing: BKSpacing.spacing5
        )
    }
}

extension ArchiveView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: ArchiveLayoutGuide.cellHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let book = books[indexPath.item]
        eventPublisher.send(.bookTapped(book: book))
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        print("shouldHighlight \(indexPath)")
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("didHighlight \(indexPath)")
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let section = indexPath.section
        let totalItems = collectionView.numberOfItems(inSection: section)
        if indexPath.item == totalItems - 1 {
            eventPublisher.send(.loadNextPage)
        }
    }
}
