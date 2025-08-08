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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map { $0.recordInfo }
            .sink { [weak self] recordInfo in
                self?.contentView.apply(recordInfo: recordInfo)
            }
            .store(in: &cancellable)
    }
    
    @objc private func customBackButtonTapped() {
        dismiss(animated: true)
    }
}
