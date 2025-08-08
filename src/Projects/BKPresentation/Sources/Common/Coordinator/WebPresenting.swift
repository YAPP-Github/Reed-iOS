// Copyright © 2025 Booket. All rights reserved

import SafariServices
import UIKit

protocol WebPresenting {
    var navigationController: UINavigationController { get }
}

extension WebPresenting {
    func presentWeb(
        url: URL?,
        entersReaderIfAvailable: Bool = false
    ) {
        guard let url else { return }
        let safari = SFSafariViewController(url: url)
        safari.configuration.entersReaderIfAvailable = entersReaderIfAvailable
        navigationController.present(safari, animated: true)
    }
}

enum DocsType {
    case privacy
    case terms
    case licenses
    
    var url: URL? {
        switch self {
        case .privacy:
            return URL(string: "https://clxxrlove.github.io/docs/privacy")
        case .terms:
            return URL(string: "https://clxxrlove.github.io/docs/terms")
        case .licenses:
            return URL(string: "https://clxxrlove.github.io/docs/licenses")
        }
    }
}
