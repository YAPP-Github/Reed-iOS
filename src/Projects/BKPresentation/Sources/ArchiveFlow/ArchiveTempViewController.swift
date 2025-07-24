// Copyright © 2025 Booket. All rights reserved

import UIKit
import SnapKit

final class ArchiveTempViewController: UIViewController {
    weak var coordinator: ArchiveCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "내 서재"
        
        // 임시 라벨 추가
        let label = UILabel()
        label.text = "내 서재 화면"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
