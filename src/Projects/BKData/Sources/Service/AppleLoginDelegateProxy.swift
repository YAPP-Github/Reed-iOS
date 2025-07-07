// Copyright © 2025 Booket. All rights reserved

import AuthenticationServices
import BKCore
import BKDomain
import Combine
import UIKit

final class AppleLoginDelegateProxy: NSObject {
    private var currentSubject: PassthroughSubject<String, AuthError>?
    private var currentController: ASAuthorizationController?
}

extension AppleLoginDelegateProxy {
    func startAuthorization() -> AnyPublisher<String, AuthError> {
        cancelPreviousAuthorization()

        let subject = PassthroughSubject<String, AuthError>()
        self.currentSubject = subject

        let controller = makeAuthorizationController()
        self.currentController = controller

        controller.performRequests()

        return subject
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.cleanup()
            }, receiveCancel: { [weak self] in
                self?.cleanup()
            })
            .debugError(logger: AppLogger.auth)
            .eraseToAnyPublisher()
    }
}

private extension AppleLoginDelegateProxy {
    func cancelPreviousAuthorization() {
        currentSubject?.send(completion: .failure(.sdkError(message: "이전 인증 요청 정리")))
        cleanup()
    }

    func makeAuthorizationController() -> ASAuthorizationController {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email, .fullName]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        return controller
    }

    func cleanup() {
        currentSubject = nil
        currentController = nil
    }
}

extension AppleLoginDelegateProxy: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let token = String(data: tokenData, encoding: .utf8)
        else {
            currentSubject?.send(completion: .failure(.missingToken))
            return
        }
        
        currentSubject?.send(token)
        currentSubject?.send(completion: .finished)
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        currentSubject?.send(completion: .failure(.sdkError(message: error.localizedDescription)))
    }
}

extension AppleLoginDelegateProxy: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindowInActiveScene ?? UIWindow()
    }
}
