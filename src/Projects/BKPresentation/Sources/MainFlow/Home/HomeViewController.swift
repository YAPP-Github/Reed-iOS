// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

final class HomeViewController: UIViewController {
    weak var coordinator: MainFlowCoordinator?
    
    private let settingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SettingViewController", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "홈 화면"
        view.backgroundColor = .systemBackground
        configure()
        bindActions()
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

    @objc private func openSettings() {
        coordinator?.didTapSettingButton()
    }
}
