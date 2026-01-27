import Foundation

// MARK: - Public Types

/// A promotional campaign
public struct Promotion: Codable, Sendable, Identifiable {
    /// Unique identifier
    public let id: String

    /// Promotion identifier/code
    public let identifier: String

    /// Display name
    public let name: String

    /// Description text
    public let description: String?

    /// Campaign type
    public let campaignType: CampaignType

    /// Discount percentage
    public let discountPercent: Decimal

    /// Fixed discount amount (formatted string)
    public let discountFixedFormatted: String?

    /// Products this promotion applies to
    public let applicableProductIds: [String]

    /// Entitlements this promotion applies to
    public let applicableEntitlementIds: [String]

    /// When the promotion starts
    public let startsAt: Date

    /// When the promotion ends
    public let endsAt: Date

    /// Promotional code (if code-based)
    public let code: String?

    /// Whether this promotion is currently active
    public var isActive: Bool {
        let now = Date()
        return now >= startsAt && now <= endsAt
    }

    /// Time remaining in the promotion
    public var timeRemaining: TimeInterval? {
        guard isActive else { return nil }
        return endsAt.timeIntervalSince(Date())
    }

    public init(
        id: String,
        identifier: String,
        name: String,
        description: String? = nil,
        campaignType: CampaignType,
        discountPercent: Decimal,
        discountFixedFormatted: String? = nil,
        applicableProductIds: [String] = [],
        applicableEntitlementIds: [String] = [],
        startsAt: Date,
        endsAt: Date,
        code: String? = nil
    ) {
        self.id = id
        self.identifier = identifier
        self.name = name
        self.description = description
        self.campaignType = campaignType
        self.discountPercent = discountPercent
        self.discountFixedFormatted = discountFixedFormatted
        self.applicableProductIds = applicableProductIds
        self.applicableEntitlementIds = applicableEntitlementIds
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.code = code
    }
}

/// Type of promotional campaign
public enum CampaignType: String, Codable, Sendable {
    /// Limited-time flash sale
    case flashSale = "flash_sale"
    /// Product bundle discount
    case bundle
    /// Referral reward
    case referral
    /// Segment-targeted promotion
    case segment
}

/// Result of redeeming a promotion
public struct RedemptionResult: Codable, Sendable {
    /// Whether redemption succeeded
    public let success: Bool

    /// Message to display
    public let message: String

    /// Discount amount applied (formatted string)
    public let discountAppliedFormatted: String?

    /// Updated entitlements after redemption
    public let entitlements: [Entitlement]?

    public init(
        success: Bool,
        message: String,
        discountAppliedFormatted: String? = nil,
        entitlements: [Entitlement]? = nil
    ) {
        self.success = success
        self.message = message
        self.discountAppliedFormatted = discountAppliedFormatted
        self.entitlements = entitlements
    }
}

// MARK: - API Response Mapping

extension Promotion {
    init(from response: PromotionResponse) {
        self.id = response.id
        self.identifier = response.identifier
        self.name = response.name
        self.description = response.description
        self.campaignType = CampaignType(rawValue: response.campaignType) ?? .segment
        self.discountPercent = Decimal(response.discountPercent)
        self.discountFixedFormatted = response.discountFixedFormatted
        self.applicableProductIds = response.productIds ?? []
        self.applicableEntitlementIds = response.entitlementIds ?? []
        self.startsAt = response.startsAt
        self.endsAt = response.endsAt
        self.code = response.code
    }
}

extension RedemptionResult {
    init(from response: RedemptionResultResponse) {
        self.success = response.success
        self.message = response.message
        self.discountAppliedFormatted = response.discountAppliedFormatted
        self.entitlements = response.entitlements?.map { Entitlement(from: $0) }
    }
}

// MARK: - Response Types

struct PromotionResponse: Codable {
    let id: String
    let identifier: String
    let name: String
    let description: String?
    let campaignType: String
    let discountPercent: Double
    let discountFixedFormatted: String?
    let productIds: [String]?
    let entitlementIds: [String]?
    let startsAt: Date
    let endsAt: Date
    let code: String?

    enum CodingKeys: String, CodingKey {
        case id
        case identifier
        case name
        case description
        case campaignType = "campaign_type"
        case discountPercent = "discount_percent"
        case discountFixedFormatted = "discount_fixed_formatted"
        case productIds = "product_ids"
        case entitlementIds = "entitlement_ids"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case code
    }
}

struct PromotionsResponse: Codable {
    let promotions: [PromotionResponse]
}

struct RedemptionResultResponse: Codable {
    let success: Bool
    let message: String
    let discountAppliedFormatted: String?
    let entitlements: [EntitlementResponse]?

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case discountAppliedFormatted = "discount_applied_formatted"
        case entitlements
    }
}
