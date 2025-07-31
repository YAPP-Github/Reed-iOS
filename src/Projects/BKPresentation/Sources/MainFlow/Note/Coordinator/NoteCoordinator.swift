// Copyright © 2025 Booket. All rights reserved

import UIKit
import Combine

final class NoteCoordinator: Coordinator, SessionExpirationNotifying {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    // Combine을 위한 cancellables 추가
    private var cancellables = Set<AnyCancellable>()
    
    init(
        parentCoordinator: Coordinator?,
        navigationController: UINavigationController
    ) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = NoteViewController(viewModel: NoteViewModel())
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension NoteCoordinator {
    func didCompleteNoteCreation() {
        let viewController = NoteCompletionViewController()
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
            dismissOCRScanner()
            
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
        // 뷰모델의 사이드 이펙트 바인딩
        bindRecognizedTextViewModelSideEffects(viewModel)
        
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
            print("선택된 텍스트: \(selectedText)")
            
            // 선택된 텍스트 저장
            saveRecognizedText(selectedText)
            
            // OCR 스캐너까지 모두 닫기
            dismissOCRScanner()
            
        case .dismissToRetake:
            print("버튼 눌림")
            if let presentedViewController = navigationController.presentedViewController?.presentedViewController {
                presentedViewController.dismiss(animated: true)
            }
        }
    }
    
    /// OCR 스캐너 화면 닫기
    private func dismissOCRScanner() {
        navigationController.dismiss(animated: true)
    }
    
    /// 인식된 텍스트를 노트로 저장하는 로직
    private func saveRecognizedText(_ text: String) {
        // TODO: 새 노트 생성하거나 기존 노트에 추가하는 로직
        // 예: createNewNote(with: text) 또는 addToCurrentNote(text)
        print("텍스트 저장: \(text)")
    }
}
