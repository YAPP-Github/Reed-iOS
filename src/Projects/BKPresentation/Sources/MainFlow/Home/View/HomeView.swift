// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import SnapKit
import UIKit

final class HomeView: BaseView {
    let eventPublisher = PassthroughSubject<HomeViewEvent, Never>()
    private var cancellable: Set<AnyCancellable> = []
    
    private var books: [HomeBookInfo] = []
    private let backgroundColorView = UIView()
    
    private let topArea = UIView()
    private let mainTitleLabel = BKLabel(
        text: """
        문장 기록하고
        씨앗을 모아볼까요?
        """,
        fontStyle: .heading1(weight: .bold),
        color: .bkContentColor(.primary),
        alignment: .left
    )
    
    private let searchButton = BookSearchEntryView()
    private let graphicImageView = UIImageView(image: BKImage.Graphics.homeChar)
    private let bookSectionTitleLabel = BKLabel(
        text: "요즘 읽는 책",
        fontStyle: .headline2(weight: .medium),
        color: .bkContentColor(.secondary),
        alignment: .left
    )
    
    private lazy var bookCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(
            HomeCardCell.self,
            forCellWithReuseIdentifier: HomeCardCell.reuseIdentifier
        )
        
        return collectionView
    }()
        
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .bkBackgroundColor(.secondaryPressed)
        pageControl.currentPageIndicatorTintColor = .bkBackgroundColor(.primary)
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    var collectionView: UICollectionView {
        return bookCollectionView
    }
    
    var pageControlView: UIPageControl {
        return pageControl
    }
    
    private let homeEmptyView = HomeEmptyView()
    
    override func setupView() {
        addSubviews(
            backgroundColorView,
            topArea,
            bookSectionTitleLabel,
            bookCollectionView,
            pageControl,
            homeEmptyView
        )
        topArea.addSubviews(mainTitleLabel, searchButton, graphicImageView)
    }
    
    override func configure() {
        backgroundColorView.backgroundColor = UIColor(hex: "F0F9E8")
        mainTitleLabel.numberOfLines = 2
        bookCollectionView.dataSource = self
        bookCollectionView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchButtonTapped))
        searchButton.isUserInteractionEnabled = true
        graphicImageView.isUserInteractionEnabled = false
        searchButton.addGestureRecognizer(tapGesture)
        
        homeEmptyView.buttonTapped
            .sink { [weak self] in
                self?.eventPublisher.send(.didTapEmptyBook)
            }
            .store(in: &cancellable)
    }
    
    override func setupLayout() {
        backgroundColorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(LayoutConstants.backgroundHeight)
        }
        
        topArea.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
                .inset(LayoutConstants.topAreaTopInset)
            $0.leading.equalToSuperview()
                .offset(LayoutConstants.topAreaLeading)
            $0.trailing.equalToSuperview()
                .offset(-LayoutConstants.topAreaTrailing)
            $0.height.equalTo(LayoutConstants.topAreaHeight)
        }
        
        mainTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        searchButton.snp.makeConstraints {
            $0.top.equalTo(mainTitleLabel.snp.bottom)
                .offset(LayoutConstants.titleToSearchButtonSpacing)
            $0.leading.equalToSuperview()
        }
        
        graphicImageView.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(mainTitleLabel.snp.trailing)
                .offset(LayoutConstants.titleToGraphicSpacing)
        }
        
        bookSectionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(graphicImageView.snp.bottom)
                .offset(LayoutConstants.sectionTitleTopSpacing)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.sectionTitleHorizontalInset)
        }
        
        bookCollectionView.snp.makeConstraints {
            $0.top.equalTo(bookSectionTitleLabel.snp.bottom)
                .offset(LayoutConstants.collectionTopSpacing)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(LayoutConstants.collectionHeight)
        }
        
        homeEmptyView.snp.makeConstraints {
            $0.top.equalTo(bookSectionTitleLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(LayoutConstants.collectionHeight + LayoutConstants.collectionTopSpacing)
        }
        
        pageControl.snp.makeConstraints {
            $0.top.equalTo(bookCollectionView.snp.bottom)
                .offset(LayoutConstants.pageControlTopSpacing)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(LayoutConstants.pageControlHeight)
        }
    }
    
    func updateBooks(_ books: [HomeBookInfo]) {
        self.books = books
        pageControl.numberOfPages = books.count
        collectionView.reloadData()
        homeEmptyView.isHidden = !books.isEmpty
    }
}

extension HomeView: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return books.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeCardCell.reuseIdentifier,
            for: indexPath
        ) as? HomeCardCell else {
            return UICollectionViewCell()
        }
        
        let book = books[indexPath.item]
        cell.configure(
            title: book.title,
            author: book.author,
            publisher: book.publisher,
            recordCount: book.recordCount,
            image: book.coverImageUrl,
            onNoteButtonTapped: { [weak self] in
                self?.eventPublisher.send(.didTapRecordButton(book.userBookId))
            }
        )
        
        return cell
    }
}

extension HomeView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.frame.width - LayoutConstants.cellWidthOffset
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 0,
            left: LayoutConstants.horizontalInset,
            bottom: 0,
            right: LayoutConstants.horizontalInset
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return LayoutConstants.minimumLineSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let selectedBook = books[indexPath.item]
        eventPublisher.send(.didTapBook(isbn: "9791193737330", userBookId: selectedBook.userBookId))
    }
}

extension HomeView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let pageWidth = scrollView.frame.width
            let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
            pageControlView.currentPage = currentPage
        }
    }
}

private extension HomeView {
    @objc func searchButtonTapped() {
        eventPublisher.send(.didTapSearchButton)
    }
}

private extension HomeView {
    enum LayoutConstants {
        static let backgroundHeight: CGFloat = 259
        static let topAreaTopInset: CGFloat = 16
        static let topAreaLeading: CGFloat = 24
        static let topAreaTrailing: CGFloat = 20
        static let topAreaHeight: CGFloat = 160

        static let titleToSearchButtonSpacing: CGFloat = 12
        static let titleToGraphicSpacing: CGFloat = 20

        static let sectionTitleTopSpacing: CGFloat = 24
        static let sectionTitleHorizontalInset: CGFloat = 20

        static let collectionTopSpacing: CGFloat = 12
        static let collectionHeight: CGFloat = 330

        static let pageControlTopSpacing: CGFloat = 20
        static let pageControlHeight: CGFloat = 6
        
        static let horizontalInset: CGFloat = 20
        static let minimumLineSpacing: CGFloat = 40
        static let cellWidthOffset: CGFloat = horizontalInset * 2
    }
}
