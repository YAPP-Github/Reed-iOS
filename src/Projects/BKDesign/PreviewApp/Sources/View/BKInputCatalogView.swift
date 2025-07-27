// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class BKInputCatalogView: BaseView {
    private let contentView = UIView()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = BKSpacing.spacing5
        stackView.alignment = .fill
        return stackView
    }()
    
    private let mediumLabel = BKLabel(
        text: "Medium Label",
        type: .medium
    )
    
    private let smallLabel = BKLabel(
        text: "small label",
        type: .small
    )
    
    private let labelDivider = BKDivider(type: .medium)
    private let checkBoxStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = BKSpacing.spacing2
        stackView.alignment = .leading
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    private let rectangleCheckBox = BKCheckBox(type: .rectangle)
    private let roundCheckBox = BKCheckBox(type: .round)
    private let checkBoxSpacer = UIView()
    
    private let checkBoxDivider = BKDivider(type: .medium)
    
    private let normalBaseTextField = BKBaseTextField(
        placeholder: "여기에 텍스트가 들어갑니다.",
        type: .normal
    )
    
    private let brandBaseTextField = BKBaseTextField(
        placeholder: "여기에 텍스트가 들어갑니다.",
        type: .brand
    )
    
    private let errorBaseTextField = BKBaseTextField(
        placeholder: "여기에 텍스트가 들어갑니다.",
        type: .error
    )
    
    private let searchTextFieldDivider = BKDivider(type: .small)
    
    private let searchTextField = BKSearchTextField(
        placeholder: "여기에 텍스트가 들어갑니다.",
        type: .brand
    )
    
    private let textFieldDivider = BKDivider(type: .small)
    
    private let textField = BKTextFieldView(
        labelText: "BKTextField",
        placeholder: "여기에 텍스트가 들어갑니다.",
        helpMessage: "Help message",
        isError: false
    )
    
    private let textFieldWithError = BKTextFieldView(
        labelText: "BKTextField",
        placeholder: "에러가 발생한 TextField.",
        helpMessage: "Help message",
        isError: true
    )
    
    private let textViewDivider = BKDivider(type: .small)
    
    private let textView = BKTextView(
        labelText: "BKTextView",
        placeholder: "여기에 텍스트가 들어갑니다."
    )
    
    private let textViewWithError = BKTextView(
        labelText: "BKTextView",
        placeholder: "여기에 텍스트가 들어갑니다."
    )
    
    override func setupView() {
        addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        stackView.addArrangedSubview(mediumLabel)
        stackView.addArrangedSubview(smallLabel)
        stackView.addArrangedSubview(labelDivider)

        checkBoxStackView.addArrangedSubview(rectangleCheckBox)
        checkBoxStackView.addArrangedSubview(roundCheckBox)
        checkBoxStackView.addArrangedSubview(checkBoxSpacer)
        stackView.addArrangedSubview(checkBoxStackView)
        
        stackView.addArrangedSubview(checkBoxDivider)

        stackView.addArrangedSubview(normalBaseTextField)
        stackView.addArrangedSubview(brandBaseTextField)
        stackView.addArrangedSubview(errorBaseTextField)

        stackView.addArrangedSubview(searchTextFieldDivider)
        
        stackView.addArrangedSubview(searchTextField)

        stackView.addArrangedSubview(textFieldDivider)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(textFieldWithError)
        
        stackView.addArrangedSubview(textViewDivider)
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(textViewWithError)
        textViewWithError.setErrorMessage("Help message")
    }

    override func configure() {
        backgroundColor = .white
    }

    override func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
                .inset(BKInset.inset5)
        }
    }
}
