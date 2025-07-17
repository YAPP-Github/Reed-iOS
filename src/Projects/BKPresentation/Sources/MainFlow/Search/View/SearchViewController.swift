// Copyright © 2025 Booket. All rights reserved

import Combine
import UIKit

enum SearchViewEvent: Equatable {
    case search(String)
}

final class SearchViewController: BaseViewController<SearchView> {
    weak var coordinator: SearchCoordinator?
    
    override var bkNavigationTitle: String {
        return "도서 검색"
    }
    
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        return .standard(viewController: self)
    }
    
    private var cancellable = Set<AnyCancellable>()
    let viewModel: AnyViewBindableViewModel<SearchViewModel.State, SearchViewModel.Action>
    
    init(viewModel: SearchViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func bindAction() {
        viewModel.send(.onAppear)
        contentView.eventPublisher
            .receive(on: DispatchQueue.main)
            .compactMap {
                if case let .search(query) = $0 { return query }
                return nil
            }
            .removeDuplicates()
            .sink { [weak self] event in
                // TODO: - 검색 기능 구현
//                self?.viewModel.send()
            }
            .store(in: &cancellable)
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] in
                self?.contentView.applySnapshot(with: $0)
            }
            .store(in: &cancellable)
    }
}
