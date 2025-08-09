// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import UIKit

final class NoteCompletionViewController: BaseViewController<NoteCompletionView> {
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        return .standard(viewController: self)
    }
    override var bkNavigationTitle: String {
        return "독서 기록"
    }
    
    private var cancellable: Set<AnyCancellable> = []
    private let viewModel: AnyViewBindableViewModel<NoteCompletionViewModel.State, NoteCompletionViewModel.Action>
    
    init(viewModel: NoteCompletionViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        let backButton = UIBarButtonItem(
            image: BKImage.Icon.x,
            style: .plain,
            target: self,
            action: #selector(customBackButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        viewModel.send(.onAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0.recordInfo }
            .sink { [weak self] recordInfo in
                self?.contentView.apply(recordInfo: recordInfo)
            }
            .store(in: &cancellable)
        
        
        viewModel.statePublisher
            .map { $0.isLoading }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0.error }
            .sink { [weak self] error in
                // 에러 알림 표시 -> BKStyle로 교체 필요
                let alert = UIAlertController(
                    title: "오류",
                    message: "기록을 불러올 수 없습니다.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                    self?.viewModel.send(.errorHandled)
                    self?.dismiss(animated: true)
                })
                self?.present(alert, animated: true)
            }
            .store(in: &cancellable)
    }
    
    @objc private func customBackButtonTapped() {
        dismiss(animated: true)
    }
}
