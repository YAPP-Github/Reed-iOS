// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class BKDialogTestViewController: UIViewController {
    private let singleButtonDialog: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Present single button dialog", for: .normal)
        return button
    }()
    
    private let doubleButtonDialog: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Present double button dialog", for: .normal)
        return button
    }()
    
    private let singleButtonWithImageDialog: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Present single button with image dialog", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dialog(Alert Modal) 테스트"
        view.backgroundColor = .bkBaseColor(.primary)
        configure()
        bindActions()
    }

    private func configure() {
        let stack = UIStackView(arrangedSubviews: [
            singleButtonDialog,
            doubleButtonDialog,
            singleButtonWithImageDialog
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center

        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func bindActions() {
        singleButtonDialog.addTarget(
            self,
            action: #selector(presentSingleDialog),
            for: .touchUpInside
        )
        doubleButtonDialog.addTarget(
            self,
            action: #selector(presentDoubleDialog),
            for: .touchUpInside
        )
        singleButtonWithImageDialog.addTarget(
            self,
            action: #selector(presentDialogWithImage),
            for: .touchUpInside
        )
    }

    @objc private func presentSingleDialog() {
        let dialog = BKDialog(
            title: "테스트트",
            subtitle: "서브타이틀틀",
            config: BKDialogConfiguration(
                leftButtonTitle: "왼쪽",
                leftButtonAction: { [weak self] in
                    self?.dismiss(animated: true)
                }
            )
        )
        let dialogViewController = BKDialogViewController(dialog: dialog)
        present(dialogViewController, animated: true)
    }
    
    @objc private func presentDoubleDialog() {
        let dialog = BKDialog(
            title: "테스트트",
            subtitle: "서브타이틀틀",
            config: BKDialogConfiguration(
                leftButtonTitle: "왼쪽",
                leftButtonAction: { [weak self] in
                    self?.dismiss(animated: true)
                },
                rightButtonTitle: "오른쪽",
                rightButtonAction: { [weak self] in
                    self?.dismiss(animated: true)
                }
            )
        )
        let dialogViewController = BKDialogViewController(dialog: dialog)
        present(dialogViewController, animated: true)
    }
    
    @objc private func presentDialogWithImage() {
        let imageView = UIImageView(image: BKImage.Graphics.mascot)
        let dialog = BKDialog(
            title: "테스트트",
            subtitle: "서브타이틀틀",
            config: BKDialogConfiguration(
                leftButtonTitle: "왼쪽",
                leftButtonAction: { [weak self] in
                    self?.dismiss(animated: true)
                }
            ),
            suppliedContentStyle: .upper(imageView)
        )
        let dialogViewController = BKDialogViewController(dialog: dialog)
        present(dialogViewController, animated: true)
    }
}
