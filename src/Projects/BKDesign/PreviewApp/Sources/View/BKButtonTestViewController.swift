// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

public final class BKButtonTestViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let containerView = UIStackView()

    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupScrollView()
        setupIndependentButtons()
//        setupStackView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setupAllTestButtons()
    }
    
    // MARK: - Setup Scroll & Stack
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
            $0.width.equalToSuperview().inset(20)
        }
    }
    
    private func setupStackView() {
        containerView.axis = .vertical
        containerView.spacing = 16
        containerView.alignment = .fill
        containerView.distribution = .equalSpacing
    }
    
    // MARK: - Setup Buttons by Size
    
    private func setupAllTestButtons() {
        setupButtons(for: .large)
        setupButtons(for: .medium)
        setupButtons(for: .small)
        setupButtons(for: .rounded)
    }
    
    private func setupButtons(for size: BKButtonSize) {
        addButton("Primary", style: .primary, size: size)
        addButton("Secondary", style: .secondary, size: size)
        addButton("Tertiary", style: .tertiary, size: size)

        addIconButton("Apple 로그인", style: .primary, size: size, left: .appleLogo)
        addIconButton("카카오 로그인", style: .primary, size: size, right: .kakaoLogo)
        addIconButton("양쪽 아이콘", style: .primary, size: size, left: .appleLogo, right: .kakaoLogo)
    }
    
    // MARK: - Button Builders
    
    private func addButton(_ title: String, style: BKButtonStyle, size: BKButtonSize) {
        let button = BKButton(style: style, size: size)
        button.title = "[\(size.label)] \(title)"
        containerView.addArrangedSubview(button)
    }

    private func addIconButton(
        _ title: String,
        style: BKButtonStyle,
        size: BKButtonSize,
        left: BKIcon? = nil,
        right: BKIcon? = nil
    ) {
        let button = BKButton(style: style, size: size)
        button.title = "[\(size.label)] \(title)"
        button.leftIcon = left?.image
        button.rightIcon = right?.image
        containerView.addArrangedSubview(button)
    }
    
    private func setupIndependentButtons() {
        let sampleView = UIView()
        scrollView.addSubview(sampleView)
        sampleView.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }

        let buttons: [BKButton] = [
            .primary(title: "[Free] Apple 로그인", size: .large),
            .secondary(title: "[Free] Secondary", size: .large),
            .tertiary(title: "[Free] Tertiary", size: .large),
            .primary(title: "[Free] Apple 로그인", size: .medium),
            .secondary(title: "[Free] Secondary", size: .small),
            .tertiary(title: "[Free] Tertiary", size: .rounded)
        ]

        buttons[0].leftIcon = BKIcon.appleLogo.image
        buttons[2].rightIcon = BKIcon.kakaoLogo.image

        var last: UIView?
        for button in buttons {
            sampleView.addSubview(button)
            button.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(last?.snp.bottom ?? sampleView.snp.top).offset(16)
            }
            last = button
        }
    }

}


public extension BKButtonSize {
    var label: String {
        switch self {
        case .large: return "Large"
        case .medium: return "Medium"
        case .small: return "Small"
        case .rounded: return "Rounded"
        }
    }
}
