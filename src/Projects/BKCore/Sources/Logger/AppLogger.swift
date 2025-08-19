// Copyright © 2025 Booket. All rights reserved

import OSLog

public enum AppLogger {
    private static let subsystem = "Booket.26th.yapp"

    public static let auth = Logger(subsystem: subsystem, category: "auth")
    public static let network = Logger(subsystem: subsystem, category: "network")
    public static let ui = Logger(subsystem: subsystem, category: "ui")
    public static let storage = Logger(subsystem: subsystem, category: "storage")
    public static let viewModel = Logger(subsystem: subsystem, category: "viewModel")
    public static let database = Logger(subsystem: subsystem, category: "database")
}

public enum Log {
    public enum Level { case debug, error }

    public typealias Mirror = (
        _ level: Level,
        _ message: String,
        _ file: String,
        _ function: String,
        _ line: Int
    ) -> Void

    private static var mirror: Mirror?

    public static func setMirror(_ newMirror: Mirror?) { mirror = newMirror }
    
    public static func debug(
        _ message: String,
        logger: Logger,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        logger.debug("\(message, privacy: .public) [\(file):\(line) \(function)]")
        mirror?(.debug, message, file, function, line)
    }

    public static func error(
        _ message: String,
        logger: Logger,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        logger.error("\(message, privacy: .public) [\(file):\(line) \(function)]")
        mirror?(.error, message, file, function, line)
    }
}
