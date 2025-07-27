// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class NoteView: BaseView {
    private lazy var pageViews: [UIView] = [
        SentenceRegistrationView(),
        EmotionRegistrationView(),
        SentenceAppreciationView()
    ]
    
    private let containerView = UIView()
    private let pageControl = BKPageControl()
    private let contentScrollView = UIScrollView()
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private var nextButton: BKButtonGroup = .singleFullButton(title: "다음")
    
    override func setupView() {
        addSubview(containerView)
        containerView.addSubviews(pageControl, contentScrollView, nextButton)
        contentScrollView.addSubview(contentStackView)
        makeInnerViews()
    }
    
    override func configure() {
        contentScrollView.isPagingEnabled = true
        contentScrollView.isScrollEnabled = false
        contentScrollView.showsHorizontalScrollIndicator = false
        pageControl.numberOfPages = pageViews.count
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        nextButton.primaryButton?.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints {
            $0.top.equalToSuperview()
                .inset(LayoutConstants.pageControlTopInset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(contentScrollView.snp.bottom)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        contentScrollView.snp.makeConstraints {
            $0.top.equalTo(pageControl.snp.bottom)
                .offset(LayoutConstants.contentOffset)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top)
        }
        
        contentStackView.snp.makeConstraints {
            $0.edges.equalTo(contentScrollView.contentLayoutGuide)
            $0.width.equalTo(contentScrollView.frameLayoutGuide)
                .multipliedBy(pageViews.count)
            $0.height.equalTo(contentScrollView.frameLayoutGuide)
        }
    }
}

private extension NoteView {
    func makeInnerViews() {
        pageViews.forEach { pageView in
            let scrollView = UIScrollView()
            scrollView.alwaysBounceVertical = false
            contentStackView.addArrangedSubview(scrollView)
            
            let innerContentView = UIView()
            scrollView.addSubview(innerContentView)
            
            innerContentView.snp.makeConstraints {
                $0.edges.equalTo(scrollView.contentLayoutGuide)
                $0.width.equalTo(scrollView.frameLayoutGuide)
            }
            
            innerContentView.addSubview(pageView)
            pageView.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview().priority(.low)
            }
            
            scrollView.snp.makeConstraints {
                $0.width.equalTo(snp.width)
            }
        }
    }
    
    @objc func pageControlChanged(_ sender: BKPageControl) {
        let x = CGFloat(sender.currentPage) * contentScrollView.bounds.width
        contentScrollView.setContentOffset(.init(x: x, y: 0), animated: true)
    }
    
    @objc func nextButtonTapped() {
        let next = min(pageControl.currentPage + 1, pageViews.count - 1)
        pageControl.currentPage = next
        pageControlChanged(pageControl)
    }
}

private extension NoteView {
    enum LayoutConstants {
        static let pageControlTopInset = BKInset.inset2
        static let contentOffset: CGFloat = 40
        static let horizontalInset = BKInset.inset5
    }
}
