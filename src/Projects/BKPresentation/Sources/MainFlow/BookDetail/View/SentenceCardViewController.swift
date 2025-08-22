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
    let viewModel: AnyViewBindableViewModel<
        SentenceCardViewModel.State,
        SentenceCardViewModel.Action
    >
    
    init(viewModel: SentenceCardViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
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
        contentView.eventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .didTapSaveButton:
                    self.viewModel.send(.prepareToSaveImage)
                    let image = self.contentView.renderCardImageWithoutCornerRadius()
                    self.viewModel.send(.didTapSaveButton(image: image))
                case .didTapShareButton:
                    self.showLoading()
                    let image = self.contentView.renderCardImageWithoutCornerRadius()
                    self.presentShareSheet(with: image) {
                        self.hideLoading()
                    }
                }
            }
            .store(in: &cancellables)
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
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map(\.alertInfo)
            .removeDuplicates()
            .sink { [weak self] alertInfo in
                guard let self = self, let info = alertInfo else { return }
                
                self.showAlert(info)
            }
            .store(in: &cancellables)
        
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
            .store(in: &cancellables)
    }
    
}

extension SentenceCardViewController {
    private func showAlert(_ message: String) {
        ToastMessageView.show(message: message, duration: 2.0)
        viewModel.send(.alertDismissed)
    }
    
    private func presentShareSheet(with image: UIImage, completion: (() -> Void)? = nil) {
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(activityViewController, animated: true, completion: completion)
    }
}
