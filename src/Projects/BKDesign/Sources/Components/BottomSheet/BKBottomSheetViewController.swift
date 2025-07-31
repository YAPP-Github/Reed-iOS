// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public final class BKBottomSheetViewController: UIViewController {
    public var suppliedContentStyle: SuppliedContentStyle?
    public var button: BKButtonGroup?
    public var cornerRadius: CGFloat = BKSpacing.spacing5
    private var contentAspectRatio: CGFloat?
    
    private let style: BKBottomSheetStyle
    private let titleView: BKBottomSheetTitleView
    private var dimView: BKDimView?
    
    private let rootStack = UIStackView()
    
    public init(
        title: String,
        subtitle: String? = nil,
        style: BKBottomSheetStyle = .leadingCloseButton,
        suppliedContentStyle: SuppliedContentStyle? = nil,
        buttonConfiguration: BKButtonGroup? = nil
    ) {
        self.style = style
        self.suppliedContentStyle = suppliedContentStyle
        self.button = buttonConfiguration
        self.titleView = BKBottomSheetTitleView(
            style: style == .leadingCloseButton ? .leadingCloseButton : .centered,
            title: title,
            subtitle: subtitle
        )
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard isBeingDismissed || isMovingFromParent else { return }

        if let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimView?.alpha = .zero
            }, completion: { context in
                if !context.isCancelled {
                    self.dimView?.removeFromSuperview()
                    self.dimView = nil
                }
            })
        } else {
            dimView?.removeFromSuperview()
            dimView = nil
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let targetWidth = rootStack.bounds.width
        guard targetWidth > 0 else { return }

        let fittingSize = rootStack.systemLayoutSizeFitting(
            CGSize(
                width: targetWidth,
                height: UIView.layoutFittingCompressedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        let buttonHeight = button?.frame.height ?? .zero
        let totalHeight = fittingSize.height + buttonHeight + BKSpacing.spacing5

        preferredContentSize = CGSize(
            width: view.bounds.width,
            height: totalHeight
        )

        applyBottomSheetShadow(to: view)
    }
    
    public func show(from viewController: UIViewController, animated: Bool) {
        let dim = BKDimView(alpha: LayoutConstants.dimViewAlpha)
        dim.tapHandler = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        if let navigationView = viewController.navigationController?.view {
            navigationView.addSubview(dim)
            self.dimView = dim
        } else {
            viewController.view.addSubview(dim)
            self.dimView = dim
        }
        
        dim.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        setupPresentationController()
        modalPresentationStyle = .pageSheet
        viewController.present(self, animated: animated, completion: nil)
    }
}

public extension BKBottomSheetViewController {
    // TODO: - Presentation Layer로 분리
    static func makeWithdrawalSheet(
        title: String,
        subtitle: String,
        agreementText: String,
        cancelTitle: String = "취소",
        confirmTitle: String = "탈퇴하기",
        cancelAction: @escaping () ->Void,
        confirmAction: @escaping () ->Void
    ) -> BKBottomSheetViewController {
        let checkBox = BKCheckBoxLabel(
            checkboxType: .rectangle,
            labelText: agreementText
        )
        
        let sheet = BKBottomSheetViewController(
            title: title,
            subtitle: subtitle,
            style: .centered,
            suppliedContentStyle: .lower(checkBox),
            buttonConfiguration: .twoButtonGroup(
                leftTitle: cancelTitle,
                rightTitle: confirmTitle,
                leftAction: cancelAction,
                rightAction: confirmAction
            )
        )
        
        sheet.button?.setPrimaryButtonState(false)
        checkBox.onChecked = { isChecked in
            sheet.button?.setPrimaryButtonState(isChecked)
        }
        
        return sheet
    }
}

private extension BKBottomSheetViewController {
    func setup() {
        view.backgroundColor = .bkBaseColor(.primary)
        view.layer.cornerRadius = BKRadius.sheet
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        view.addSubview(rootStack)
        rootStack.axis = .vertical
        rootStack.spacing = .zero
        
        titleView.onClose = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        calculateRatioIfNeeded()
        assembleContent()
        configure()
        layout()
    }
    
    func configure() {
        modalPresentationStyle = .pageSheet
        setupPresentationController()
    }
    
    func layout() {
        rootStack.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(BKSpacing.spacing5)
            $0.leading.trailing.equalToSuperview().inset(BKSpacing.spacing5)
        }
        
        if let button {
            button.snp.makeConstraints {
                $0.top.equalTo(rootStack.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(LayoutConstants.buttonGroupHeight)
            }
        }
    }
    
    func assembleContent() {
        switch style {
        case .leadingCloseButton:
            makeLeadingContent()
        case .centered:
            makeCenteredContent()
        }

        if let button {
            view.addSubview(button)
        }
    }
    
    func makeLeadingContent() {
        rootStack.alignment = .fill
        
        switch suppliedContentStyle {
        case .upper(let contentView):
            rootStack.addArrangedSubview(contentView)
            applyRatioIfNeeded(to: contentView)
            rootStack.addArrangedSubview(titleView)
        case .lower(let contentView):
            rootStack.addArrangedSubview(titleView)
            rootStack.addArrangedSubview(contentView)
            applyRatioIfNeeded(to: contentView)
        case .none:
            rootStack.addArrangedSubview(titleView)
        }
    }
    
    func makeCenteredContent() {
        rootStack.alignment = .center
        
        let paddedContainer = UIView()
        let inner = UIStackView()
        inner.axis = .vertical
        inner.alignment = .center
        inner.spacing = BKSpacing.spacing5
        paddedContainer.addSubview(inner)
        
        inner.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(BKInset.inset3)
            $0.leading.trailing.equalToSuperview()
        }
        
        switch suppliedContentStyle {
        case .upper(let contentView):
            inner.addArrangedSubview(contentView)
            applyRatioIfNeeded(to: contentView)
            inner.addArrangedSubview(titleView)
        case .lower(let contentView):
            inner.addArrangedSubview(titleView)
            inner.addArrangedSubview(contentView)
            applyRatioIfNeeded(to: contentView)
        case .none:
            inner.addArrangedSubview(titleView)
        }

        rootStack.addArrangedSubview(paddedContainer)
         
        paddedContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    func applyBottomSheetShadow(to view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = BottomSheetShadow.color.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = BottomSheetShadow.offset
        view.layer.shadowRadius = BottomSheetShadow.blur / 2
        
        let shadowPath = UIBezierPath(
            roundedRect: view.bounds,
            cornerRadius: cornerRadius
        )
        view.layer.shadowPath = shadowPath.cgPath
    }
    
    func setupPresentationController() {
        guard let sheet = sheetPresentationController else { return }
        sheet.detents = [
            .custom(identifier: .init("dynamic")) { _ in
                self.preferredContentSize.height
            }
        ]
        sheet.preferredCornerRadius = cornerRadius
        sheet.prefersGrabberVisible = false
        sheet.prefersEdgeAttachedInCompactHeight = true
        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
    }
    
    func calculateRatioIfNeeded() {
        guard let style = suppliedContentStyle else { return }

        let targetView: UIView
        switch style {
        case .upper(let view), .lower(let view):
            targetView = view
        }

        if let imageView = targetView as? UIImageView,
           let image = imageView.image {
            contentAspectRatio = image.size.height / image.size.width
            imageView.contentMode = .scaleAspectFit
        }
    }
    
    func applyRatioIfNeeded(to view: UIView) {
        if let ratio = contentAspectRatio {
            view.snp.makeConstraints {
                $0.width.equalToSuperview()
                $0.height.equalTo(view.snp.width).multipliedBy(ratio)
            }
        }
    }
}

private extension BKBottomSheetViewController {
    enum LayoutConstants {
        static let dimViewAlpha: CGFloat = 0.5
        static let buttonGroupHeight: CGFloat = 84
    }
}
