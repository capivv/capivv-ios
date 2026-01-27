import Foundation
@testable import Capivv

// MARK: - Promotion Mock Data

extension MockDataFactory {
    static func promotionResponse(
        id: String = "promo_123",
        identifier: String = "summer_sale",
        name: String = "Summer Sale",
        campaignType: String = "flash_sale",
        discountPercent: Double = 30,
        daysUntilEnd: Int = 7
    ) -> MockPromotionResponse {
        MockPromotionResponse(
            id: id,
            identifier: identifier,
            name: name,
            description: "Get 30% off all annual plans!",
            campaignType: campaignType,
            discountPercent: discountPercent,
            discountFixedFormatted: nil,
            productIds: ["com.test.annual"],
            entitlementIds: ["premium"],
            startsAt: Date().addingTimeInterval(-86400), // Started yesterday
            endsAt: Date().addingTimeInterval(Double(daysUntilEnd) * 86400),
            code: "SUMMER30"
        )
    }

    static func promotionsResponse(count: Int = 2) -> MockPromotionsResponse {
        var promotions: [MockPromotionResponse] = []
        for i in 0..<count {
            promotions.append(promotionResponse(
                id: "promo_\(i)",
                identifier: "promo_\(i)",
                name: "Promotion \(i + 1)",
                discountPercent: Double((i + 1) * 10)
            ))
        }
        return MockPromotionsResponse(promotions: promotions)
    }

    static func redemptionResultResponse(
        success: Bool = true,
        discountApplied: String? = "$29.99"
    ) -> MockRedemptionResultResponse {
        MockRedemptionResultResponse(
            success: success,
            message: success ? "Code redeemed successfully!" : "Invalid or expired code",
            discountAppliedFormatted: success ? discountApplied : nil,
            entitlements: success ? [
                MockEntitlementResponse(
                    identifier: "premium",
                    isActive: true,
                    expiresAt: Date().addingTimeInterval(86400 * 365),
                    source: "promotion"
                )
            ] : nil
        )
    }

    static func experimentVariantResponse(
        experimentId: String = "exp_paywall_test",
        variantId: String = "variant_b",
        variantName: String = "New Design",
        isControl: Bool = false
    ) -> MockExperimentVariantResponse {
        MockExperimentVariantResponse(
            experimentId: experimentId,
            variantId: variantId,
            variantName: variantName,
            isControl: isControl,
            metadata: [
                "button_color": "#FF0000",
                "headline": "Try Premium Today"
            ]
        )
    }
}

// MARK: - Mock Response Types

struct MockPromotionResponse: Encodable {
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

struct MockPromotionsResponse: Encodable {
    let promotions: [MockPromotionResponse]
}

struct MockRedemptionResultResponse: Encodable {
    let success: Bool
    let message: String
    let discountAppliedFormatted: String?
    let entitlements: [MockEntitlementResponse]?

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case discountAppliedFormatted = "discount_applied_formatted"
        case entitlements
    }
}

struct MockExperimentVariantResponse: Encodable {
    let experimentId: String
    let variantId: String
    let variantName: String
    let isControl: Bool
    let metadata: [String: String]

    enum CodingKeys: String, CodingKey {
        case experimentId = "experiment_id"
        case variantId = "variant_id"
        case variantName = "variant_name"
        case isControl = "is_control"
        case metadata
    }
}
