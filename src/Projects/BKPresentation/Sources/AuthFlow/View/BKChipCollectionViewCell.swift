// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class BKChipCollectionViewCell: UICollectionViewCell {
    static let identifier = "BKChipCollectionViewCell"
    
    private let chip = BKChip(title: "")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(chip)
        chip.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(with data: ChipData) {
        chip.title = data.title
        chip.count = data.count
        chip.isSelected = data.isSelected
    }
}
