// Copyright © 2026 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import UIKit

final class DefaultExternalLinkRepository: ExternalLinkRepository {
    func open(_ urlString: String) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            guard let url = URL(string: urlString) else {
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
