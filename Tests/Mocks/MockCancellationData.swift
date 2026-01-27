import Foundation
@testable import Capivv

// MARK: - Cancellation Flow Mock Data

extension MockDataFactory {
    static func cancellationFlowResponse(
        id: String = "flow_123",
        identifier: String = "default_rescue",
        name: String = "Default Rescue Flow",
        includeOffers: Bool = true
    ) -> MockCancellationFlowResponse {
        var offers: [MockRescueOfferResponse] = []
        if includeOffers {
            offers = [
                MockRescueOfferResponse(
                    id: "offer_discount",
                    identifier: "discount_50",
                    offerType: "discount",
                    title: "Stay with 50% Off",
                    description: "We'd hate to see you go! How about 50% off your next 3 months?",
                    ctaText: "Apply Discount",
                    discountPercent: 50,
                    pauseDays: nil,
                    downgradeProductId: nil,
                    freeExtensionDays: nil,
                    priority: 1
                ),
                MockRescueOfferResponse(
                    id: "offer_pause",
                    identifier: "pause_30",
                    offerType: "pause",
                    title: "Take a Break",
                    description: "Need some time off? Pause your subscription for 30 days.",
                    ctaText: "Pause Subscription",
                    discountPercent: nil,
                    pauseDays: 30,
                    downgradeProductId: nil,
                    freeExtensionDays: nil,
                    priority: 2
                )
            ]
        }

        return MockCancellationFlowResponse(
            id: id,
            identifier: identifier,
            name: name,
            steps: [
                MockCancellationStepResponse(
                    type: "reason",
                    order: 1,
                    title: "Why are you cancelling?",
                    subtitle: "Your feedback helps us improve",
                    options: [
                        MockCancellationOptionResponse(
                            identifier: "too_expensive",
                            title: "Too expensive",
                            description: "The price doesn't fit my budget",
                            icon: "dollarsign.circle",
                            triggersOfferId: "offer_discount"
                        ),
                        MockCancellationOptionResponse(
                            identifier: "not_using",
                            title: "Not using enough",
                            description: "I don't use the app often",
                            icon: "xmark.circle",
                            triggersOfferId: "offer_pause"
                        )
                    ],
                    offerId: nil,
                    isSkippable: false
                ),
                MockCancellationStepResponse(
                    type: "offer",
                    order: 2,
                    title: "Before you go...",
                    subtitle: nil,
                    options: nil,
                    offerId: nil,
                    isSkippable: true
                ),
                MockCancellationStepResponse(
                    type: "confirm",
                    order: 3,
                    title: "Confirm Cancellation",
                    subtitle: "Are you sure you want to cancel?",
                    options: nil,
                    offerId: nil,
                    isSkippable: false
                )
            ],
            offers: offers,
            subscriptionId: "sub_123",
            subscriptionValueFormatted: "$9.99/month"
        )
    }

    static func rescueResultResponse(
        success: Bool = true,
        message: String = "Offer applied successfully"
    ) -> MockRescueResultResponse {
        MockRescueResultResponse(
            success: success,
            message: message,
            entitlements: success ? [
                MockEntitlementResponse(
                    identifier: "premium",
                    isActive: true,
                    expiresAt: Date().addingTimeInterval(86400 * 90),
                    source: "rescue_offer"
                )
            ] : nil,
            newExpirationDate: success ? Date().addingTimeInterval(86400 * 90) : nil
        )
    }
}

// MARK: - Mock Response Types

struct MockCancellationFlowResponse: Encodable {
    let id: String
    let identifier: String
    let name: String
    let steps: [MockCancellationStepResponse]
    let offers: [MockRescueOfferResponse]
    let subscriptionId: String?
    let subscriptionValueFormatted: String?

    enum CodingKeys: String, CodingKey {
        case id
        case identifier
        case name
        case steps
        case offers
        case subscriptionId = "subscription_id"
        case subscriptionValueFormatted = "subscription_value_formatted"
    }
}

struct MockCancellationStepResponse: Encodable {
    let type: String
    let order: Int
    let title: String
    let subtitle: String?
    let options: [MockCancellationOptionResponse]?
    let offerId: String?
    let isSkippable: Bool

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

struct MockCancellationOptionResponse: Encodable {
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

struct MockRescueOfferResponse: Encodable {
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

struct MockRescueResultResponse: Encodable {
    let success: Bool
    let message: String
    let entitlements: [MockEntitlementResponse]?
    let newExpirationDate: Date?

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case entitlements
        case newExpirationDate = "new_expiration_date"
    }
}
