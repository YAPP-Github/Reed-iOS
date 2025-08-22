// Copyright © 2025 Booket. All rights reserved

import UIKit
import BKDomain
import Combine

final class NoteCoordinator: Coordinator {
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

extension NoteCoordinator: AuthenticationRequiredNotifying, ErrorHandleable {
    func notifyAuthenticationRequired(onFinish: (() -> Void)?) {
        (parentCoordinator as? AuthenticationRequiredNotifying)?.notifyAuthenticationRequired(onFinish: onFinish)
    }
}

extension NoteCoordinator {
    func didCompleteNoteCreation(recordInfo: RecordInfo) {
        let noteNavigationController = UINavigationController()
        noteNavigationController.modalPresentationStyle = .fullScreen
        
        // ✅ 부모를 내 부모(예: BookDetailCoordinator)로 올려준다
        let parent = self.parentCoordinator ?? self
        
        let noteCompletionCoordinator = NoteCompletionCoordinator(
            parentCoordinator: parent,
            navigationController: noteNavigationController,
            recordId: recordInfo.recordId
        )
        
        // 부모의 child로 달기 (addChildCoordinator는 부모 쪽 메서드여야 함)
        parent.addChildCoordinator(noteCompletionCoordinator)
        noteCompletionCoordinator.start()
        
        // 프리젠터는 parent의 navigationController가 가장 안전
        parent.navigationController.present(noteNavigationController, animated: true) {
            // 이제 NoteCoordinator를 정리해도 완료 플로우는 안 죽음
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
