// Copyright © 2025 Booket. All rights reserved

import SafariServices
import UIKit

protocol URLPresenting {
    var navigationController: UINavigationController { get }
}

extension URLPresenting {
    func presentWeb(
        url: URL?
    ) {
        guard let url else { return }
        let safari = SFSafariViewController(url: url)
        navigationController.present(safari, animated: true)
    }
    
    func presentApp(
        url: URL?
    ) {
        guard let url else { return }
        
        if url.scheme?.lowercased() == "https" {
            presentWeb(url: url)
        } else if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

enum DocsType {
    case privacy
    case terms
    case licenses
    
    var url: URL? {
        switch self {
        case .privacy:
            return URL(string: "https://sites.google.com/view/reed-privacypolicy")
        case .terms:
            return URL(string: "https://sites.google.com/view/reed-termsofuse")
        case .licenses:
            return URL(string: "https://sites.google.com/view/reed-oss/")
        }
    }
}
