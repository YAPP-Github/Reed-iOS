//  Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

final class CatalogViewController: UIViewController {
    private let bottomSheetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("BottomSheetTitleViewController", for: .normal)
        return button
    }()
    
    private let inputCatalogButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("BKInputCatalogViewController", for: .normal)
        return button
    }()

    private let buttonTestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("BKButtonTestViewController", for: .normal)
        return button
    }()

    private let buttonGroupDemoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("BKButtonGroupDemoViewController", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Test Menu"
        view.backgroundColor = .systemBackground
        configure()
        bindActions()
    }

    private func configure() {
        let stack = UIStackView(arrangedSubviews: [
            inputCatalogButton,
            buttonTestButton,
            buttonGroupDemoButton,
            bottomSheetButton
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
        inputCatalogButton.addTarget(self, action: #selector(openInputCatalog), for: .touchUpInside)
        buttonTestButton.addTarget(self, action: #selector(openButtonTest), for: .touchUpInside)
        buttonGroupDemoButton.addTarget(self, action: #selector(openButtonGroupDemo), for: .touchUpInside)
        bottomSheetButton.addTarget(self, action: #selector(openBottomSheetTitle), for: .touchUpInside)
    }
    
    @objc private func openBottomSheetTitle() {
        let vc = BottomSheetTitleViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openInputCatalog() {
        let vc = BKInputCatalogViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openButtonTest() {
        let vc = BKButtonTestViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openButtonGroupDemo() {
        let vc = BKButtonGroupDemoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
