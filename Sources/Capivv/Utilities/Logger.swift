import Foundation
import os.log

/// Internal logger for the Capivv SDK
enum Logger {
    private static let subsystem = "com.capivv.sdk"
    private static let logger = os.Logger(subsystem: subsystem, category: "Capivv")

    static func debug(_ message: String) {
        #if DEBUG
        logger.debug("[\("Capivv")] \(message)")
        #endif
    }

    static func info(_ message: String) {
        logger.info("[\("Capivv")] \(message)")
    }

    static func warning(_ message: String) {
        logger.warning("[\("Capivv")] \(message)")
    }

    static func error(_ message: String) {
        logger.error("[\("Capivv")] \(message)")
    }
}
