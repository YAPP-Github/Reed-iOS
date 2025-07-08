// Copyright © 2025 Booket. All rights reserved

import AuthenticationServices
import BKDomain
import Foundation
import SnapKit
import UIKit

protocol LoginViewDelegate: AnyObject {
    func loginViewDidTapLoginButton(
        _ view: LoginView,
        provider: AuthProvider
    )
}

final class LoginView: BaseView {
    weak var delegate: LoginViewDelegate?
    
    private let loginStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 아무 것도 안 함"
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let appleSignInButton = ASAuthorizationAppleIDButton(
        authorizationButtonType: .signIn,
        authorizationButtonStyle: .black
    )
    
    private let kakaoSignInButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .yellow
        button.setTitle("카카오톡으로 로그인", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = LayoutConstants.buttonCornerRadius
        return button
    }()
    
    override func setupView() {
        [
            loginStatusLabel,
            appleSignInButton,
            kakaoSignInButton
        ].forEach(addSubview)
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
        loginStatusLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
                .offset(LayoutConstants.labelTopOffset)
        }
        
        kakaoSignInButton.snp.makeConstraints {
            $0.height.equalTo(LayoutConstants.buttonHeight)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.bottom.equalToSuperview()
                .inset(LayoutConstants.bottomInset)
        }
        
        appleSignInButton.snp.makeConstraints {
            $0.height.equalTo(LayoutConstants.buttonHeight)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.bottom.equalTo(kakaoSignInButton.snp.top)
                .offset(-LayoutConstants.buttonSpacing)
        }
    }
    
    func updateStatusView(
        provider: String,
        status: Bool
    ) {
        loginStatusLabel.text = """
        최근 시도한 OAuth Provider: \(provider)
        로그인 상태: \(status)
        """
    }
}

private extension LoginView {
    @objc func handleAppleSignInButtonTap() {
        delegate?.loginViewDidTapLoginButton(self, provider: .apple)
    }
    
    @objc func handleKakaoSignInButtonTap() {
        delegate?.loginViewDidTapLoginButton(self, provider: .kakao)
    }
}

private extension LoginView {
    enum LayoutConstants {
        static let horizontalInset: CGFloat = 20
        static let bottomInset: CGFloat = 32
        static let buttonHeight: CGFloat = 52
        static let buttonSpacing: CGFloat = 8
        static let buttonCornerRadius: CGFloat = 8
        static let labelTopOffset: CGFloat = 150
    }
}
