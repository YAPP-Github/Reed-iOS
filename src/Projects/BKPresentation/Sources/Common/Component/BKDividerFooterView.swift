// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class BKDividerFooterView: UICollectionReusableView {
    static let kind = UICollectionView.elementKindSectionFooter
    static let identifier = "BKDividerFooterView"

    override init(frame: CGRect) {
        super.init(frame: frame)

        let divider = BKDivider()
        addSubview(divider)
        
        divider.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
