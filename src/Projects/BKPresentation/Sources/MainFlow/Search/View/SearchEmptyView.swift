// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

final class SearchEmptyView: BaseView {
    var onActionButtonTapped: (() -> Void)?
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        return view
    }()
    
    private let contentView = UIView()
    
    private let textGroupView = UIView()
    
    private let titleLabel = BKLabel(
        text: "",
        fontStyle: .headline1(weight: .semiBold),
        color: .bkContentColor(.primary),
        alignment: .center
    )
    
    private let descriptionLabel = BKLabel(
        text: "",
        fontStyle: .body1(weight: .medium),
        color: .bkContentColor(.secondary),
        alignment: .center
    )
    
    private let actionButton: BKButton = {
        let button = BKButton(style: .secondary, size: .small)
        return button
    }()
    
    override func setupView() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(textGroupView)
        textGroupView.addSubviews(titleLabel, descriptionLabel, actionButton)
    }
    
    override func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide).priority(.low)
        }
        
        textGroupView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(BKSpacing.spacing5)
            $0.top.greaterThanOrEqualToSuperview().offset(20)
            $0.bottom.lessThanOrEqualToSuperview().inset(20)
        }
    }
    
    override func configure() {
        actionButton.addAction(UIAction { [weak self] _ in
            self?.onActionButtonTapped?()
        }, for: .touchUpInside)
    }
    
    func setContent(title: String, description: String? = nil, buttonTitle: String? = nil) {
        titleLabel.setText(text: title)
        
        if let desc = description {
            descriptionLabel.setText(text: desc)
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
        
        if let btnTitle = buttonTitle {
            actionButton.setTitle(btnTitle, for: .normal)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
        
        updateConstraintsManually(hasDescription: description != nil, hasButton: buttonTitle != nil)
    }
}

private extension SearchEmptyView {
    func updateConstraintsManually(hasDescription: Bool, hasButton: Bool) {
        let horizontalInset = BKSpacing.spacing5
        let textSpacing = BKSpacing.spacing2
        let buttonSpacing = BKSpacing.spacing5
        
        // 1. Title Label
        titleLabel.snp.remakeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            
            if !hasDescription && !hasButton {
                $0.bottom.equalToSuperview()
            }
        }
        
        // 2. Description Label
        if hasDescription {
            descriptionLabel.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(textSpacing)
                $0.leading.trailing.equalToSuperview().inset(horizontalInset)
                
                if !hasButton {
                    $0.bottom.equalToSuperview()
                }
            }
        }
        
        // 3. Action Button
        if hasButton {
            actionButton.snp.remakeConstraints {
                let topTarget = hasDescription ? descriptionLabel.snp.bottom : titleLabel.snp.bottom
                
                $0.top.equalTo(topTarget).offset(buttonSpacing)
                $0.centerX.equalToSuperview()
                
                $0.bottom.equalToSuperview()
            }
        }
    }
}
