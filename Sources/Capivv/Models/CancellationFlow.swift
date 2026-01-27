import Foundation

// MARK: - Public Types

/// An entitlement that will be lost upon cancellation
public struct EntitlementAtRisk: Codable, Sendable, Identifiable {
    public var id: String { identifier }

    /// Entitlement identifier
    public let identifier: String

    /// User-friendly display name
    public let displayName: String

    /// Description of the entitlement
    public let description: String?

    public init(identifier: String, displayName: String, description: String? = nil) {
        self.identifier = identifier
        self.displayName = displayName
        self.description = description
    }

    enum CodingKeys: String, CodingKey {
        case identifier
        case displayName = "display_name"
        case description
    }
}

/// A cancellation/rescue flow configuration
public struct CancellationFlow: Codable, Sendable, Identifiable {
    /// Unique identifier
    public let id: String

    /// Flow identifier
    public let identifier: String

    /// Display name
    public let name: String

    /// Steps in the cancellation flow
    public let steps: [CancellationStep]

    /// Available rescue offers
    public let offers: [RescueOffer]

    /// Subscription ID this flow is for
    public let subscriptionId: String?

    /// Estimated value of the subscription (for showing impact)
    public let subscriptionValueFormatted: String?

    /// Entitlements that will be lost upon cancellation
    public let entitlementsAtRisk: [EntitlementAtRisk]

    public init(
        id: String,
        identifier: String,
        name: String,
        steps: [CancellationStep],
        offers: [RescueOffer],
        subscriptionId: String? = nil,
        subscriptionValueFormatted: String? = nil,
        entitlementsAtRisk: [EntitlementAtRisk] = []
    ) {
        self.id = id
        self.identifier = identifier
        self.name = name
        self.steps = steps
        self.offers = offers
        self.subscriptionId = subscriptionId
        self.subscriptionValueFormatted = subscriptionValueFormatted
        self.entitlementsAtRisk = entitlementsAtRisk
    }
}

/// A step in the cancellation flow
public struct CancellationStep: Codable, Sendable, Identifiable {
    public var id: String { "\(type.rawValue)-\(order)" }

    /// Type of step
    public let type: CancellationStepType

    /// Order in the flow
    public let order: Int

    /// Title text
    public let title: String

    /// Subtitle text
    public let subtitle: String?

    /// Options for selection (for reason step)
    public let options: [CancellationOption]?

    /// Offer ID to show (for offer step)
    public let offerId: String?

    /// Whether this step can be skipped
    public let isSkippable: Bool

    public init(
        type: CancellationStepType,
        order: Int,
        title: String,
        subtitle: String? = nil,
        options: [CancellationOption]? = nil,
        offerId: String? = nil,
        isSkippable: Bool = false
    ) {
        self.type = type
        self.order = order
        self.title = title
        self.subtitle = subtitle
        self.options = options
        self.offerId = offerId
        self.isSkippable = isSkippable
    }
}

/// Type of cancellation step
public enum CancellationStepType: String, Codable, Sendable {
    /// Ask why the user is cancelling
    case reason
    /// Show a rescue offer
    case offer
    /// Final confirmation before cancel
    case confirm
    /// Optional feedback after decision
    case feedback
}

/// An option for cancellation reason selection
public struct CancellationOption: Codable, Sendable, Identifiable {
    public var id: String { identifier }

    /// Option identifier
    public let identifier: String

    /// Display text
    public let title: String

    /// Description text
    public let description: String?

    /// SF Symbol icon name
    public let icon: String?

    /// Whether selecting this triggers a specific offer
    public let triggersOfferId: String?

    public init(
        identifier: String,
        title: String,
        description: String? = nil,
        icon: String? = nil,
        triggersOfferId: String? = nil
    ) {
        self.identifier = identifier
        self.title = title
        self.description = description
        self.icon = icon
        self.triggersOfferId = triggersOfferId
    }
}

/// A rescue offer to prevent cancellation
public struct RescueOffer: Codable, Sendable, Identifiable, Equatable {
    /// Unique identifier
    public let id: String

    /// Offer identifier
    public let identifier: String

    /// Type of offer
    public let offerType: RescueOfferType

    /// Title text
    public let title: String

    /// Description text
    public let description: String

    /// Call-to-action button text
    public let ctaText: String

    /// Discount percentage (for discount offers)
    public let discountPercent: Int?

    /// Number of days to pause (for pause offers)
    public let pauseDays: Int?

    /// Product to downgrade to (for downgrade offers)
    public let downgradeProductId: String?

    /// Number of free days to extend (for extension offers)
    public let freeExtensionDays: Int?

    /// Visual priority (lower = more prominent)
    public let priority: Int

    public init(
        id: String,
        identifier: String,
        offerType: RescueOfferType,
        title: String,
        description: String,
        ctaText: String,
        discountPercent: Int? = nil,
        pauseDays: Int? = nil,
        downgradeProductId: String? = nil,
        freeExtensionDays: Int? = nil,
        priority: Int = 0
    ) {
        self.id = id
        self.identifier = identifier
        self.offerType = offerType
        self.title = title
        self.description = description
        self.ctaText = ctaText
        self.discountPercent = discountPercent
        self.pauseDays = pauseDays
        self.downgradeProductId = downgradeProductId
        self.freeExtensionDays = freeExtensionDays
        self.priority = priority
    }
}

/// Type of rescue offer
public enum RescueOfferType: String, Codable, Sendable, Equatable {
    /// Discount on current subscription
    case discount
    /// Pause subscription temporarily
    case pause
    /// Downgrade to cheaper plan
    case downgrade
    /// Free trial extension
    case freeExtension = "free_extension"
}

/// Result of accepting a rescue offer
public struct RescueResult: Codable, Sendable {
    /// Whether the offer was successfully applied
    public let success: Bool

    /// Message to display to user
    public let message: String

    /// Updated entitlements after applying offer
    public let entitlements: [Entitlement]?

    /// New expiration date if applicable
    public let newExpirationDate: Date?

    public init(
        success: Bool,
        message: String,
        entitlements: [Entitlement]? = nil,
        newExpirationDate: Date? = nil
    ) {
        self.success = success
        self.message = message
        self.entitlements = entitlements
        self.newExpirationDate = newExpirationDate
    }
}

/// Cancellation reasons for analytics
public enum CancellationReason: String, Codable, Sendable {
    case tooExpensive = "too_expensive"
    case notUsing = "not_using"
    case foundAlternative = "found_alternative"
    case missingFeatures = "missing_features"
    case technicalIssues = "technical_issues"
    case other
}

// MARK: - API Response Mapping

extension CancellationFlow {
    init(from response: CancellationFlowResponse) {
        self.id = response.id
        self.identifier = response.identifier
        self.name = response.name
        self.steps = response.steps.map { CancellationStep(from: $0) }
        self.offers = response.offers.map { RescueOffer(from: $0) }
        self.subscriptionId = response.subscriptionId
        self.subscriptionValueFormatted = response.subscriptionValueFormatted
        self.entitlementsAtRisk = response.entitlementsAtRisk ?? []
    }
}

extension CancellationStep {
    init(from response: CancellationStepResponse) {
        self.type = CancellationStepType(rawValue: response.type) ?? .reason
        self.order = response.order
        self.title = response.title
        self.subtitle = response.subtitle
        self.options = response.options?.map { CancellationOption(from: $0) }
        self.offerId = response.offerId
        self.isSkippable = response.isSkippable ?? false
    }
}

extension CancellationOption {
    init(from response: CancellationOptionResponse) {
        self.identifier = response.identifier
        self.title = response.title
        self.description = response.description
        self.icon = response.icon
        self.triggersOfferId = response.triggersOfferId
    }
}

extension RescueOffer {
    init(from response: RescueOfferResponse) {
        self.id = response.id
        self.identifier = response.identifier
        self.offerType = RescueOfferType(rawValue: response.offerType) ?? .discount
        self.title = response.title
        self.description = response.description
        self.ctaText = response.ctaText ?? "Accept Offer"
        self.discountPercent = response.discountPercent
        self.pauseDays = response.pauseDays
        self.downgradeProductId = response.downgradeProductId
        self.freeExtensionDays = response.freeExtensionDays
        self.priority = response.priority ?? 0
    }
}

extension RescueResult {
    init(from response: RescueResultResponse) {
        self.success = response.success
        self.message = response.message
        self.entitlements = response.entitlements?.map { Entitlement(from: $0) }
        self.newExpirationDate = response.newExpirationDate
    }
}

// MARK: - Response Types

struct CancellationFlowResponse: Codable {
    let id: String
    let identifier: String
    let name: String
    let steps: [CancellationStepResponse]
    let offers: [RescueOfferResponse]
    let subscriptionId: String?
    let subscriptionValueFormatted: String?
    let entitlementsAtRisk: [EntitlementAtRisk]?

    enum CodingKeys: String, CodingKey {
        case id
        case identifier
        case name
        case steps
        case offers
        case subscriptionId = "subscription_id"
        case subscriptionValueFormatted = "subscription_value_formatted"
        case entitlementsAtRisk = "entitlements_at_risk"
    }
}

struct CancellationStepResponse: Codable {
    let type: String
    let order: Int
    let title: String
    let subtitle: String?
    let options: [CancellationOptionResponse]?
    let offerId: String?
    let isSkippable: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case order
        case title
        case subtitle
        case options
        case offerId = "offer_id"
        case isSkippable = "is_skippable"
    }
}

struct CancellationOptionResponse: Codable {
    let identifier: String
    let title: String
    let description: String?
    let icon: String?
    let triggersOfferId: String?

    enum CodingKeys: String, CodingKey {
        case identifier
        case title
        case description
        case icon
        case triggersOfferId = "triggers_offer_id"
    }
}

struct RescueOfferResponse: Codable {
    let id: String
    let identifier: String
    let offerType: String
    let title: String
    let description: String
    let ctaText: String?
    let discountPercent: Int?
    let pauseDays: Int?
    let downgradeProductId: String?
    let freeExtensionDays: Int?
    let priority: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case identifier
        case offerType = "offer_type"
        case title
        case description
        case ctaText = "cta_text"
        case discountPercent = "discount_percent"
        case pauseDays = "pause_days"
        case downgradeProductId = "downgrade_product_id"
        case freeExtensionDays = "free_extension_days"
        case priority
    }
}

struct RescueResultResponse: Codable {
    let success: Bool
    let message: String
    let entitlements: [EntitlementResponse]?
    let newExpirationDate: Date?

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case entitlements
        case newExpirationDate = "new_expiration_date"
    }
}
