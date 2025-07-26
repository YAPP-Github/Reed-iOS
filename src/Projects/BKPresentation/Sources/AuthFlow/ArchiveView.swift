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

struct ArchiveBook {
    let title: String
    let author: String
    let publisher: String
    let imageURL: URL?
    let recordCount: Int
}

struct ChipData {
    let title: String
    let count: Int
    var isSelected: Bool = false
}

final class ArchiveView: BaseView {
    typealias ArchiveResultCell = SearchResultCell
    // MARK: - Layout Metrics
    enum LayoutGuide {
    }
    
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
            fontStyle: .headline2(weight: .semiBold),
            color: .bkContentColor(.primary),
            alignment: .center
        )
        
        let descriptionLabel = BKLabel(
            text: "도서 등록 후 나만의 아카이브를 만들어보세요",
            fontStyle: .body2(weight: .regular),
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
            $0.horizontalEdges.equalToSuperview().inset(BKSpacing.spacing4)
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
    
}

final class BKChipCollectionViewCell: UICollectionViewCell {
    static let identifier = "BKChipCollectionViewCell"
    
    private let chip =
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(chip)
        chip.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(with data: ChipData) {
        chip.title = data.title
        chip.count = data.count
        chip.isSelected = data.isSelected
    }
}
