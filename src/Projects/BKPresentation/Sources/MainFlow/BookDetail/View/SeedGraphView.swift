// Copyright © 2026 Booket. All rights reserved

import BKDesign
import BKDomain
import SnapKit
import UIKit

final class SeedGraphView: BaseView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.clipsToBounds = true
        stackView.layer.cornerRadius = 6
        return stackView
    }()
    
    override func setupView() {
        addSubview(stackView)
    }
    
    override func setupLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func applyGraph(with seeds: [Seed]) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        let totalCount = CGFloat(seeds.reduce(0) { $0 + $1.count })
        
        guard totalCount > 0 else { return }
        
        for (index, seed) in seeds.enumerated() {
            let segment = UIView()
            let emotion = EmotionSeed.from(seed: seed)
            
            segment.backgroundColor = emotion?.graphTintColor ?? .lightGray
            stackView.addArrangedSubview(segment)
            
            segment.snp.makeConstraints {
                let ratio = CGFloat(seed.count) / totalCount
                
                if index < seeds.count - 1 {
                    $0.width.equalTo(stackView.snp.width).multipliedBy(ratio)
                }
            }
        }
        
        self.layoutIfNeeded()
    }
    
}
