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
    
    func showOCRScanner() {
        let viewModel = OCRScannerViewModel()
        let ocrViewController = OCRScannerViewController(viewModel: viewModel)
        ocrViewController.coordinator = self
        
        // ViewModel의 SideEffect 구독
        bindOCRViewModelSideEffects(viewModel)
        
        navigationController.present(ocrViewController, animated: true)
    }
    
    private func bindOCRViewModelSideEffects(_ viewModel: OCRScannerViewModel) {
        viewModel.sideEffectPublisher
            .sink { [weak self] sideEffect in
                self?.handleOCRSideEffect(sideEffect)
            }
            .store(in: &cancellables)
    }
    
    private func handleOCRSideEffect(_ sideEffect: OCRScannerViewModel.SideEffect) {
        switch sideEffect {
        case .showRecognizedText(let text):
            showRecognizedTextViewController(with: text)
            
        case .dismissScanner:
            dismissOCRScanner()
        }
    }
    
    /// 인식된 텍스트 확인 화면으로 이동
    private func showRecognizedTextViewController(with text: String) {
        let textViewController = RecognizedTextViewController(recognizedText: text)
        
        // 선택 완료 콜백 처리
        textViewController.onConfirm = { [weak self] selectedText in
            print("선택된 텍스트: \(selectedText)")
            
            // 여기에 선택된 텍스트 저장 로직 추가
            self?.saveRecognizedText(selectedText)
            
            // OCR 스캐너까지 모두 닫기
            self?.dismissOCRScanner()
        }
        
        // 다시 촬영하기 콜백 처리
        textViewController.onRetake = { [weak self] in
            // 현재 텍스트 선택 화면만 닫고 OCR 스캐너로 돌아가기
            self?.navigationController.dismiss(animated: true)
        }
        
        navigationController.present(textViewController, animated: true)
    }
    
    /// OCR 스캐너 화면 닫기
    private func dismissOCRScanner() {
        navigationController.dismiss(animated: true)
    }
    
    /// 인식된 텍스트를 노트로 저장하는 로직
    private func saveRecognizedText(_ text: String) {
        // TODO: 새 노트 생성하거나 기존 노트에 추가하는 로직
        // 예: createNewNote(with: text) 또는 addToCurrentNote(text)
        print("💾 텍스트 저장: \(text)")
    }
}
