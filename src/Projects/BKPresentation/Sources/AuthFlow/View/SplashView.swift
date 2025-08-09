// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

final class SplashView: UIView {
    private let logoImageView = UIView()
    private let imageView = UIImageView(image: BKImage.Logos.bigLogo)
    private let sloganLabel = BKLabel(
        text: "책 덮기 전 한 문장을 기록해보세요",
        fontStyle: .headline2(weight: .semiBold),
        color: .bkBaseColor(.primary)
    )
    
    func setupView() {
        logoImageView.backgroundColor = .clear
        
        backgroundColor = .bkContentColor(.brand)
        imageView.tintColor = .bkBaseColor(.primary)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        
        logoImageView.addSubviews(imageView, sloganLabel)
        addSubview(logoImageView)
    }
    
    func setLayout() {
        logoImageView.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        sloganLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().inset(32)
        }
    }
}
