// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class BKBottomSheetTestMenuViewController: UIViewController {
    private let centeredSheetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("----- Centered -----", for: .normal)
        return button
    }()
    
    private let centeredWithSubtitleSheetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("With subtitle", for: .normal)
        return button
    }()
    
    private let centeredWithSubtitleAndImageSheetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("With subtitle and image", for: .normal)
        return button
    }()
    
    private let leadingSheetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("----- Leading -----", for: .normal)
        return button
    }()
    
    private let leadingWithSubtitleSheetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("With subtitle", for: .normal)
        return button
    }()
    
    private let leadingWithSubtitleAndImageSheetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("With subtitle and image", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BottomSheet 테스트"
        view.backgroundColor = .systemBackground
        configure()
        bindActions()
    }

    private func configure() {
        let stack = UIStackView(arrangedSubviews: [
            centeredSheetButton,
            centeredWithSubtitleSheetButton,
            centeredWithSubtitleAndImageSheetButton,
            leadingSheetButton,
            leadingWithSubtitleSheetButton,
            leadingWithSubtitleAndImageSheetButton
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
        centeredSheetButton.addTarget(
            self,
            action: #selector(openCentered),
            for: .touchUpInside
        )
        centeredWithSubtitleSheetButton.addTarget(
            self,
            action: #selector(openCenteredWithSubtitle),
            for: .touchUpInside
        )
        centeredWithSubtitleAndImageSheetButton.addTarget(
            self,
            action: #selector(openCenteredWithSubtitleAndImage),
            for: .touchUpInside
        )
        leadingSheetButton.addTarget(
            self,
            action: #selector(openLeading),
            for: .touchUpInside
        )
        leadingWithSubtitleSheetButton.addTarget(
            self,
            action: #selector(openLeadingWithSubtitle),
            for: .touchUpInside
        )
        leadingWithSubtitleAndImageSheetButton.addTarget(
            self,
            action: #selector(openLeadingWithSubtitleAndImage),
            for: .touchUpInside
        )
    }

    @objc private func openCentered() {
        let sheet = BKBottomSheetViewController(
            title: "타이틀틀",
            style: .centered,
            buttonConfiguration: .singleFullButton()
        )
        sheet.show(from: self, animated: true)
    }
    
    @objc private func openCenteredWithSubtitle() {
        let sheet = BKBottomSheetViewController(
            title: "타이틀틀",
            subtitle: "서브타이틀틀",
            style: .centered,
            buttonConfiguration: .singleFullButton()
        )
        sheet.show(from: self, animated: true)
    }
    
    @objc private func openCenteredWithSubtitleAndImage() {
        let image = UIImageView(image: BKImage.Icon.search)
        let sheet = BKBottomSheetViewController(
            title: "타이틀틀",
            subtitle: "서브타이틀틀",
            style: .centered,
            suppliedContentStyle: .upper(image),
            buttonConfiguration: .singleFullButton()
        )
        sheet.show(from: self, animated: true)
    }
    
    @objc private func openLeading() {
        let sheet = BKBottomSheetViewController(
            title: "타이틀틀",
            style: .leadingCloseButton,
            buttonConfiguration: .singleFullButton()
        )
        sheet.show(from: self, animated: true)
    }
    
    @objc private func openLeadingWithSubtitle() {
        let sheet = BKBottomSheetViewController(
            title: "타이틀틀",
            subtitle: "서브타이틀틀",
            style: .leadingCloseButton,
            buttonConfiguration: .singleFullButton()
        )
        sheet.show(from: self, animated: true)
    }

    @objc private func openLeadingWithSubtitleAndImage() {
        let image = UIImageView(image: BKImage.Icon.search)
        let sheet = BKBottomSheetViewController(
            title: """
            두줄을 가뿐
            히넘기는
            타이틀
            """,
            subtitle: """
            두줄을 가뿐히 넘겨버리
            는 서브타이틀
            """,
            style: .leadingCloseButton,
            suppliedContentStyle: .lower(image),
            buttonConfiguration: .singleFullButton()
        )
        sheet.show(from: self, animated: true)
    }
}
