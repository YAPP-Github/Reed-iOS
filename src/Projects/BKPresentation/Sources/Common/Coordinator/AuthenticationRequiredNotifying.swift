// Copyright © 2025 Booket. All rights reserved.

import Foundation

protocol AuthenticationRequiredNotifying: AnyObject {
    func notifyAuthenticationRequired(onFinish: (() -> Void)?)
}
