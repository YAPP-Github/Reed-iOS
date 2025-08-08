// Copyright © 2025 Booket. All rights reserved

import AuthenticationServices
import BKDesign
import BKDomain
import Combine
import Foundation
import SnapKit
import UIKit

enum LoginViewEvent {
    case loginButtonTapped(AuthProvider)
}

final class LoginView: BaseView {
    let eventPublisher = PassthroughSubject<LoginViewEvent, Never>()
    
    private let logoImageView = UIView()
    private let imageView = UIImageView(image: BKImage.Logos.bigLogo)
    private let sloganLabel = BKLabel(
        text: "책 덮기 전 한 문장을 기록해보세요",
        fontStyle: .headline2(weight: .semiBold),
        color: .bkContentColor(.brand)
    )

    private let appleSignInButton = BKButton(
        style: .custom(
            background: .solid(UIColor(hex: "000000")),
            foreground: .solid(.bkContentColor(.inverse))
        ),
        size: .large
    )
    
    private let kakaoSignInButton = BKButton(
        style: .custom(
            background: .solid(UIColor(hex: "FFEB00")),
            foreground: .solid(.bkContentColor(.primary))
        ),
        size: .large
    )
    
    override func setupView() {
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        logoImageView.backgroundColor = .clear
        
        appleSignInButton.title = "Apple로 시작하기"
        appleSignInButton.leftIcon = BKImage.Icon.apple

        kakaoSignInButton.title = "카카오로 시작하기"
        kakaoSignInButton.leftIcon = BKImage.Icon.kakao
        
        logoImageView.addSubviews(imageView, sloganLabel)
        
        addSubviews(logoImageView, appleSignInButton, kakaoSignInButton)
    }
    
    override func configure() {
        appleSignInButton.addTarget(
            self,
            action: #selector(handleAppleSignInButtonTap),
            for: .touchUpInside
        )
        
        kakaoSignInButton.addTarget(
            self,
            action: #selector(handleKakaoSignInButtonTap),
            for: .touchUpInside
        )
    }
    
    override func setupLayout() {
        kakaoSignInButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
                .inset(LayoutConstants.bottomInset)
        }
        
        appleSignInButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.bottom.equalTo(kakaoSignInButton.snp.top)
                .offset(-LayoutConstants.buttonSpacing)
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(LayoutConstants.imageTopInset)
        }
        
        sloganLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(LayoutConstants.horizontalInset)
        }
        
        logoImageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(LayoutConstants.logoHeight)
            $0.bottom.equalTo(appleSignInButton.snp.top)
                .offset(-LayoutConstants.logoBottomOffset)
        }
    }
}

private extension LoginView {
    @objc func handleAppleSignInButtonTap() {
        eventPublisher.send(.loginButtonTapped(.apple))
    }
    
    @objc func handleKakaoSignInButtonTap() {
        eventPublisher.send(.loginButtonTapped(.kakao))
    }
}

private extension LoginView {
    enum LayoutConstants {
        static let horizontalInset: CGFloat = BKSpacing.spacing5
        static let bottomInset: CGFloat = BKSpacing.spacing8
        static let buttonSpacing: CGFloat = BKSpacing.spacing2
        static let logoBottomOffset: CGFloat = 200
        static let logoHeight: CGFloat = 200
        static let imageTopInset: CGFloat = 44.5
    }
}
