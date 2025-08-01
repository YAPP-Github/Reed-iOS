// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

final class HomeViewController: UIViewController, BKNavigationBarStylable {
    weak var coordinator: MainFlowCoordinator?    
    var bkNavigationTitle: String = "홈"
    var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        .main(
            viewController: self,
            target: self,
            searchAction: #selector(dummyFunc),
            gearAction: #selector(dummyFunc)
        )
    }
    
    private let settingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SettingViewController", for: .normal)
        return button
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SearchViewController", for: .normal)
        return button
    }()
    
    private let noteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("NoteViewController", for: .normal)
        return button
    }()
    
    private let bookDetailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("BookDetailViewController", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bkBaseColor(.primary)
        configure()
        bindActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.applyStyleIfNeeded(for: self)
    }

    private func configure() {
        let stack = UIStackView(arrangedSubviews: [
            settingButton,
            searchButton,
            noteButton,
            bookDetailButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center

        view.addSubview(stack)
        
        stack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }

    private func bindActions() {
        settingButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(openSearch), for: .touchUpInside)
        noteButton.addTarget(self, action: #selector(openNote), for: .touchUpInside)
        bookDetailButton.addTarget(self, action: #selector(openBookDetail), for: .touchUpInside)
    }
    
    @objc private func dummyFunc() {
        
    }

    @objc private func openSettings() {
        coordinator?.didTapSettingButton()
    }
    
    @objc private func openSearch() {
        coordinator?.didTapSearchButton()
    }
    
    @objc private func openNote() {
        coordinator?.didTapNoteButton()
    }
    
    @objc private func openBookDetail() {
        coordinator?.didTapBookDetailButton()
    }
}
