// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public final class BKBottomSheetViewController: UIViewController {
    public var suppliedContent: UIView?
    public var button: BKButtonGroup?
    public var cornerRadius: CGFloat = BKSpacing.spacing5
    private var contentAspectRatio: CGFloat?
    
    private let style: BKBottomSheetStyle
    private let titleView: BKBottomSheetTitleView
    private var dimView: BKDimView?
    
    private let rootStack = UIStackView()
    private var innerStack: UIStackView?
    
    public init(
        title: String,
        subtitle: String? = nil,
        style: BKBottomSheetStyle = .leadingCloseButton,
        suppliedContent: UIView? = nil,
        buttonConfiguration: BKButtonGroup? = nil
    ) {
        self.style = style
        self.suppliedContent = suppliedContent
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

        if let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimView?.alpha = 0
            }, completion: { _ in
                self.dimView?.removeFromSuperview()
                self.dimView = nil
            })
        } else {
            dimView?.removeFromSuperview()
            dimView = nil
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.layoutIfNeeded()
        
        let targetWidth = rootStack.bounds.width
        let fittingSize = rootStack.systemLayoutSizeFitting(
            CGSize(
                width: targetWidth,
                height: UIView.layoutFittingCompressedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        let buttonHeight = button?.frame.height ?? 0
        let totalHeight = fittingSize.height + buttonHeight + BKSpacing.spacing5

        preferredContentSize = CGSize(
            width: view.bounds.width,
            height: totalHeight
        )
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyBottomSheetShadow(to: view)
    }
    
    public func show(from viewController: UIViewController, animated: Bool) {
        let dim = BKDimView(alpha: 0.5)
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

        dimView = dim
        setupPresentationController()
        modalPresentationStyle = .pageSheet
        viewController.present(self, animated: animated, completion: nil)
    }
}

private extension BKBottomSheetViewController {
    func setup() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = BKRadius.sheet
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        view.addSubview(rootStack)
        rootStack.axis = .vertical
        rootStack.spacing = 0
        
        titleView.onClose = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        calculateRatioIfNeeded()
        assembleContent()
        configure()
        layout()
    }
    
    func configure() {
        view.backgroundColor = .white
        
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
                $0.height.equalTo(84)
            }
        }
    }
    
    func assembleContent() {
        switch style {
        case .leadingCloseButton:
            rootStack.addArrangedSubview(titleView)
            if let suppliedContent {
                rootStack.addArrangedSubview(suppliedContent)
                if let ratio = contentAspectRatio {
                    suppliedContent.snp.makeConstraints {
                        $0.height.equalTo(suppliedContent.snp.width).multipliedBy(ratio)
                    }
                }
            }
        case .centered:
            let paddedContainer = UIView()
            let inner = UIStackView()
            inner.axis = .vertical
            inner.alignment = .fill
            inner.spacing = BKSpacing.spacing5
            paddedContainer.addSubview(inner)
            
            inner.snp.makeConstraints {
                $0.top.bottom.equalToSuperview().inset(BKInset.inset3)
                $0.leading.trailing.equalToSuperview()
            }
            
            if let suppliedContent {
                inner.addArrangedSubview(suppliedContent)
                if let ratio = contentAspectRatio {
                    suppliedContent.snp.makeConstraints {
                        $0.height.equalTo(suppliedContent.snp.width).multipliedBy(ratio)
                    }
                }
            }
            inner.addArrangedSubview(titleView)
            rootStack.addArrangedSubview(paddedContainer)
            innerStack = inner
        }

        if let button {
            view.addSubview(button)
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
        if let imageView = suppliedContent as? UIImageView,
           let image = imageView.image {
            contentAspectRatio = image.size.height / image.size.width
            imageView.contentMode = .scaleAspectFit
        }
    }
}
