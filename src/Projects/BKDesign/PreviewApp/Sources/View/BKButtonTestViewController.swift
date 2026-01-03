// Copyright © 2026 Booket. All rights reserved

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
        setupStackView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Button Tests"
        setupAllTestButtons()
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
        
        addSectionSeparator()
        setupTextButtons()
    }
    
    private func setupButtons(for size: BKButtonSize) {
        addButton("Primary", style: .primary, size: size)
        addButton("Secondary", style: .secondary, size: size)
        addButton("Tertiary", style: .tertiary, size: size)
        addButton("Stroke", style: .stroke, size: size)
        addDisabledButton("Stroke-Dis", style: .stroke, size: size)

        addIconButton("Apple 로그인", style: .primary, size: size, left: BKImage.Icon.apple)
        addIconButton("카카오 로그인", style: .primary, size: size, right: BKImage.Icon.kakao)
        addIconButton("양쪽 아이콘", style: .primary, size: size, left: BKImage.Icon.apple, right: BKImage.Icon.kakao)
    }
    
    // MARK: - Text Button Tests
    
    private func setupTextButtons() {
        addSectionHeader("Text Buttons")
        
        addTextButton("텍스트 버튼1", size: .small)
        addTextButton("텍스트 버튼2", size: .medium)
        addTextButton("텍스트 버튼3", size: .large)
        addTextButton("아주 긴 내용의 텍스트 버튼을 만들어봅시다", size: .large)
        addDisabledTextButton("비활성화 텍스트", size: .small)
    }
    
    private func addTextButton(_ title: String, size: BKButtonSize) {
        let button = BKTextButton(title: "[\(size.label)] \(title)", size: size)
        containerView.addArrangedSubview(wrapForLeftAlign(button))
    }
    
    private func addDisabledTextButton(_ title: String, size: BKButtonSize) {
        let button = BKTextButton(title: "[\(size.label)] \(title)", size: size)
        button.isDisabled = true
        containerView.addArrangedSubview(wrapForLeftAlign(button))
    }
    
    /// 텍스트 버튼은 intrinsic size를 사용하므로 왼쪽 정렬 래퍼 필요
    private func wrapForLeftAlign(_ view: UIView) -> UIView {
        let wrapper = UIView()
        wrapper.addSubview(view)
        view.snp.makeConstraints {
            $0.leading.verticalEdges.equalToSuperview()
        }
        return wrapper
    }
    
    // MARK: - Button Builders
    
    private func addButton(_ title: String, style: BKButtonStyle, size: BKButtonSize) {
        let button = BKButton(style: style, size: size)
        button.title = "[\(size.label)] \(title)"
        containerView.addArrangedSubview(button)
    }
    
    private func addDisabledButton(_ title: String, style: BKButtonStyle, size: BKButtonSize) {
        let button = BKButton(style: style, size: size)
        button.title = "[\(size.label)] \(title)"
        button.isDisabled = true
        containerView.addArrangedSubview(button)
    }

    private func addIconButton(
        _ title: String,
        style: BKButtonStyle,
        size: BKButtonSize,
        left: UIImage? = nil,
        right: UIImage? = nil
    ) {
        let button = BKButton(style: style, size: size)
        button.title = "[\(size.label)] \(title)"
        button.leftIcon = left
        button.rightIcon = right
        containerView.addArrangedSubview(button)
    }
    
    // MARK: - Section Helpers
    
    private func addSectionHeader(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .darkGray
        containerView.addArrangedSubview(label)
    }
    
    private func addSectionSeparator() {
        let separator = UIView()
        separator.backgroundColor = .systemGray4
        separator.snp.makeConstraints { $0.height.equalTo(1) }
        containerView.addArrangedSubview(separator)
        containerView.setCustomSpacing(24, after: separator)
    }
}

// MARK: - BKButtonSize Extension
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
