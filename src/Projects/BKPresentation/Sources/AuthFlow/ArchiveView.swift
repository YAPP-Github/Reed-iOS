// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

enum ArchiveViewEvent {
    case chipTapped(index: Int)
    case bookTapped(book: ArchiveBook)
}

final class ArchiveView: BaseView {
    typealias ArchiveResultCell = SearchResultCell
    
    enum Section: Int, CaseIterable {
        case chips
        case books
        case empty
    }
    
    enum Item: Hashable {
        case chip(ChipData)
        case book(ArchiveBook)
        case empty
    }
    
    private var eventPublisher = PassthroughSubject<ArchiveViewEvent, Never>()
    var events: AnyPublisher<ArchiveViewEvent, Never> {
        eventPublisher.eraseToAnyPublisher()
    }
    
    private lazy var collectionView: UICollectionView = {
        return setupCollectionView()
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Item> = {
        return setupDataSource()
    }()
    
    private let emptyStateView: UIView = {
        let containerView = UIView()
        
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
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
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
    
    override func setupView() {
        super.setupView()
        addSubviews(collectionView, emptyStateView)
        setupConstraints()
        registerCells()
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emptyStateView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emptyStateView.isHidden = true
    }
    
    private func registerCells() {
        collectionView.register(
            BKChipCollectionViewCell.self,
            forCellWithReuseIdentifier: BKChipCollectionViewCell.identifier
        )
        collectionView.register(
            ArchiveResultCell.self,
            forCellWithReuseIdentifier: ArchiveResultCell.identifier
        )
    }
    
    private func setupCollectionView() -> UICollectionView {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.bkBaseColor(.primary)
        collectionView.delegate = self
        return collectionView
    }
    
    func updateData(chips: [ChipData], books: [ArchiveBook]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        snapshot.appendSections([.chips])
        snapshot.appendItems(chips.map { .chip($0) }, toSection: .chips)
        
        if books.isEmpty {
            snapshot.appendSections([.empty])
            snapshot.appendItems([.empty], toSection: .empty)
            emptyStateView.isHidden = false
        } else {
            snapshot.appendSections([.books])
            snapshot.appendItems(books.map { .book($0) }, toSection: .books)
            emptyStateView.isHidden = true
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

private extension ArchiveView {
    /// 전체 레이아웃 분기 처리
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .chips:
                return self.createChipSection()
            case .books:
                return self.createBookListSection()
            case .empty:
                return self.createEmptySection()
            }
        }
    }
    
    private func createChipSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(60),
            heightDimension: .absolute(36)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(36) // fractionHeight(1.0) ?
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(ArchiveLayoutGuide.chipSpacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = ArchiveLayoutGuide.chipSectionInset
        
        return section
    }
    
    private func createBookListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(132)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(132)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func createEmptySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(300)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(300)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    /// 데이터 소스 관리
    private func setupDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        return UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            switch item {
            case .chip(let chipData):
                return self?.configureChipCell(collectionView, indexPath, chipData)
            case .book(let book):
                return self?.configureBookCell(collectionView, indexPath, book)
            case .empty:
                return self?.configureEmptyCell(collectionView, indexPath)
            }
        }
    }
    
    private func configureChipCell(
        _ collectionView: UICollectionView,
        _ indexPath: IndexPath,
        _ chipData: ChipData
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BKChipCollectionViewCell.identifier,
            for: indexPath
        ) as! BKChipCollectionViewCell
        
        cell.configure(with: chipData)
        return cell
    }
    
    private func configureBookCell(
        _ collectionView: UICollectionView,
        _ indexPath: IndexPath,
        _ bookData: ArchiveBook
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ArchiveResultCell.archiveReuseIdentifier,
            for: indexPath
        ) as! ArchiveResultCell
        
        cell.configureWithRecord(
            title: bookData.title,
            description: .init(
                author: bookData.author,
                publisher: bookData.publisher
            ),
            image: bookData.imageURL,
            recordCount: bookData.recordCount
        )
        
        return cell
    }
    
    private func configureEmptyCell(
        _ collectionView: UICollectionView,
        _ indexPath: IndexPath
    ) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
}


extension ArchiveView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .chip:
            eventPublisher.send(.chipTapped(index: indexPath.item))
        case .book(let book):
            eventPublisher.send(.bookTapped(book: book))
        case .empty:
            break
        }
    }
}

// MARK: - Layout Metrics
enum ArchiveLayoutGuide {
    static let chipSpacing: CGFloat = BKSpacing.spacing2
    static let chipSectionInset = NSDirectionalEdgeInsets(
        top: BKSpacing.spacing3,
        leading: BKSpacing.spacing5,
        bottom: BKSpacing.spacing3,
        trailing: BKSpacing.spacing5
    )
}
