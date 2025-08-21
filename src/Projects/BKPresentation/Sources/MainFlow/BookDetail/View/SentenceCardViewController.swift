// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import UIKit

enum SentenceCardViewEvent: Equatable {
    case didTapSaveButton
    case didTapShareButton
}

final class SentenceCardViewController: BaseViewController<SentenceCardView> {
    override var bkNavigationTitle: String { "" }
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        .standard(viewController: self)
    }
    
    weak var coordinator: BookDetailCoordinator?
    
    private var cancellables = Set<AnyCancellable>()
    let viewModel: AnyViewBindableViewModel<SentenceCardViewModel.State,
                                            SentenceCardViewModel.Action>
    
    init(viewModel: SentenceCardViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        viewModel.send(.onAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func bindAction() {
        
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ouput in
                guard let self = self else { return }
                if let data = ouput.data {
                    contentView.configure(data)
                }
            }
            .store(in: &cancellables)
    }

}
