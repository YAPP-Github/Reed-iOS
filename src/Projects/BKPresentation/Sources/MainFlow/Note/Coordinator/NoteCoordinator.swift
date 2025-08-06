// Copyright © 2025 Booket. All rights reserved

import UIKit
import BKDomain
import Combine

final class NoteCoordinator: Coordinator, SessionExpirationNotifying {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    private let bookId: String
    
    // Combine을 위한 cancellables 추가
    private var cancellables = Set<AnyCancellable>()
    
    private weak var noteViewController: NoteViewController?
    
    init(
        parentCoordinator: Coordinator?,
        navigationController: UINavigationController,
        bookId: String
    ) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.bookId = bookId
    }
    
    func start() {
        let viewController = NoteViewController(
            viewModel: NoteViewModel(bookId: bookId)
        )
        viewController.coordinator = self
        
        self.noteViewController = viewController
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension NoteCoordinator {
    func didCompleteNoteCreation(recordInfo: RecordInfo) {
        let viewController = NoteCompletionViewController(
            viewModel: NoteCompletionViewModel(
                recordInfo: recordInfo
            )
        )
        let noteNavigationController = UINavigationController(rootViewController: viewController)
        noteNavigationController.modalPresentationStyle = .fullScreen
        navigationController.present(noteNavigationController, animated: true) {
            self.popAndFinish()
        }
    }
    
    /// OCR 실제 연결 버튼에서 해당 함수 호출 필요
    func showOCRScanner() {
        let viewModel = OCRScannerViewModel()
        let ocrViewController = OCRScannerViewController(viewModel: viewModel)
        ocrViewController.coordinator = self
        bindOCRViewModelSideEffects(viewModel)
        
        ocrViewController.modalPresentationStyle = .fullScreen
        navigationController.present(ocrViewController, animated: true)
    }
    
    /// 스캔하기 버튼 눌렀을 때,
    private func bindOCRViewModelSideEffects(_ viewModel: OCRScannerViewModel) {
        viewModel.sideEffectPublisher
            .sink { [weak self] sideEffect in
                self?.handleOCRSideEffect(sideEffect)
            }
            .store(in: &cancellables)
    }
    
    private func handleOCRSideEffect(_ sideEffect: OCRScannerViewModel.SideEffect) {
        switch sideEffect {
        case .showRecognizedSentences(let sentences):
            showRecognizedTextViewController(with: sentences)
            
        case .dismissScanner:
            navigationController.dismiss(animated: true)
            
        }
    }
    
    private func showRecognizedTextViewController(with sentences: [String]) {
        let viewModel = RecognizedTextViewModel()
        let textViewController = RecognizedTextViewController(
            recognizedTexts: sentences,
            viewModel: viewModel
        )
        
        setupRecognizedTextViewController(textViewController, viewModel: viewModel)
    }
    
    // 공통 설정 로직
    private func setupRecognizedTextViewController(
        _ textViewController: RecognizedTextViewController,
        viewModel: RecognizedTextViewModel
    ) {
        bindRecognizedTextViewModelSideEffects(viewModel)
        
        textViewController.modalPresentationStyle = .fullScreen
        
        if let presentedViewController = navigationController.presentedViewController {
            presentedViewController.present(textViewController, animated: true)
        } else {
            // 만약 OCR 스캐너가 없다면 navigationController에서 직접 present
            navigationController.present(textViewController, animated: true)
        }
    }
    
    private func bindRecognizedTextViewModelSideEffects(_ viewModel: RecognizedTextViewModel) {
        viewModel.sideEffectPublisher
            .sink { [weak self] sideEffect in
                self?.handleRecognizedTextSideEffect(sideEffect)
            }
            .store(in: &cancellables)
    }
    
    // RecognizedTextViewModel 사이드 이펙트 처리
    private func handleRecognizedTextSideEffect(_ sideEffect: RecognizedTextViewModel.SideEffect) {
        switch sideEffect {
        case .confirmWithSelectedText(let selectedText):
            noteViewController?.setScannedText(selectedText)
            navigationController.dismiss(animated: true)
            
        case .dismissToRetake:
            if let presentedViewController = navigationController.presentedViewController?.presentedViewController {
                presentedViewController.dismiss(animated: true)
            }
        }
    }
}
