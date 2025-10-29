// Copyright © 2025 Booket. All rights reserved

import BKDesign
import UIKit
import SnapKit

final class NotificationSettingsView: BaseView {
    // MARK: - Closures
    var onNotificationToggleChanged: ((Bool) -> Void)?
    var onPermissionRequestViewTapped: (() -> Void)?

    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView = UIView()

    private let permissionRequestContainer = UIView()
    private let permissionRequestView = UIView()
    private let permissionRequestLabelStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.permissionRequestStackViewSpacing
        stackView.alignment = .leading
        return stackView
    }()
    
    private let permissionRequestTitle = BKLabel(
        text: "알림을 켜주세요.",
        fontStyle: .body1(weight: .semiBold),
        color: .bkContentColor(.brand)
    )
    
    private let permissionRequestContent = BKLabel(
        text: """
        기기 설정에서 Reed 알림을 설정하세요. 
        독서 기록에 도움되는 알림을 받을 수 있어요.
        """,
        fontStyle: .label2(weight: .regular),
        color: .bkContentColor(.tertiary)
    )
    
    private let permissionRequestButton: UIImageView = {
        let imageView = UIImageView(image: BKImage.Icon.chevronRight)
        imageView.tintColor = .bkContentColor(.brand)
        return imageView
    }()
    
    private let permissionToggleContainer = UIView()
    private let permissionToggleLabelStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = .zero
        stackView.alignment = .leading
        return stackView
    }()
    
    private let permissionToggleTitle = BKLabel(
        text: "알림 받기",
        fontStyle: .body1(weight: .medium),
        color: .bkContentColor(.primary)
    )
    
    private let permissionToggleContent = BKLabel(
        text: "리드에서 알림을 보내드려요.",
        fontStyle: .label1(weight: .regular),
        color: .bkContentColor(.tertiary)
    )
    
    private let permissionToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .bkBackgroundColor(.primary)
        return toggle
    }()

    private var permissionToggleContainerTopToRequestConstraint: Constraint?
    private var permissionToggleContainerTopToSafeAreaConstraint: Constraint?
    private var isAnimating = false

    override func setupView() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(permissionRequestContainer, permissionToggleContainer)
        
        permissionRequestContainer.addSubview(permissionRequestView)
        permissionRequestView.addSubviews(permissionRequestLabelStack, permissionRequestButton)
        [permissionRequestTitle, permissionRequestContent]
            .forEach(permissionRequestLabelStack.addArrangedSubview(_:))
        
        permissionToggleContainer.addSubviews(permissionToggleLabelStack, permissionToggle)
        [permissionToggleTitle, permissionToggleContent]
            .forEach(permissionToggleLabelStack.addArrangedSubview(_:))
    }
    
    override func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        permissionRequestContainer.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
        }

        permissionRequestView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
                .inset(LayoutConstants.permissionRequestViewVerticalInset)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.permissionRequestViewHorizontalInset)
        }

        permissionRequestLabelStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
                .inset(LayoutConstants.permissionRequestLabelPadding)
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.commonHorizontalInset)
        }

        permissionRequestButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.commonHorizontalInset)
        }

        permissionToggleContainer.snp.makeConstraints {
            self.permissionToggleContainerTopToRequestConstraint =
                $0.top
                    .equalTo(permissionRequestContainer.snp.bottom)
                    .offset(LayoutConstants.toggleSpacingWithRequest)
                    .constraint
            self.permissionToggleContainerTopToSafeAreaConstraint =
                $0.top
                    .equalTo(contentView.safeAreaLayoutGuide.snp.top)
                    .inset(LayoutConstants.toggleEmptySpacing)
                    .constraint
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.commonHorizontalInset)
            $0.bottom.lessThanOrEqualToSuperview()
        }

        permissionToggleContainerTopToRequestConstraint?.activate()
        permissionToggleContainerTopToSafeAreaConstraint?.deactivate()

        permissionToggleLabelStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
                .inset(LayoutConstants.permissionToggleLabelPadding)
            $0.leading.equalToSuperview()
        }

        permissionToggle.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }
    
    override func configure() {
        permissionRequestView.backgroundColor = .bkBaseColor(.secondary)
        permissionRequestView.layer.cornerRadius = BKRadius.medium
        permissionToggle.addTarget(self, action: #selector(didTapPermissionToggle), for: .valueChanged)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPermissionRequestView))
        permissionRequestView.addGestureRecognizer(tapGesture)
        permissionRequestView.isUserInteractionEnabled = true
    }
}

// MARK: - Public Methods
extension NotificationSettingsView {
    func updateNotificationToggle(isEnabled: Bool, animated: Bool = true) {
        guard permissionToggle.isOn != isEnabled else { return }

        permissionToggle.setOn(isEnabled, animated: false)
        updatePermissionRequestVisibility(isToggleOn: isEnabled, animated: animated)
    }
}

private extension NotificationSettingsView {
    @objc
    func didTapPermissionToggle() {
        onNotificationToggleChanged?(permissionToggle.isOn)
        updatePermissionRequestVisibility(isToggleOn: permissionToggle.isOn, animated: true)
    }

    @objc
    func didTapPermissionRequestView() {
        onPermissionRequestViewTapped?()
    }

    func updatePermissionRequestVisibility(isToggleOn: Bool, animated: Bool) {
        /// 초기엔 애니메이션 없이 즉시 화면 로드
        if !animated {
            if isToggleOn {
                self.permissionRequestContainer.isHidden = true
                self.permissionToggleContainerTopToRequestConstraint?.deactivate()
                self.permissionToggleContainerTopToSafeAreaConstraint?.activate()
            } else {
                self.permissionToggleContainerTopToSafeAreaConstraint?.deactivate()
                self.permissionToggleContainerTopToRequestConstraint?.activate()
                self.permissionRequestContainer.isHidden = false
            }
            self.layoutIfNeeded()
            return
        }

        guard !isAnimating else { return }
        /// 탭 하여 권한 안내 화면이 나오는 경우 애니메이션이 없으면 부자연스러우므로 애니메이션 적용
        isAnimating = true

        if isToggleOn {
            UIView.animate(withDuration: 0.3, animations: {
                self.permissionRequestContainer.isHidden = true
                self.permissionToggleContainerTopToRequestConstraint?.deactivate()
                self.permissionToggleContainerTopToSafeAreaConstraint?.activate()
                self.layoutIfNeeded()
            }, completion: { _ in
                self.isAnimating = false
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.permissionToggleContainerTopToSafeAreaConstraint?.deactivate()
                self.permissionToggleContainerTopToRequestConstraint?.activate()
                self.layoutIfNeeded()
            }, completion: { _ in
                self.permissionRequestContainer.isHidden = false
                self.isAnimating = false
            })
        }
    }
}

private extension NotificationSettingsView {
    enum LayoutConstants {
        static let permissionRequestStackViewSpacing = BKInset.inset05
        static let permissionRequestViewVerticalInset = BKInset.inset2
        static let permissionRequestViewHorizontalInset = BKInset.inset5
        static let commonHorizontalInset = BKInset.inset5
        static let toggleEmptySpacing = BKSpacing.spacing4
        static let toggleSpacingWithRequest = BKSpacing.spacing2
        static let permissionToggleLabelPadding = BKSpacing.spacing4
        static let permissionRequestLabelPadding = BKSpacing.spacing6
    }
}
