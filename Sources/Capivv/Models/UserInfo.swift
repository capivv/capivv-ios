import Foundation

/// Information about a user
public struct UserInfo: Sendable {
    /// The user's ID in your system
    public let userId: String

    /// The user's ID in Capivv
    public let capivvUserId: String

    /// Active entitlements for this user
    public let entitlements: [Entitlement]

    /// User attributes
    public let attributes: [String: String]

    /// First seen timestamp
    public let firstSeenAt: Date

    /// Last seen timestamp
    public let lastSeenAt: Date

    public init(
        userId: String,
        capivvUserId: String,
        entitlements: [Entitlement],
        attributes: [String: String],
        firstSeenAt: Date,
        lastSeenAt: Date
    ) {
        self.userId = userId
        self.capivvUserId = capivvUserId
        self.entitlements = entitlements
        self.attributes = attributes
        self.firstSeenAt = firstSeenAt
        self.lastSeenAt = lastSeenAt
    }

    /// Check if user has a specific entitlement
    public func hasEntitlement(_ identifier: String) -> Bool {
        entitlements.contains { $0.identifier == identifier && $0.isActive }
    }
}

// MARK: - API Response Mapping

extension UserInfo {
    init(from response: UserInfoResponse) {
        self.userId = response.user.externalId
        self.capivvUserId = response.user.id
        self.entitlements = response.entitlements.map { Entitlement(from: $0) }
        self.attributes = [:]
        self.firstSeenAt = response.user.firstSeenAt
        self.lastSeenAt = response.user.lastSeenAt
    }
}

struct UserInfoResponse: Codable {
    let user: UserResponse
    let entitlements: [EntitlementResponse]
}

struct UserResponse: Codable {
    let id: String
    let externalId: String
    let firstSeenAt: Date
    let lastSeenAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case externalId = "external_id"
        case firstSeenAt = "first_seen_at"
        case lastSeenAt = "last_seen_at"
    }
}
