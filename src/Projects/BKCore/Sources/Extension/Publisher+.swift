// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation
import OSLog

public extension Publisher {
    func debugError(
        _ label: String = "",
        logger: Logger,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveCompletion: { completion in
            guard case let .failure(error) = completion else { return }
            Log.error(
                "[Combine Error] \(label) ↳ error: \(error)",
                logger: logger,
                file: file,
                function: function,
                line: line
            )
        })
    }
}
