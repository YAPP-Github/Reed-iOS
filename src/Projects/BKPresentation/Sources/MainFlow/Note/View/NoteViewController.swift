// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import UIKit

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
}

private extension NoteViewController {
    @objc func customBackButtonTapped() {
        
    }
}
