// Copyright © 2026 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import UIKit

final class DefaultExternalLinkRepository: ExternalLinkRepository {
    func canOpen(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            Log.error("유효하지 않은 URL 형식: \(urlString)", logger: AppLogger.network)
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func open(_ urlString: String) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            guard let url = URL(string: urlString) else {
                Log.error("URL 객체 생성 실패: \(urlString)", logger: AppLogger.network)
                promise(.success(false))
                return
            }
            
            DispatchQueue.main.async {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:]) { success in
                        promise(.success(success))
                    }
                } else {
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
