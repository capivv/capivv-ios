import XCTest
@testable import Capivv

/// Tests for Promotion and Experiment model parsing
final class PromotionModelTests: XCTestCase {

    // MARK: - Promotion Tests

    func testPromotionResponseParsing() throws {
        let json = """
        {
            "id": "promo_123",
            "identifier": "summer_sale",
            "name": "Summer Sale",
            "description": "Get 30% off all annual plans!",
            "campaign_type": "flash_sale",
            "discount_percent": 30,
            "discount_fixed_formatted": null,
            "product_ids": ["com.app.annual"],
            "entitlement_ids": ["premium"],
            "starts_at": "2024-06-01T00:00:00Z",
            "ends_at": "2024-06-30T23:59:59Z",
            "code": "SUMMER30"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(PromotionResponse.self, from: json.data(using: .utf8)!)
        let promotion = Promotion(from: response)

        XCTAssertEqual(promotion.id, "promo_123")
        XCTAssertEqual(promotion.identifier, "summer_sale")
        XCTAssertEqual(promotion.name, "Summer Sale")
        XCTAssertEqual(promotion.description, "Get 30% off all annual plans!")
        XCTAssertEqual(promotion.campaignType, .flashSale)
        XCTAssertEqual(promotion.discountPercent, Decimal(30))
        XCTAssertEqual(promotion.applicableProductIds, ["com.app.annual"])
        XCTAssertEqual(promotion.applicableEntitlementIds, ["premium"])
        XCTAssertEqual(promotion.code, "SUMMER30")
    }

    func testCampaignTypeEnum() {
        XCTAssertEqual(CampaignType(rawValue: "flash_sale"), .flashSale)
        XCTAssertEqual(CampaignType(rawValue: "bundle"), .bundle)
        XCTAssertEqual(CampaignType(rawValue: "referral"), .referral)
        XCTAssertEqual(CampaignType(rawValue: "segment"), .segment)
    }

    func testPromotionIsActive() throws {
        // Create promotion that started yesterday and ends tomorrow
        let yesterday = Date().addingTimeInterval(-86400)
        let tomorrow = Date().addingTimeInterval(86400)

        let promotion = Promotion(
            id: "promo_1",
            identifier: "test",
            name: "Test",
            description: nil,
            campaignType: .flashSale,
            discountPercent: 10,
            discountFixedFormatted: nil,
            applicableProductIds: [],
            applicableEntitlementIds: [],
            startsAt: yesterday,
            endsAt: tomorrow,
            code: nil
        )

        XCTAssertTrue(promotion.isActive)
        XCTAssertNotNil(promotion.timeRemaining)
    }

    func testPromotionIsInactive() throws {
        // Create expired promotion
        let twoDaysAgo = Date().addingTimeInterval(-86400 * 2)
        let yesterday = Date().addingTimeInterval(-86400)

        let promotion = Promotion(
            id: "promo_1",
            identifier: "test",
            name: "Test",
            description: nil,
            campaignType: .flashSale,
            discountPercent: 10,
            discountFixedFormatted: nil,
            applicableProductIds: [],
            applicableEntitlementIds: [],
            startsAt: twoDaysAgo,
            endsAt: yesterday,
            code: nil
        )

        XCTAssertFalse(promotion.isActive)
        XCTAssertNil(promotion.timeRemaining)
    }

    // MARK: - RedemptionResult Tests

    func testRedemptionResultSuccessParsing() throws {
        let json = """
        {
            "success": true,
            "message": "Code redeemed successfully!",
            "discount_applied_formatted": "$29.99",
            "entitlements": [
                {
                    "identifier": "premium",
                    "is_active": true,
                    "expires_at": "2025-01-01T00:00:00Z",
                    "source": "promotion"
                }
            ]
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(RedemptionResultResponse.self, from: json.data(using: .utf8)!)
        let result = RedemptionResult(from: response)

        XCTAssertTrue(result.success)
        XCTAssertEqual(result.message, "Code redeemed successfully!")
        XCTAssertEqual(result.discountAppliedFormatted, "$29.99")
        XCTAssertEqual(result.entitlements?.count, 1)
    }

    func testRedemptionResultFailureParsing() throws {
        let json = """
        {
            "success": false,
            "message": "Invalid or expired code",
            "discount_applied_formatted": null,
            "entitlements": null
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(RedemptionResultResponse.self, from: json.data(using: .utf8)!)
        let result = RedemptionResult(from: response)

        XCTAssertFalse(result.success)
        XCTAssertEqual(result.message, "Invalid or expired code")
        XCTAssertNil(result.discountAppliedFormatted)
        XCTAssertNil(result.entitlements)
    }

    // MARK: - ExperimentVariant Tests

    func testExperimentVariantParsing() throws {
        let json = """
        {
            "experiment_id": "exp_paywall_test",
            "experiment_name": "Paywall Design Test",
            "variant_id": "variant_b",
            "variant_name": "New Design",
            "is_control": false,
            "metadata": {
                "button_color": "#FF0000",
                "headline": "Try Premium Today"
            }
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(ExperimentVariantResponse.self, from: json.data(using: .utf8)!)
        let variant = ExperimentVariant(from: response)

        XCTAssertEqual(variant.experimentId, "exp_paywall_test")
        XCTAssertEqual(variant.experimentName, "Paywall Design Test")
        XCTAssertEqual(variant.variantId, "variant_b")
        XCTAssertEqual(variant.variantName, "New Design")
        XCTAssertFalse(variant.isControl)
        XCTAssertNotNil(variant.metadata["button_color"])
    }

    func testExperimentVariantControlGroup() throws {
        let json = """
        {
            "experiment_id": "exp_pricing",
            "experiment_name": "Pricing Experiment",
            "variant_id": "control",
            "variant_name": "Control",
            "is_control": true,
            "metadata": {}
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(ExperimentVariantResponse.self, from: json.data(using: .utf8)!)
        let variant = ExperimentVariant(from: response)

        XCTAssertEqual(variant.experimentName, "Pricing Experiment")
        XCTAssertTrue(variant.isControl)
        XCTAssertTrue(variant.metadata.isEmpty)
    }

    // MARK: - Promotions List Tests

    func testPromotionsListParsing() throws {
        let json = """
        {
            "promotions": [
                {
                    "id": "promo_1",
                    "identifier": "promo_a",
                    "name": "Promo A",
                    "description": null,
                    "campaign_type": "flash_sale",
                    "discount_percent": 10,
                    "discount_fixed_formatted": null,
                    "product_ids": [],
                    "entitlement_ids": [],
                    "starts_at": "2024-01-01T00:00:00Z",
                    "ends_at": "2024-12-31T23:59:59Z",
                    "code": null
                },
                {
                    "id": "promo_2",
                    "identifier": "promo_b",
                    "name": "Promo B",
                    "description": "Bundle deal",
                    "campaign_type": "bundle",
                    "discount_percent": 20,
                    "discount_fixed_formatted": "$5.00",
                    "product_ids": ["product_1", "product_2"],
                    "entitlement_ids": ["premium", "pro"],
                    "starts_at": "2024-06-01T00:00:00Z",
                    "ends_at": "2024-06-30T23:59:59Z",
                    "code": "BUNDLE20"
                }
            ]
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(PromotionsResponse.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(response.promotions.count, 2)
        XCTAssertEqual(response.promotions[0].identifier, "promo_a")
        XCTAssertEqual(response.promotions[1].identifier, "promo_b")
        XCTAssertEqual(response.promotions[1].campaignType, "bundle")
    }

    // MARK: - Edge Cases

    func testPromotionWithFixedDiscount() throws {
        let json = """
        {
            "id": "promo_fixed",
            "identifier": "fixed_discount",
            "name": "Fixed Discount",
            "description": null,
            "campaign_type": "segment",
            "discount_percent": 0,
            "discount_fixed_formatted": "$10.00 off",
            "product_ids": null,
            "entitlement_ids": null,
            "starts_at": "2024-01-01T00:00:00Z",
            "ends_at": "2024-12-31T23:59:59Z",
            "code": null
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(PromotionResponse.self, from: json.data(using: .utf8)!)
        let promotion = Promotion(from: response)

        XCTAssertEqual(promotion.discountPercent, 0)
        XCTAssertEqual(promotion.discountFixedFormatted, "$10.00 off")
        XCTAssertTrue(promotion.applicableProductIds.isEmpty)
        XCTAssertTrue(promotion.applicableEntitlementIds.isEmpty)
    }
}
