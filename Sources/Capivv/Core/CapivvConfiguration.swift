import Foundation

/// Configuration for the Capivv SDK
public struct CapivvConfiguration: Sendable {
    /// Your Capivv public API key
    public let apiKey: String

    /// Base URL for the Capivv API
    public let baseURL: URL

    /// Request timeout interval
    public let timeoutInterval: TimeInterval

    /// Whether to enable debug logging
    public let debugLoggingEnabled: Bool

    /// Default production API base URL
    public static let defaultBaseURL = URL(string: "https://app.capivv.com/v1")!

    public init(
        apiKey: String,
        baseURL: URL? = nil,
        timeoutInterval: TimeInterval = 30,
        debugLoggingEnabled: Bool = false
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL ?? Self.defaultBaseURL
        self.timeoutInterval = timeoutInterval
        self.debugLoggingEnabled = debugLoggingEnabled
    }
}
