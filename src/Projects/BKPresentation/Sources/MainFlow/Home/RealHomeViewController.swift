// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import UIKit

final class RealHomeViewController: BaseViewController<HomeView> {
    weak var coordinator: MainFlowCoordinator?
    private var cancellables = Set<AnyCancellable>()
    
    // 샘플 데이터
    private let sampleBooks: [BookInfo] = [
        BookInfo(
            bookId: "01986174-8b41-737b-a158-d46b1a5af478",
            isbn: "K972030963",
            title: "몸, 내 안의 우주 - 응급의학과 의사가 들려주는 의학교양",
            author: "남궁인",
            status: .reading,
            imageUrl: URL(string: "https://image.aladin.co.kr/product/36617/34/cover500/k972030963_1.jpg"),
            publisher: "문학동네",
            createdAt: nil,
            updatedAt: nil
        ),
        BookInfo(
            bookId: "01986174-8b41-737b-a158-d46b1a5af478",
            isbn: "K972030963",
            title: "몸2",
            author: "남궁인",
            status: .reading,
            imageUrl: URL(string: "https://image.aladin.co.kr/product/36617/34/cover500/k972030963_1.jpg"),
            publisher: "문학동네",
            createdAt: nil,
            updatedAt: nil
        ),
        BookInfo(
            bookId: "01986174-8b41-737b-a158-d46b1a5af478",
            isbn: "K972030963",
            title: "몸3",
            author: "남궁인",
            status: .reading,
            imageUrl: URL(string: "https://image.aladin.co.kr/product/36617/34/cover500/k972030963_1.jpg"),
            publisher: "문학동네",
            createdAt: nil,
            updatedAt: nil
        )
    ]
    
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        .home(
            viewController: self,
            target: self,
            gearAction: #selector(goToSettingViewController)
        )
    }
    
    override var bkNavigationTitle: String {
        return "Reed"
    }
    
    override init() {
        super.init()
    }
    
    @objc private func goToSettingViewController() {
        coordinator?.didTapSettingButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
//        setupTapGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
        
    private func setupCollectionView() {
        contentView.collectionView.dataSource = self
        contentView.collectionView.delegate = self
        
        contentView.pageControlView.numberOfPages = sampleBooks.count
    }

}

// MARK: - UICollectionViewDataSource
extension RealHomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sampleBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeCardCell.reuseIdentifier,
            for: indexPath
        ) as? HomeCardCell else {
            fatalError("HomeCardCell을 dequeue할 수 없습니다.")
        }
        
        let book = sampleBooks[indexPath.item]
        cell.configure(
            title: book.title,
            author: book.author,
            publisher: book.publisher,
            recordCount: 0,
            image: book.imageUrl
        )
        
        // 셀 내부 버튼 이벤트 처리 필요
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RealHomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 40
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
}

// MARK: - UIScrollViewDelegate
extension RealHomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == contentView.collectionView {
            let pageWidth = scrollView.frame.width
            let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
            contentView.pageControlView.currentPage = currentPage
        }
    }
}
