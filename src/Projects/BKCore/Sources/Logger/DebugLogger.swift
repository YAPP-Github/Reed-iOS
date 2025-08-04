// Copyright © 2025 Booket. All rights reserved

import Foundation

#if DEBUG
    import Pulse
#endif

public func debugPulse(
    _ message: Any?...,
    function: String = #function,
    file: String = #file,
    line: UInt = #line
) {
    #if DEBUG
    LoggerStore.shared.storeMessage(
        label: "console print",
        level: .debug,
        message: message.map({ String(describing: $0) }).joined(separator: " "),
        file: file,
        function: function,
        line: line
    )
    #endif
    // QC 상황에서 디버그 출력 필요하면 추가
}
