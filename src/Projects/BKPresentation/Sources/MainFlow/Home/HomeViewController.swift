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
            settingButton
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
    }
    
    @objc private func dummyFunc() {
        
    }

    @objc private func openSettings() {
        coordinator?.didTapSettingButton()
    }
}
