import Foundation

/// Represents an entitlement that grants access to features
public struct Entitlement: Identifiable, Codable, Sendable {
    /// Unique identifier
    public let id: String

    /// The entitlement identifier (e.g., "premium", "pro_features")
    public let identifier: String

    /// Display name for the entitlement
    public let displayName: String

    /// Whether this entitlement is currently active
    public let isActive: Bool

    /// When this entitlement expires (nil for lifetime)
    public let expiresAt: Date?

    /// Source of the entitlement (purchase or grant)
    public let source: EntitlementSource

    /// Product ID that granted this entitlement (if from purchase)
    public let productId: String?

    public init(
        id: String,
        identifier: String,
        displayName: String,
        isActive: Bool,
        expiresAt: Date?,
        source: EntitlementSource,
        productId: String?
    ) {
        self.id = id
        self.identifier = identifier
        self.displayName = displayName
        self.isActive = isActive
        self.expiresAt = expiresAt
        self.source = source
        self.productId = productId
    }
}

/// Source of an entitlement
public enum EntitlementSource: String, Codable, Sendable {
    case purchase
    case grant
}

// MARK: - API Response Mapping

extension Entitlement {
    init(from response: EntitlementResponse) {
        self.id = response.identifier
        self.identifier = response.identifier
        self.displayName = response.identifier
        self.isActive = response.isActive
        self.expiresAt = response.expiresAt
        self.source = EntitlementSource(rawValue: response.source) ?? .purchase
        self.productId = nil
    }
}

struct EntitlementResponse: Codable {
    let identifier: String
    let isActive: Bool
    let expiresAt: Date?
    let source: String

    enum CodingKeys: String, CodingKey {
        case identifier
        case isActive = "is_active"
        case expiresAt = "expires_at"
        case source
    }
}
