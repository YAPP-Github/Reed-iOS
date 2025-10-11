// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKCore
import SnapKit
import UIKit

final class ToastMessageView: UIView {
    // MARK: - UI Components
    private let messageLabel = BKLabel(
        fontStyle: .label1(weight: .regular),
        color: .bkBaseColor(.primary),
        alignment: .center
    )
    
    private init(message: String) {
        super.init(frame: .zero)
        self.messageLabel.setText(text: message)
        
        setupView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = UIColor(hex: "0A0A0A").withAlphaComponent(0.7)
        layer.cornerRadius = BKRadius.small
        clipsToBounds = true
        
        addSubview(messageLabel)
    }
    
    private func setupLayout() {
        messageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.verticalEdges.equalToSuperview().inset(12)
        }
    }
    
    /// 화면에 토스트 메시지를 표시하는 static 메서드
    /// - Parameters:
    ///   - message: 표시할 메시지
    ///   - duration: 메시지가 표시될 시간 (초 단위)
    static func show(message: String, duration: TimeInterval = 2.0) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        
        keyWindow.subviews.filter({ $0 is ToastMessageView }).forEach { $0.removeFromSuperview() }
        
        let toastView = ToastMessageView(message: message)
        keyWindow.addSubview(toastView)
        
        toastView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(keyWindow.safeAreaLayoutGuide.snp.bottom).inset(88)
            $0.width.equalTo(keyWindow.safeAreaLayoutGuide.snp.width).inset(36)
        }
        
        toastView.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastView.alpha = 1.0
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                    toastView.alpha = 0.0
                }) { _ in
                    toastView.removeFromSuperview()
                }
            }
        }
    }
}
