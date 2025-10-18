// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class SentenceListCell: UICollectionViewCell {
    
    private let sentenceLabel = BKLabel(
        text: "",
        fontStyle: .body1(weight: .regular),
        color: .bkContentColor(.primary),
        alignment: .left
    )
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        updateSelectionState(isSelected: false)
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .bkBaseColor(.primary)
        contentView.backgroundColor = .bkBackgroundColor(.secondary)
        contentView.layer.cornerRadius = 8
        
        sentenceLabel.numberOfLines = 0
        sentenceLabel.lineBreakMode = .byWordWrapping
        
        contentView.addSubview(sentenceLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        sentenceLabel.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.verticalEdges.equalToSuperview().inset(12)
        }
    }
    
    // MARK: - Configuration
    func configure(with sentence: RecognizedTextViewModel.SentenceItem) {
        sentenceLabel.setText(text: sentence.text)
        sentenceLabel.setColor(color: .bkContentColor(.primary))
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.updateSelectionState(isSelected: sentence.isSelected)
        }
    }
    
    private func updateSelectionState(isSelected: Bool) {
        if isSelected {
            sentenceLabel.setFontStyle(style: .body1(weight: .medium))
            contentView.backgroundColor = .bkBackgroundColor(.tertiary)
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.bkBorderColor(.brand).cgColor
        } else {
            sentenceLabel.setFontStyle(style: .body1(weight: .regular))
            contentView.backgroundColor = .bkBackgroundColor(.secondary)
            contentView.layer.borderColor = UIColor.clear.cgColor
        }
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
}
