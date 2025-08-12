// Copyright © 2025 Booket. All rights reserved

import UIKit
import BKDesign
import SnapKit

final class BKChipDemoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .bkBaseColor(.primary)
        title = "BKChip Demo"
        
        // 비활성화된 칩
        let inactiveChip = BKChip(title: "비활성화", count: 5) {
            #if DEBUG
            print("비활성화 칩 탭됨 - 현재 상태: 비활성화")
            #endif
        }
        
        // 활성화된 칩
        let activeChip = BKChip(title: "활성화", count: 3) {
            #if DEBUG
            print("활성화 칩 탭됨 - 현재 상태: 활성화")
            #endif
        }
        activeChip.isSelected = true
        
        view.addSubviews(inactiveChip, activeChip)
        
        inactiveChip.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-30)
        }
        
        activeChip.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(30)
        }
    }
}