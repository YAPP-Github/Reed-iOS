// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import UIKit

enum NoteViewEvent {
    case completeForm(NoteForm)
}

final class NoteViewController: BaseViewController<NoteView> {
    weak var delegate: NoteCoordinator?
    
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        return .standard(viewController: self)
    }
    
    override var bkNavigationTitle: String { "" }
    
    private var cancellable: Set<AnyCancellable> = []
    private let viewModel: AnyViewBindableViewModel<NoteViewModel.State, NoteViewModel.Action>
    
    init(viewModel: NoteViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        let backButton = UIBarButtonItem(
            image: BKImage.Icon.chevronLeft,
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
    
    override func bindAction() {
        contentView.eventPublisher
            .compactMap { event -> NoteForm? in
                if case let .completeForm(form) = event { return form }
                return nil
            }
            .sink { [weak self] _ in
                // TODO: - ViewModel 구현 이후 추가
//                self?.viewModel.send(.submitNoteForm(query))
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellable)
    }
}

private extension NoteViewController {
    @objc func customBackButtonTapped() {
        let currentPage = contentView.pageControl.currentPage
        if currentPage == 0 {
            navigationController?.popViewController(animated: true)
        } else {
            contentView.pageControl.currentPage -= 1
        }
    }
}
