// Copyright © 2025 Booket. All rights reserved

#if DEBUG
import Pulse
import Foundation
import BKCore

enum LoggingBootstrap {
    static func install() {
        Log.setMirror { level, message, file, function, line in
            let pulseLevel: LoggerStore.Level = {
                switch level {
                case .debug: return .debug
                case .error: return .error
                }
            }()
            
            LoggerStore.shared.storeMessage(
                label: "pulse logger",
                level: pulseLevel,
                message: message,
                file: file,
                function: function,
                line: UInt(line)
            )
        }
    }
}
#endif
