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
            leftAction: {
                #if DEBUG
                print("취소 tapped")
                #endif
            },
            rightAction: {
                #if DEBUG
                print("확인 tapped")
                #endif
            }
        ))

        addDivider()

        addSection(title: "ThreeButtonGroup")
        containerView.addArrangedSubview(BKButtonGroup.threeButtonGroup(
            leftTitle: "이전", centerTitle: "중간", rightTitle: "다음",
            leftAction: {
                #if DEBUG
                print("이전 tapped")
                #endif
            },
            centerAction: {
                #if DEBUG
                print("중간 tapped")
                #endif
            },
            rightAction: {
                #if DEBUG
                print("다음 tapped")
                #endif
            }
        ))

        addDivider()

        addSection(title: "SingleFullButton")
        containerView.addArrangedSubview(BKButtonGroup.singleFullButton(
            title: "계속하기",
            action: {
                #if DEBUG
                print("계속하기 tapped")
                #endif
            }
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
            #if DEBUG
            print("Tapped: \(title)")
            #endif
        }, for: .touchUpInside)
        return button
    }

    private func addSection(title: String) {
        let label = BKLabel(text: title, type: .small, alignment: .left)
        containerView.addArrangedSubview(label)
    }

    private func addDivider() {
        let divider = BKDivider(type: .small)
        containerView.addArrangedSubview(divider)
    }
}