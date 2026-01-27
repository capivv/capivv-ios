import XCTest
@testable import Capivv

/// Tests for CancellationFlow model parsing and initialization
final class CancellationFlowModelTests: XCTestCase {

    // MARK: - CancellationFlow Tests

    func testCancellationFlowResponseParsing() throws {
        let json = """
        {
            "id": "flow_123",
            "identifier": "default_rescue",
            "name": "Default Rescue Flow",
            "steps": [
                {
                    "type": "reason",
                    "order": 1,
                    "title": "Why are you cancelling?",
                    "subtitle": "Your feedback helps us improve",
                    "options": [
                        {
                            "identifier": "too_expensive",
                            "title": "Too expensive",
                            "description": "Price is too high",
                            "icon": "dollarsign.circle",
                            "triggers_offer_id": "offer_discount"
                        }
                    ],
                    "offer_id": null,
                    "is_skippable": false
                },
                {
                    "type": "confirm",
                    "order": 2,
                    "title": "Confirm",
                    "subtitle": null,
                    "options": null,
                    "offer_id": null,
                    "is_skippable": false
                }
            ],
            "offers": [
                {
                    "id": "offer_1",
                    "identifier": "discount_50",
                    "offer_type": "discount",
                    "title": "50% Off",
                    "description": "Stay with us at half price",
                    "cta_text": "Apply Discount",
                    "discount_percent": 50,
                    "pause_days": null,
                    "downgrade_product_id": null,
                    "free_extension_days": null,
                    "priority": 1
                }
            ],
            "subscription_id": "sub_abc",
            "subscription_value_formatted": "$9.99/month"
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(CancellationFlowResponse.self, from: json.data(using: .utf8)!)
        let flow = CancellationFlow(from: response)

        XCTAssertEqual(flow.id, "flow_123")
        XCTAssertEqual(flow.identifier, "default_rescue")
        XCTAssertEqual(flow.name, "Default Rescue Flow")
        XCTAssertEqual(flow.steps.count, 2)
        XCTAssertEqual(flow.offers.count, 1)
        XCTAssertEqual(flow.subscriptionId, "sub_abc")
        XCTAssertEqual(flow.subscriptionValueFormatted, "$9.99/month")
    }

    // MARK: - CancellationStep Tests

    func testCancellationStepParsing() throws {
        let json = """
        {
            "type": "reason",
            "order": 1,
            "title": "Tell us why",
            "subtitle": "Help us improve",
            "options": [
                {
                    "identifier": "opt_1",
                    "title": "Option 1",
                    "description": "Description",
                    "icon": "star",
                    "triggers_offer_id": null
                }
            ],
            "offer_id": null,
            "is_skippable": true
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(CancellationStepResponse.self, from: json.data(using: .utf8)!)
        let step = CancellationStep(from: response)

        XCTAssertEqual(step.type, .reason)
        XCTAssertEqual(step.order, 1)
        XCTAssertEqual(step.title, "Tell us why")
        XCTAssertEqual(step.subtitle, "Help us improve")
        XCTAssertEqual(step.options?.count, 1)
        XCTAssertTrue(step.isSkippable)
    }

    func testCancellationStepTypes() {
        XCTAssertEqual(CancellationStepType(rawValue: "reason"), .reason)
        XCTAssertEqual(CancellationStepType(rawValue: "offer"), .offer)
        XCTAssertEqual(CancellationStepType(rawValue: "confirm"), .confirm)
        XCTAssertEqual(CancellationStepType(rawValue: "feedback"), .feedback)
    }

    // MARK: - RescueOffer Tests

    func testRescueOfferDiscountParsing() throws {
        let json = """
        {
            "id": "offer_discount",
            "identifier": "discount_30",
            "offer_type": "discount",
            "title": "30% Off for 3 Months",
            "description": "Stay with us at a reduced price",
            "cta_text": "Accept Offer",
            "discount_percent": 30,
            "pause_days": null,
            "downgrade_product_id": null,
            "free_extension_days": null,
            "priority": 1
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(RescueOfferResponse.self, from: json.data(using: .utf8)!)
        let offer = RescueOffer(from: response)

        XCTAssertEqual(offer.id, "offer_discount")
        XCTAssertEqual(offer.offerType, .discount)
        XCTAssertEqual(offer.discountPercent, 30)
        XCTAssertNil(offer.pauseDays)
        XCTAssertEqual(offer.priority, 1)
    }

    func testRescueOfferPauseParsing() throws {
        let json = """
        {
            "id": "offer_pause",
            "identifier": "pause_30",
            "offer_type": "pause",
            "title": "Take a 30-Day Break",
            "description": "Pause your subscription",
            "cta_text": "Pause Now",
            "discount_percent": null,
            "pause_days": 30,
            "downgrade_product_id": null,
            "free_extension_days": null,
            "priority": 2
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(RescueOfferResponse.self, from: json.data(using: .utf8)!)
        let offer = RescueOffer(from: response)

        XCTAssertEqual(offer.offerType, .pause)
        XCTAssertEqual(offer.pauseDays, 30)
        XCTAssertNil(offer.discountPercent)
    }

    func testRescueOfferDowngradeParsing() throws {
        let json = """
        {
            "id": "offer_downgrade",
            "identifier": "downgrade_basic",
            "offer_type": "downgrade",
            "title": "Switch to Basic Plan",
            "description": "Keep access at a lower price",
            "cta_text": "Switch Plan",
            "discount_percent": null,
            "pause_days": null,
            "downgrade_product_id": "com.app.basic",
            "free_extension_days": null,
            "priority": 3
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(RescueOfferResponse.self, from: json.data(using: .utf8)!)
        let offer = RescueOffer(from: response)

        XCTAssertEqual(offer.offerType, .downgrade)
        XCTAssertEqual(offer.downgradeProductId, "com.app.basic")
    }

    func testRescueOfferFreeExtensionParsing() throws {
        let json = """
        {
            "id": "offer_extension",
            "identifier": "extend_14",
            "offer_type": "free_extension",
            "title": "14 Days Free",
            "description": "Get 14 more days on us",
            "cta_text": "Extend Free",
            "discount_percent": null,
            "pause_days": null,
            "downgrade_product_id": null,
            "free_extension_days": 14,
            "priority": 4
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(RescueOfferResponse.self, from: json.data(using: .utf8)!)
        let offer = RescueOffer(from: response)

        XCTAssertEqual(offer.offerType, .freeExtension)
        XCTAssertEqual(offer.freeExtensionDays, 14)
    }

    func testRescueOfferTypes() {
        XCTAssertEqual(RescueOfferType(rawValue: "discount"), .discount)
        XCTAssertEqual(RescueOfferType(rawValue: "pause"), .pause)
        XCTAssertEqual(RescueOfferType(rawValue: "downgrade"), .downgrade)
        XCTAssertEqual(RescueOfferType(rawValue: "free_extension"), .freeExtension)
    }

    // MARK: - RescueResult Tests

    func testRescueResultSuccessParsing() throws {
        let json = """
        {
            "success": true,
            "message": "Offer applied successfully!",
            "entitlements": [
                {
                    "identifier": "premium",
                    "is_active": true,
                    "expires_at": "2025-06-01T00:00:00Z",
                    "source": "rescue_offer"
                }
            ],
            "new_expiration_date": "2025-06-01T00:00:00Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(RescueResultResponse.self, from: json.data(using: .utf8)!)
        let result = RescueResult(from: response)

        XCTAssertTrue(result.success)
        XCTAssertEqual(result.message, "Offer applied successfully!")
        XCTAssertEqual(result.entitlements?.count, 1)
        XCTAssertNotNil(result.newExpirationDate)
    }

    func testRescueResultFailureParsing() throws {
        let json = """
        {
            "success": false,
            "message": "Offer could not be applied",
            "entitlements": null,
            "new_expiration_date": null
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(RescueResultResponse.self, from: json.data(using: .utf8)!)
        let result = RescueResult(from: response)

        XCTAssertFalse(result.success)
        XCTAssertEqual(result.message, "Offer could not be applied")
        XCTAssertNil(result.entitlements)
        XCTAssertNil(result.newExpirationDate)
    }

    // MARK: - CancellationReason Tests

    func testCancellationReasonEnum() {
        XCTAssertEqual(CancellationReason(rawValue: "too_expensive"), .tooExpensive)
        XCTAssertEqual(CancellationReason(rawValue: "not_using"), .notUsing)
        XCTAssertEqual(CancellationReason(rawValue: "found_alternative"), .foundAlternative)
        XCTAssertEqual(CancellationReason(rawValue: "missing_features"), .missingFeatures)
        XCTAssertEqual(CancellationReason(rawValue: "technical_issues"), .technicalIssues)
        XCTAssertEqual(CancellationReason(rawValue: "other"), .other)
    }

    // MARK: - Edge Cases

    func testCancellationFlowWithNoOffers() throws {
        let json = """
        {
            "id": "flow_1",
            "identifier": "simple",
            "name": "Simple Flow",
            "steps": [],
            "offers": [],
            "subscription_id": null,
            "subscription_value_formatted": null
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(CancellationFlowResponse.self, from: json.data(using: .utf8)!)
        let flow = CancellationFlow(from: response)

        XCTAssertTrue(flow.steps.isEmpty)
        XCTAssertTrue(flow.offers.isEmpty)
        XCTAssertNil(flow.subscriptionId)
    }
}
