import Foundation

/// Tracks analytics events for paywalls and other features
@MainActor
public final class EventTracker {
    private let api: CapivvAPI
    private weak var capivv: Capivv?

    /// Current session ID for event correlation
    private var sessionId: String = UUID().uuidString

    init(api: CapivvAPI, capivv: Capivv) {
        self.api = api
        self.capivv = capivv
    }

    // MARK: - Paywall Events

    /// Track a paywall view event
    /// - Parameters:
    ///   - paywallId: The paywall identifier
    ///   - variant: A/B test variant (if applicable)
    public func trackPaywallView(paywallId: String, variant: String? = nil) async {
        guard let userId = capivv?.userId else {
            Logger.warning("Cannot track paywall view: user not logged in")
            return
        }

        let event = PaywallEvent(
            type: .view,
            variant: variant,
            sessionId: sessionId
        )

        do {
            try await api.trackPaywallEvent(paywallId: paywallId, event: event, userId: userId)
            Logger.debug("Tracked paywall view: \(paywallId)")
        } catch {
            Logger.error("Failed to track paywall view: \(error)")
        }
    }

    /// Track a paywall conversion (purchase initiated from paywall)
    /// - Parameters:
    ///   - paywallId: The paywall identifier
    ///   - packageId: The purchased package identifier
    ///   - variant: A/B test variant (if applicable)
    public func trackPaywallConversion(
        paywallId: String,
        packageId: String,
        variant: String? = nil
    ) async {
        guard let userId = capivv?.userId else {
            Logger.warning("Cannot track paywall conversion: user not logged in")
            return
        }

        let event = PaywallEvent(
            type: .conversion,
            variant: variant,
            packageId: packageId,
            sessionId: sessionId
        )

        do {
            try await api.trackPaywallEvent(paywallId: paywallId, event: event, userId: userId)
            Logger.debug("Tracked paywall conversion: \(paywallId)")
        } catch {
            Logger.error("Failed to track paywall conversion: \(error)")
        }
    }

    /// Track a paywall close event
    /// - Parameters:
    ///   - paywallId: The paywall identifier
    ///   - variant: A/B test variant (if applicable)
    public func trackPaywallClose(paywallId: String, variant: String? = nil) async {
        guard let userId = capivv?.userId else {
            Logger.warning("Cannot track paywall close: user not logged in")
            return
        }

        let event = PaywallEvent(
            type: .close,
            variant: variant,
            sessionId: sessionId
        )

        do {
            try await api.trackPaywallEvent(paywallId: paywallId, event: event, userId: userId)
            Logger.debug("Tracked paywall close: \(paywallId)")
        } catch {
            Logger.error("Failed to track paywall close: \(error)")
        }
    }

    /// Track a restore purchases tap from paywall
    /// - Parameters:
    ///   - paywallId: The paywall identifier
    ///   - variant: A/B test variant (if applicable)
    public func trackPaywallRestoreTapped(paywallId: String, variant: String? = nil) async {
        guard let userId = capivv?.userId else {
            Logger.warning("Cannot track restore tap: user not logged in")
            return
        }

        let event = PaywallEvent(
            type: .restoreTapped,
            variant: variant,
            sessionId: sessionId
        )

        do {
            try await api.trackPaywallEvent(paywallId: paywallId, event: event, userId: userId)
            Logger.debug("Tracked paywall restore tap: \(paywallId)")
        } catch {
            Logger.error("Failed to track restore tap: \(error)")
        }
    }

    // MARK: - Session Management

    /// Start a new tracking session
    /// Call this when a new paywall or flow is presented
    public func startNewSession() {
        sessionId = UUID().uuidString
        Logger.debug("Started new tracking session: \(sessionId)")
    }

    /// Get the current session ID
    public var currentSessionId: String {
        sessionId
    }
}
