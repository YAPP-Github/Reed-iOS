// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public final class BKPageControl: UIControl {
    public var numberOfPages: Int = 0 {
        didSet {
            setupIndicators()
        }
    }
    
    public var currentPage: Int = 0 {
        didSet {
            updateIndicators()
            sendActions(for: .valueChanged)
        }
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = LayoutConstants.spacing
        return stackView
    }()
    
    private var indicatorViews: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BKPageControl {
    func setupStackView() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(LayoutConstants.barHeight)
        }
    }
    
    func setupIndicators() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        indicatorViews.removeAll()
        
        (0..<numberOfPages).forEach { _ in
            let bar = UIView()
            bar.layer.cornerRadius = LayoutConstants.barHeight / 2
            bar.backgroundColor = .bkBackgroundColor(.disable)
            indicatorViews.append(bar)
            stackView.addArrangedSubview(bar)
        }
        
        updateIndicators()
    }
    
    func updateIndicators() {
        indicatorViews.enumerated().forEach { index, view in
            view.backgroundColor =
                index <= currentPage ? .bkBackgroundColor(.primary) : .bkBackgroundColor(.disable)
        }
    }
}

private extension BKPageControl {
    enum LayoutConstants {
        static let spacing = BKSpacing.spacing1
        static let barHeight: CGFloat = 6
    }
}
