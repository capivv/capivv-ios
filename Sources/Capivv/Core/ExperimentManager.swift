import Foundation

/// Manages A/B test experiment assignments and tracking
@MainActor
public final class ExperimentManager: ObservableObject {
    private let api: CapivvAPI
    private weak var capivv: Capivv?

    /// Cached experiment assignments
    @Published public private(set) var assignments: [String: ExperimentVariant] = [:]

    init(api: CapivvAPI, capivv: Capivv) {
        self.api = api
        self.capivv = capivv
    }

    // MARK: - Public API

    /// Get the assigned variant for an experiment
    /// - Parameter experimentId: The experiment identifier
    /// - Returns: The assigned variant
    public func getVariant(experimentId: String) async throws -> ExperimentVariant {
        // Return cached assignment if available
        if let cached = assignments[experimentId] {
            return cached
        }

        guard let userId = capivv?.userId else {
            throw CapivvError.notLoggedIn
        }

        let variant = try await api.getExperimentAssignment(experimentId: experimentId, userId: userId)
        assignments[experimentId] = variant

        Logger.info("Experiment \(experimentId) assigned variant: \(variant.variantName)")

        return variant
    }

    /// Track a conversion event for an experiment
    /// - Parameters:
    ///   - experimentId: The experiment identifier
    ///   - event: The conversion event name (default: "conversion")
    ///   - value: Optional numeric value associated with the conversion
    public func trackConversion(
        experimentId: String,
        event: String = "conversion",
        value: Double? = nil
    ) async throws {
        guard let variant = assignments[experimentId] else {
            throw CapivvError.experimentNotAssigned
        }

        guard let userId = capivv?.userId else {
            throw CapivvError.notLoggedIn
        }

        try await api.trackExperimentConversion(
            variantId: variant.variantId,
            userId: userId,
            event: event,
            value: value
        )

        Logger.info("Tracked conversion for experiment \(experimentId): \(event)")
    }

    /// Get a string value from experiment metadata
    /// - Parameters:
    ///   - key: The metadata key
    ///   - experimentId: The experiment identifier
    ///   - default: Default value if not found
    /// - Returns: The string value or default
    public func getString(
        _ key: String,
        experimentId: String,
        default defaultValue: String = ""
    ) async -> String {
        guard let variant = try? await getVariant(experimentId: experimentId) else {
            return defaultValue
        }
        return variant.getString(key, default: defaultValue)
    }

    /// Get an integer value from experiment metadata
    /// - Parameters:
    ///   - key: The metadata key
    ///   - experimentId: The experiment identifier
    ///   - default: Default value if not found
    /// - Returns: The integer value or default
    public func getInt(
        _ key: String,
        experimentId: String,
        default defaultValue: Int = 0
    ) async -> Int {
        guard let variant = try? await getVariant(experimentId: experimentId) else {
            return defaultValue
        }
        return variant.getInt(key, default: defaultValue)
    }

    /// Get a boolean value from experiment metadata
    /// - Parameters:
    ///   - key: The metadata key
    ///   - experimentId: The experiment identifier
    ///   - default: Default value if not found
    /// - Returns: The boolean value or default
    public func getBool(
        _ key: String,
        experimentId: String,
        default defaultValue: Bool = false
    ) async -> Bool {
        guard let variant = try? await getVariant(experimentId: experimentId) else {
            return defaultValue
        }
        return variant.getBool(key, default: defaultValue)
    }

    /// Check if user is in the control group for an experiment
    /// - Parameter experimentId: The experiment identifier
    /// - Returns: Whether the user is in the control group
    public func isControl(experimentId: String) async -> Bool {
        guard let variant = try? await getVariant(experimentId: experimentId) else {
            return true // Default to control behavior if assignment fails
        }
        return variant.isControl
    }

    /// Clear cached assignments (e.g., on logout)
    public func clearCache() {
        assignments.removeAll()
        Logger.debug("Experiment assignments cache cleared")
    }
}
