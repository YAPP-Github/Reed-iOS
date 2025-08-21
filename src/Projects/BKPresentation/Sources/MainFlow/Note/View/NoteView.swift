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
    private var keyboardCancellables = Set<AnyCancellable>()
    
    private var currentFocusedInput: FocusedInput = .none
    
    private enum FocusedInput {
        case none
        case pageField
        case sentenceTextView
        case scanButton
        case appreciationTextView
    }
    
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
        sentenceView.onPageFieldFocused = { [weak self] in 
            self?.currentFocusedInput = .pageField
        }
        sentenceView.onSentenceTextViewFocused = { [weak self] in 
            self?.currentFocusedInput = .sentenceTextView
        }
        appreciationView.onAppreciationTextViewFocused = { [weak self] in
            self?.currentFocusedInput = .appreciationTextView
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(tapGesture)
        
        setupKeyboardHandling()
        
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
    
    func startEditingIfNeeded() {
        appreciationView.startEditingIfNeeded()
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
        
        // input change 관련 cancellable만 제거하고 재설정
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
        currentFocusedInput = .none
        endEditing(true)
    }
    
    private func setupKeyboardHandling() {
        let keyboardWillShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return nil }
                return keyboardFrame.height
            }
        
        let keyboardWillHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat.zero }
        
        Publishers.Merge(keyboardWillShow, keyboardWillHide)
            .sink { [weak self] height in
                self?.adjustForKeyboard(height: height)
            }
            .store(in: &keyboardCancellables)
    }
    
    private func adjustForKeyboard(height: CGFloat) {
        // 각 페이지 뷰의 스크롤뷰 contentInset 조정
        contentStackView.arrangedSubviews.enumerated().forEach { index, view in
            guard let scrollView = view as? UIScrollView else { return }
            scrollView.contentInset.bottom = height
            scrollView.verticalScrollIndicatorInsets.bottom = height
            
            // 현재 페이지에서 키보드가 나타날 때만 스크롤
            if index == pageControl.currentPage, height > 0 {
                // 포커스된 입력에 따라 적절한 스크롤 수행
                switch currentFocusedInput {
                case .pageField:
                    if index == 0 { scrollToPageField(in: scrollView) }
                case .sentenceTextView:
                    if index == 0 { scrollToSentenceTextView(in: scrollView) }
                case .scanButton:
                    if index == 0 { scrollToScanButton(in: scrollView) }
                case .appreciationTextView:
                    if index == 2 { scrollToAppreciationTextView(in: scrollView) }
                case .none:
                    break
                }
            }
        }
    }
    
    private func scrollToScanButton(in scrollView: UIScrollView) {
        guard let sentenceView = pageViews.first as? SentenceRegistrationView else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // SentenceRegistrationView의 스캔 버튼이 보이도록 스크롤
            let scanButtonFrame = sentenceView.scanButtonFrame
            let scanButtonGlobalFrame = sentenceView.convert(scanButtonFrame, to: scrollView)
            
            // 스캔 버튼이 키보드 위에 20pt 여백을 두고 보이도록 계산
            let visibleHeight = scrollView.frame.height - scrollView.contentInset.bottom
            let targetY = max(0, scanButtonGlobalFrame.maxY - visibleHeight + 20)
            
            scrollView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
        }
    }
    
    private func scrollToPageField(in scrollView: UIScrollView) {
        guard let sentenceView = pageViews.first as? SentenceRegistrationView else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 페이지 필드 라벨이 보이도록 스크롤 (상단 여백 포함)
            let pageFieldFrame = sentenceView.pageFieldFrame
            let pageFieldGlobalFrame = sentenceView.convert(pageFieldFrame, to: scrollView)
            
            // 페이지 필드 라벨이 상단에 20pt 여백을 두고 보이도록
            let targetY = max(0, pageFieldGlobalFrame.minY - 20)
            
            scrollView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
        }
    }
    
    private func scrollToSentenceTextView(in scrollView: UIScrollView) {
        guard let sentenceView = pageViews.first as? SentenceRegistrationView else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 문장 기록 라벨이 보이도록 스크롤
            let sentenceTextViewFrame = sentenceView.sentenceTextViewFrame
            let sentenceTextViewGlobalFrame = sentenceView.convert(sentenceTextViewFrame, to: scrollView)
            
            // 문장 기록 라벨이 상단에 20pt 여백을 두고 보이도록
            let targetY = max(0, sentenceTextViewGlobalFrame.minY - 20)
            
            scrollView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
        }
    }
    
    private func scrollToAppreciationTextView(in scrollView: UIScrollView) {
        guard let appreciationView = pageViews[2] as? SentenceAppreciationView else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 감상 텍스트뷰 라벨이 보이도록 스크롤
            let appreciationTextViewFrame = appreciationView.appreciationTextViewFrame
            let appreciationTextViewGlobalFrame = appreciationView.convert(appreciationTextViewFrame, to: scrollView)
            
            // 감상 텍스트뷰 라벨이 상단에 20pt 여백을 두고 보이도록
            let targetY = max(0, appreciationTextViewGlobalFrame.minY - 20)
            
            scrollView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
        }
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
