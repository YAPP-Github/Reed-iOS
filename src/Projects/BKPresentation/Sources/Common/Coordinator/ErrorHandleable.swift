// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import UIKit

protocol ErrorHandleable: AnyObject {}

extension ErrorHandleable where Self: Coordinator & AuthenticationRequiredNotifying {
    func handleError(_ error: DomainError) {
        switch error {
        case .unauthorized:
            if AccessModeCenter.shared.mode.value == .member {
                presentAuthErrorAlert()
            } else {
                presentGuestAuthErrorAlert()
            }
        case .internalServerError, .clientError:
            presentServerErrorAlert()
        case .timeout:
            presentTimeoutAlert()
        }
    }
}

extension ErrorHandleable where Self: Coordinator {
    func presentCustomErrorAlert(
        title: String = "",
        subtitle: String,
        confirmTitle: String = "재시도",
        onConfirm: @escaping () -> Void
    ) {
        let dialog = BKDialog(
            title: title,
            subtitle: subtitle,
            config: .init(
                leftButtonTitle: confirmTitle,
                leftButtonAction: { [weak self] in
                    guard let self else { return }
                    self.presentedViewController?.dismiss(animated: true) {
                        onConfirm()
                    }
                }
            )
        )
        let dialogViewController = BKDialogViewController(dialog: dialog)
        topViewController?.present(dialogViewController, animated: true)
    }
}

private extension ErrorHandleable where Self: Coordinator & AuthenticationRequiredNotifying {
    private func presentAuthErrorAlert() {
        let dialog = BKDialog(
            title: "",
            subtitle: """
            세션이 만료되었어요.
            다시 로그인 해주세요
            """,
            config: .init(
                leftButtonTitle: "확인",
                leftButtonAction: { [weak self] in
                    self?.presentedViewController?.dismiss(animated: true)
                    self?.notifyAuthenticationRequired {}
                })
            )
        
        let dialogViewController = BKDialogViewController(dialog: dialog)
        topViewController?.present(dialogViewController, animated: true)
    }
    
    private func presentGuestAuthErrorAlert() {
        let dialog = BKDialog(
            title: "",
            subtitle: """
            로그인이 필요한 기능입니다.
            로그인 해주세요
            """,
            config: .init(
                leftButtonTitle: "닫기",
                leftButtonAction: { [weak self] in
                    self?.presentedViewController?.dismiss(animated: true)
                },
                rightButtonTitle: "로그인하기",
                rightButtonAction: { [weak self] in
                    self?.presentedViewController?.dismiss(animated: true)
                    self?.notifyAuthenticationRequired(onFinish: nil)
                })
            )
        
        let dialogViewController = BKDialogViewController(dialog: dialog)
        topViewController?.present(dialogViewController, animated: true)
    }
    
    private func presentServerErrorAlert() {
        let dialog = BKDialog(
            title: "",
            subtitle: """
            알 수 없는 문제가 발생했어요.
            다시 시도해주세요
            """,
            config: .init(
                leftButtonTitle: "확인",
                leftButtonAction: { [weak self] in
                    self?.presentedViewController?.dismiss(animated: true)
                })
            )
        
        let dialogViewController = BKDialogViewController(dialog: dialog)
        topViewController?.present(dialogViewController, animated: true)
    }
    
    private func presentTimeoutAlert() {
        let dialog = BKDialog(
            title: "",
            subtitle: """
            네트워크 연결이 불안정합니다.
            인터넷 연결을 확인해주세요
            """,
            config: .init(
                leftButtonTitle: "확인",
                leftButtonAction: { [weak self] in
                    self?.presentedViewController?.dismiss(animated: true)
                })
            )
        
        let dialogViewController = BKDialogViewController(dialog: dialog)
        topViewController?.present(dialogViewController, animated: true)
    }
}
