// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public final class BKDialogViewController: UIViewController {
    private let dialog: BKDialog
    private let dimView: BKDimView
    
    public init(
        dialog: BKDialog,
        dimAlpha: CGFloat = 0.5
    ) {
        self.dialog = dialog
        self.dimView = BKDimView(alpha: dimAlpha)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configure()
        layout()
    }
}

private extension BKDialogViewController {
    func setup() {
        view.addSubviews(dimView, dialog)
    }
    
    func configure() {
        dimView.tapHandler = { [weak self] in
            self?.dialog.leftButtonAction()
        }
    }
    
    func layout() {
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dialog.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
    }
}

private extension BKDialogViewController {
    enum LayoutConstants {
        static let horizontalInset = BKInset.inset5
    }
}
