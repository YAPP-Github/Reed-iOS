// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import SnapKit
import UIKit

enum RegistrationForm {
    case sentence(SentenceRegistrationForm)
    case emotion(EmotionRegistrationForm)
    case appreciation(SentenceAppreciationForm)
}

protocol RegistrationFormProvidable {
    func registrationForm() -> RegistrationForm?
}

protocol FormInputNotifiable: AnyObject {
    var inputChangedPublisher: AnyPublisher<Void, Never> { get }
}

final class NoteView: BaseView {
    let eventPublisher = PassthroughSubject<NoteViewEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var sentenceView = SentenceRegistrationView()
    private lazy var emotionView = EmotionRegistrationView()
    private lazy var appreciationView = SentenceAppreciationView { [weak self] in
        self?.guideButtonTapped()
    }

    private lazy var pageViews: [UIView] = [
        sentenceView,
        emotionView,
        appreciationView
    ]
    
    let pageControl = BKPageControl()
    private let containerView = UIView()
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
    }
    
    override func configure() {
        contentScrollView.isPagingEnabled = true
        contentScrollView.isScrollEnabled = false
        contentScrollView.showsHorizontalScrollIndicator = false
        pageControl.numberOfPages = pageViews.count
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        nextButton.primaryButton?.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        sentenceView.onTextScanTapped = { [weak self] in self?.eventPublisher.send(.didTapOCRButton) }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(tapGesture)
        
        if let notifiable = currentView as? FormInputNotifiable {
            notifiable.inputChangedPublisher
                .sink { [weak self] in self?.updateNextButtonEnabled() }
                .store(in: &cancellables)
        }
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
        
        makeInnerViews()
    }
    
    func setAppreciationText(_ text: String) {
        appreciationView.setText(text)
    }
}

private extension NoteView {
    var currentView: UIView {
        pageViews[pageControl.currentPage]
    }
    
    func makeInnerViews() {
        pageViews.forEach { pageView in
            let scrollView = UIScrollView()
            scrollView.alwaysBounceVertical = false
            scrollView.showsVerticalScrollIndicator = false
            contentStackView.addArrangedSubview(scrollView)
            
            scrollView.addSubview(pageView)
            scrollView.snp.makeConstraints {
                $0.width.equalTo(scrollView.frameLayoutGuide)
                $0.top.bottom.equalToSuperview()
            }
            pageView.snp.makeConstraints {
                $0.edges.equalTo(scrollView.contentLayoutGuide)
                $0.width.equalTo(scrollView.frameLayoutGuide)
            }
            
            scrollView.setContentHuggingPriority(.defaultLow, for: .vertical)
            scrollView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            updateNextButtonEnabled()
        }
    }
    
    func createFormData() -> NoteForm? {
        let forms: [RegistrationForm] = pageViews.compactMap { view in
            (view as? RegistrationFormProvidable)?.registrationForm()
        }
        return .makeNoteForm(from: forms)
    }
    
    func guideButtonTapped() {
        eventPublisher.send(.didTapGuideButton)
    }
    
    func updateNextButtonEnabled() {
        guard pageControl.currentPage < pageViews.count else { return }
        let isValid = (currentView as? RegistrationFormProvidable)?.registrationForm() != nil
        nextButton.primaryButton?.isEnabled = isValid
    }
    
    @objc func pageControlChanged(_ sender: BKPageControl) {
        let xpos = CGFloat(sender.currentPage) * contentScrollView.bounds.width
        contentScrollView.setContentOffset(.init(x: xpos, y: 0), animated: true)
        
        cancellables.removeAll()

        if let notifiable = currentView as? FormInputNotifiable {
            notifiable.inputChangedPublisher
                .sink { [weak self] in self?.updateNextButtonEnabled() }
                .store(in: &cancellables)
        }
        
        updateNextButtonEnabled()
    }
    
    @objc func nextButtonTapped() {
        var next = min(pageControl.currentPage + 1, pageViews.count - 1)
        
        if pageControl.currentPage + 1 == pageViews.count {
            if let formData = createFormData() {
                eventPublisher.send(.completeForm(formData))
                return
            } else { next = 0 }
        }
        
        pageControl.currentPage = next
        pageControlChanged(pageControl)
    }
    
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
}

private extension NoteView {
    enum LayoutConstants {
        static let pageControlTopInset = BKInset.inset2
        static let contentOffset: CGFloat = 40
        static let horizontalInset = BKInset.inset5
    }
}

extension NoteView {
    
    /// 외부에서 이벤트를 직접 처리할 수 있는 메서드
    func handleEvent(_ event: NoteViewEvent) {
        switch event {
        case .setScannedText(let text):
            setScannedText(text)
        default:
            break
        }
    }
    
    /// OCR 텍스트를 SentenceRegistrationView에 설정
    func setScannedText(_ text: String) {
        sentenceView.setScannedText(text)
        
        // 현재 페이지가 문장 등록 페이지가 아니라면 해당 페이지로 이동
        if pageControl.currentPage != 0 {
            pageControl.currentPage = 0
            pageControlChanged(pageControl)
        }
    }
}
