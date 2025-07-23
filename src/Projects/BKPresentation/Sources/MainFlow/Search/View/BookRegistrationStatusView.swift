// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

enum BookRegistrationStatus: String {
    case before = "읽기 전"
    case inProgress = "읽는 중"
    case after = "독서 완료"
}

final class BookRegistrationStatusView: UIView {
    private let stackView = UIStackView()
    private let statuses: [BookRegistrationStatus] = [.before, .inProgress, .after]
    private var buttons: [BKButton] = []
    
    var onSelected: (() -> Void)?
    
    private(set) var selectedStatus: BookRegistrationStatus? {
        didSet {
            onSelected?()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}

private extension BookRegistrationStatusView {
    func setupView() {
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.spacing = BKInset.inset2
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
                .inset(BKInset.inset5)
            $0.bottom.equalToSuperview()
                .inset(BKInset.inset3)
            $0.leading.trailing.equalToSuperview()
        }
        
        statuses.forEach { status in
            let button = BKButton.secondary(title: status.rawValue)
            button.addAction(UIAction { [weak self] _ in
                self?.select(status: status)
            }, for: .touchUpInside)
            
            button.snp.makeConstraints {
                $0.height.equalTo(LayoutConstants.buttonHeight)
            }
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }
    
    func select(status: BookRegistrationStatus) {
        selectedStatus = status
        
        for (index, btutton) in buttons.enumerated() {
            if statuses[index] == status {
                btutton.style = .tertiary
            } else {
                btutton.style = .secondary
            }
        }
    }
    
    enum LayoutConstants {
        static let buttonHeight: CGFloat = 52
    }
}
