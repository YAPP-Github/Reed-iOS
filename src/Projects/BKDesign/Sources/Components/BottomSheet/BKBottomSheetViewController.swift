// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public final class BKBottomSheetViewController: UIViewController, BKBottomSheetProtocol {
    public var titleStyle: BKBottomSheetTitleStyle
    public var contentView: UIView
    public var buttonConfiguration: BKButtonGroup?
    public var isDismissible: Bool = true
    public var cornerRadius: CGFloat = BKSpacing.spacing5
    public var preferredHeight: BKBottomSheetHeight
    
    private let containerView = UIStackView()
    private let titleView: BKBottomSheetTitleView
    
    private var currentHeight : CGFloat = 500
    
    public init(
        titleStyle: BKBottomSheetTitleStyle,
        contentView: UIView,
        buttonConfiguration: BKButtonGroup? = nil,
        preferredHeight: BKBottomSheetHeight = .automatic
    ) {
        self.titleStyle = titleStyle
        self.contentView = contentView
        self.buttonConfiguration = buttonConfiguration
        self.titleView = BKBottomSheetTitleView(style: titleStyle)
        self.preferredHeight = preferredHeight
        
        super.init(nibName: nil, bundle: nil)
        
        self.titleView.onClose = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        modalPresentationStyle = .pageSheet
        setupPresentationController()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if case .automatic = preferredHeight {
            DispatchQueue.main.async { [weak self] in
                self?.updateSheetHeight()
            }
        }

        applyBottomSheetShadow(to: view)
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(containerView)
        
        containerView.axis = .vertical
        containerView.spacing = 0
        containerView.alignment = .fill
        containerView.distribution = .fill
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(BKSpacing.spacing5)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        containerView.addArrangedSubview(titleView)

        containerView.addArrangedSubview(contentView)
        
        if let buttons = buttonConfiguration {
            containerView.addArrangedSubview(buttons)
        }
    }
    
    private func applyBottomSheetShadow(to view: UIView) {
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
    
    private func setupPresentationController() {
        guard let sheet = sheetPresentationController else { return }
        
        switch preferredHeight {
        case .automatic:
            sheet.detents = [.custom { _ in 500 }]
        case .fixed(let height):
            currentHeight = height
            sheet.detents = [.custom { _ in height }]
        }

        isModalInPresentation = true
        sheet.prefersGrabberVisible = false
        sheet.preferredCornerRadius = cornerRadius
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        sheet.prefersEdgeAttachedInCompactHeight = true
        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        sheet.largestUndimmedDetentIdentifier = nil
    }
    
    private func updateSheetHeight() {
        let newHeight = calculateSheetHeight()
        guard newHeight != currentHeight else { return }

        currentHeight = newHeight
        
        if let sheet = sheetPresentationController {
            sheet.animateChanges {
                sheet.detents = [.custom { _ in newHeight }]
            }
        }
    }

    private func calculateSheetHeight() -> CGFloat {
        view.layoutIfNeeded()

        let titleHeight = titleView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        let contentHeight = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        let buttonHeight = buttonConfiguration?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height ?? 0

        return titleHeight + contentHeight + buttonHeight + 20
    }
    
    public func show(from viewController: UIViewController, animated: Bool) {
        viewController.present(self, animated: animated, completion: nil)
    }
    
}
