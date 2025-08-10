// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import SnapKit
import UIKit

struct OnboardingPage {
    let image: UIImage
    let title: String
    let description: String
    let titleHighlightWord: String
}

final class OnboardingView: BaseView {
    let eventPublisher = PassthroughSubject<OnboardingViewEvent, Never>()
    
    private let containerView = UIView()
    private let scrollView = UIScrollView()
    private let innerContentView = UIView()
    private let innerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = .zero
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = .zero
        pageControl.pageIndicatorTintColor = .bkBackgroundColor(.secondaryPressed)
        pageControl.currentPageIndicatorTintColor = .bkBackgroundColor(.primary)
        pageControl.numberOfPages = Constants.pages.count
        return pageControl
    }()
    
    private let nextButton = BKButtonGroup.singleFullButton(title: "다음")
    
    override func setupView() {
        addSubviews(containerView)
        containerView.addSubviews(innerContentView, pageControl, nextButton)
        innerContentView.addSubview(scrollView)
        scrollView.addSubview(innerStackView)
        
        Constants.pages.map(makeInnerView).forEach { pageView in
            innerStackView.addArrangedSubview(pageView)
            
            pageView.snp.makeConstraints {
                $0.width.equalTo(scrollView.frameLayoutGuide)
                $0.height.equalTo(scrollView.frameLayoutGuide)
            }
        }
    }
    
    override func configure() {
        scrollView.isPagingEnabled = true
        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        nextButton.primaryButton?.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top)
                .offset(-LayoutConstants.pageControlBottomOffset)
        }
        
        innerContentView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(pageControl.snp.top)
        }
        
        scrollView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.lessThanOrEqualTo(innerContentView.snp.height)
        }
        
        innerStackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
                .multipliedBy(pageControl.numberOfPages)
            $0.height.equalTo(scrollView.frameLayoutGuide)
        }
    }
}

private extension OnboardingView {
    func makeInnerView(
        page: OnboardingPage
    ) -> UIView {
        let contentView = UIView()
        let imageView = UIImageView(image: page.image)
        let labelStack = makeInnerLabelStack(page)
        contentView.addSubviews(imageView, labelStack)
        
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.innerImageViewInset)
        }
        labelStack.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
                .offset(LayoutConstants.labelStackTopOffset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.labelStackHorizontalInset)
            $0.bottom.equalToSuperview()
        }
        
        return contentView
    }
    
    func makeInnerLabelStack(
        _ page: OnboardingPage
    ) -> UIStackView {
        let titleLabel = BKLabel(
            text: page.title,
            fontStyle: .heading1(weight: .bold),
            alignment: .center,
            highlightedWord: page.titleHighlightWord
        )
        let descriptionLabel = BKLabel(
            text: page.description,
            fontStyle: .body2(weight: .medium),
            color: .bkContentColor(.tertiary),
            alignment: .center
        )
        titleLabel.numberOfLines = .zero
        descriptionLabel.numberOfLines = .zero
        
        let labelStack = UIStackView()
        labelStack.axis = .vertical
        labelStack.spacing = LayoutConstants.labelStackSpacing
        labelStack.alignment = .center
        
        [titleLabel, descriptionLabel].forEach(labelStack.addArrangedSubview(_:))
        return labelStack
    }
    
    @objc func pageControlChanged(_ sender: UIPageControl) {
        let x = CGFloat(sender.currentPage) * scrollView.bounds.width
        scrollView.setContentOffset(.init(x: x, y: 0), animated: true)
    }
    
    @objc func nextButtonTapped() {
        let next = pageControl.currentPage + 1
        guard next < pageControl.numberOfPages else {
            eventPublisher.send(.onboardingDidFinish)
            return
        }
        
        updateButtonTitle(for: next)
        updatePage(to: next)
    }

    func updateButtonTitle(for page: Int) {
        let isLast = (page == pageControl.numberOfPages - 1)
        let title = isLast ? "로그인" : "다음"
        nextButton.primaryButton?.title = title
    }

    func updatePage(to index: Int) {
        pageControl.currentPage = index
        pageControlChanged(pageControl)
    }
    
    func syncPageWithScroll() {
        guard scrollView.bounds.width > 0 else { return }
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        guard page != pageControl.currentPage,
              (0..<pageControl.numberOfPages).contains(page) else { return }
        pageControl.currentPage = page
        updateButtonTitle(for: page)
    }
}

extension OnboardingView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        syncPageWithScroll()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        syncPageWithScroll()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        syncPageWithScroll()
    }
}
 
private extension OnboardingView {
    enum LayoutConstants {
        static let labelStackSpacing = BKSpacing.spacing3
        static let labelStackTopOffset = BKSpacing.spacing8
        static let labelStackHorizontalInset = BKInset.inset5
        static let pageControlBottomOffset = BKInset.inset6
        static let innerImageViewInset: CGFloat = 27.5
    }
    
    enum Constants {
        static let pages: [OnboardingPage] = [
            OnboardingPage(
                image: BKImage.Graphics.onboarding1,
                title: """
                읽고 있는 책을 등록하고
                바로 기록해보세요
                """,
                description: """
                책을 덮기 전, 마음에 남은 문장과 
                감정을 간편하게 남길 수 있어요
                """,
                titleHighlightWord: "기록"
            ),
            OnboardingPage(
                image: BKImage.Graphics.onboarding2,
                title: """
                어떻게 쓸지 막막할땐, 
                감상평 가이드가 도와드려요
                """,
                description: """
                감정과 생각을 이끌어주는 
                문장들이 기록을 자연스럽게 도와줘요
                """,
                titleHighlightWord: "감상평 가이드"
            ),
            OnboardingPage(
                image: BKImage.Graphics.onboarding3,
                title: """
                독서 중 느낀 감정은
                씨앗으로 남겨보세요
                """,
                description: """
                책마다 쌓인 감정들은
                나만의 독서 흔적이 됩니다
                """,
                titleHighlightWord: "씨앗"
            )
        ]
    }
}
