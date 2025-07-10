// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

public final class BKButtonGroupDemoViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let containerView = UIStackView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupScrollView()
        setupDemoGroups()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Button"
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        scrollView.addSubview(containerView)
        containerView.axis = .vertical
        containerView.spacing = 16
        containerView.alignment = .fill
        containerView.distribution = .fill
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
            $0.width.equalToSuperview().inset(20)
        }
    }

    private func setupDemoGroups() {
        addSection(title: "Custom 구성 (직접 만든 그룹)")
        containerView.addArrangedSubview(BKButtonGroup(
            buttons: [
                makeButton(title: "[Custom] S", size: .small),
                makeButton(title: "[Custom] M", size: .medium),
                makeButton(title: "[Custom] L", size: .large)
            ],
            layout: .horizontal
        ))

        addDivider()

        addSection(title: "TwoButtonGroup")
        containerView.addArrangedSubview(BKButtonGroup.twoButtonGroup(
            leftTitle: "취소", rightTitle: "확인",
            leftAction: { print("취소 tapped") },
            rightAction: { print("확인 tapped") }
        ))

        addDivider()

        addSection(title: "ThreeButtonGroup")
        containerView.addArrangedSubview(BKButtonGroup.threeButtonGroup(
            leftTitle: "이전", centerTitle: "중간", rightTitle: "다음",
            leftAction: { print("이전 tapped") },
            centerAction: { print("중간 tapped") },
            rightAction: { print("다음 tapped") }
        ))

        addDivider()

        addSection(title: "SingleFullButton")
        containerView.addArrangedSubview(BKButtonGroup.singleFullButton(
            title: "계속하기",
            action: { print("계속하기 tapped") }
        ))

        addDivider()

        addSection(title: "VerticalGroup (Rounded 버튼)")
        containerView.addArrangedSubview(BKButtonGroup.verticalButtonGroup(buttons: [
            makeButton(title: "둥글1", size: .rounded),
            makeButton(title: "둥글2", size: .rounded)
        ]))
    }

    private func makeButton(title: String, size: BKButtonSize) -> BKButton {
        let button = BKButton.primary(title: title, size: size)
        button.addAction(UIAction { _ in
            print("Tapped: \(title)")
        }, for: .touchUpInside)
        return button
    }

    private func addSection(title: String) {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .darkGray
        containerView.addArrangedSubview(label)
    }

    private func addDivider() {
        let divider = UIView()
        divider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        containerView.addArrangedSubview(divider)
    }
}
