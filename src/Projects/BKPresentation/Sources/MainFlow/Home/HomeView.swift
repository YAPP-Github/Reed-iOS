// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class HomeView: BaseView {
    private let backgroundColorView = UIView()
    
    private let topArea = UIView()
    private let mainTitleLabel = BKLabel(
        text: "문장 기록하고\n씨앗을 모아볼까요?",
        fontStyle: .heading1(weight: .bold),
        color: .bkContentColor(.primary),
        alignment: .left
    )
    
    private let searchButton = GoToSearchView()
    var searchButtonView: GoToSearchView {
        return searchButton
    }
    
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
        collectionView.register(HomeCardCell.self, forCellWithReuseIdentifier: HomeCardCell.reuseIdentifier)
        
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
    
    override func setupView() {
        // 상단 배경 색상
        backgroundColorView.backgroundColor = UIColor(hex: "F0F9E8")
        
        mainTitleLabel.numberOfLines = 2
    }
    
    override func setupLayout() {
        addSubviews(
            backgroundColorView,
            topArea,
            bookSectionTitleLabel,
            bookCollectionView,
            pageControl
        )
        topArea.addSubviews(mainTitleLabel, searchButton, graphicImageView)
        
        backgroundColorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(259)
        }
        
        topArea.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).inset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(160)
        }
        
        mainTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        searchButton.snp.makeConstraints {
            $0.top.equalTo(mainTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
        }
        
        graphicImageView.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(mainTitleLabel.snp.trailing).offset(20)
        }
        
        // 읽고 있는 책부터 레이아웃 정의
        bookSectionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(graphicImageView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        bookCollectionView.snp.makeConstraints {
            $0.top.equalTo(bookSectionTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(330)
        }
        
        pageControl.snp.makeConstraints {
            $0.top.equalTo(bookCollectionView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(6)
        }
    }
    
}
