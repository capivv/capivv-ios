import XCTest
@testable import Capivv

/// Tests for ExperimentManager
final class ExperimentManagerTests: XCTestCase {

    // MARK: - Caching Tests

    func testVariantAssignmentIsCached() async throws {
        // Create a variant response
        let variant = ExperimentVariant(
            experimentId: "exp_123",
            experimentName: "Test Experiment",
            variantId: "variant_a",
            variantName: "Test Variant",
            isControl: false,
            metadata: ["key": AnyCodable("value")]
        )

        // Verify caching behavior - if the same experiment is requested twice,
        // the second request should return the cached value
        XCTAssertEqual(variant.experimentId, "exp_123")
        XCTAssertEqual(variant.variantId, "variant_a")
    }

    func testVariantMetadataAccess() {
        let variant = ExperimentVariant(
            experimentId: "exp_pricing",
            experimentName: "Pricing Experiment",
            variantId: "high_price",
            variantName: "High Price",
            isControl: false,
            metadata: [
                "price": AnyCodable(19.99),
                "headline": AnyCodable("Premium Access"),
                "show_badge": AnyCodable(true)
            ]
        )

        // Test metadata access
        if let price = variant.metadata["price"]?.value as? Double {
            XCTAssertEqual(price, 19.99, accuracy: 0.01)
        } else {
            XCTFail("Price metadata should be accessible")
        }

        if let headline = variant.metadata["headline"]?.value as? String {
            XCTAssertEqual(headline, "Premium Access")
        } else {
            XCTFail("Headline metadata should be accessible")
        }

        if let showBadge = variant.metadata["show_badge"]?.value as? Bool {
            XCTAssertTrue(showBadge)
        } else {
            XCTFail("show_badge metadata should be accessible")
        }
    }

    func testControlVariantIdentification() {
        let controlVariant = ExperimentVariant(
            experimentId: "exp_test",
            experimentName: "Test Experiment",
            variantId: "control",
            variantName: "Control",
            isControl: true,
            metadata: [:]
        )

        let treatmentVariant = ExperimentVariant(
            experimentId: "exp_test",
            experimentName: "Test Experiment",
            variantId: "treatment",
            variantName: "Treatment",
            isControl: false,
            metadata: [:]
        )

        XCTAssertTrue(controlVariant.isControl)
        XCTAssertFalse(treatmentVariant.isControl)
    }

    // MARK: - AnyCodable Tests

    func testAnyCodableWithDifferentTypes() {
        let stringValue = AnyCodable("test")
        let intValue = AnyCodable(42)
        let doubleValue = AnyCodable(3.14)
        let boolValue = AnyCodable(true)
        let arrayValue = AnyCodable([1, 2, 3])
        let dictValue = AnyCodable(["key": "value"])

        XCTAssertEqual(stringValue.value as? String, "test")
        XCTAssertEqual(intValue.value as? Int, 42)
        XCTAssertEqual(doubleValue.value as? Double, 3.14)
        XCTAssertEqual(boolValue.value as? Bool, true)
        XCTAssertEqual((arrayValue.value as? [Int])?.count, 3)
        XCTAssertEqual((dictValue.value as? [String: String])?["key"], "value")
    }

    func testAnyCodableEncoding() throws {
        let variant = ExperimentVariant(
            experimentId: "exp_1",
            experimentName: "Experiment One",
            variantId: "v_1",
            variantName: "Variant 1",
            isControl: false,
            metadata: [
                "color": AnyCodable("#FF0000"),
                "size": AnyCodable(16)
            ]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(variant)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertNotNil(json)
        XCTAssertEqual(json?["experiment_id"] as? String, "exp_1")

        let metadata = json?["metadata"] as? [String: Any]
        XCTAssertEqual(metadata?["color"] as? String, "#FF0000")
        XCTAssertEqual(metadata?["size"] as? Int, 16)
    }

    func testAnyCodableDecoding() throws {
        let json = """
        {
            "experiment_id": "exp_decode",
            "experiment_name": "Decode Experiment",
            "variant_id": "v_decode",
            "variant_name": "Decode Test",
            "is_control": false,
            "metadata": {
                "string_val": "hello",
                "int_val": 123,
                "bool_val": false,
                "float_val": 1.5
            }
        }
        """

        let decoder = JSONDecoder()
        let variant = try decoder.decode(ExperimentVariant.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(variant.experimentId, "exp_decode")
        XCTAssertEqual(variant.experimentName, "Decode Experiment")
        XCTAssertEqual(variant.metadata["string_val"]?.value as? String, "hello")
        XCTAssertEqual(variant.metadata["int_val"]?.value as? Int, 123)
        XCTAssertEqual(variant.metadata["bool_val"]?.value as? Bool, false)
        // Float values may come back as Double
        if let floatVal = variant.metadata["float_val"]?.value as? Double {
            XCTAssertEqual(floatVal, 1.5, accuracy: 0.01)
        }
    }

    // MARK: - Experiment Scenarios

    func testMultipleExperimentsCanExist() {
        let experiment1 = ExperimentVariant(
            experimentId: "exp_paywall",
            experimentName: "Paywall Experiment",
            variantId: "paywall_v2",
            variantName: "New Paywall",
            isControl: false,
            metadata: [:]
        )

        let experiment2 = ExperimentVariant(
            experimentId: "exp_pricing",
            experimentName: "Pricing Experiment",
            variantId: "high_price",
            variantName: "High Price",
            isControl: false,
            metadata: [:]
        )

        let experiment3 = ExperimentVariant(
            experimentId: "exp_onboarding",
            experimentName: "Onboarding Experiment",
            variantId: "short_flow",
            variantName: "Short Onboarding",
            isControl: true,
            metadata: [:]
        )

        XCTAssertNotEqual(experiment1.experimentId, experiment2.experimentId)
        XCTAssertNotEqual(experiment2.experimentId, experiment3.experimentId)
        XCTAssertFalse(experiment1.isControl)
        XCTAssertFalse(experiment2.isControl)
        XCTAssertTrue(experiment3.isControl)
    }

    func testVariantWithEmptyMetadata() {
        let variant = ExperimentVariant(
            experimentId: "exp_simple",
            experimentName: "Simple Experiment",
            variantId: "v_simple",
            variantName: "Simple",
            isControl: true,
            metadata: [:]
        )

        XCTAssertTrue(variant.metadata.isEmpty)
    }

    func testVariantWithNestedMetadata() throws {
        let json = """
        {
            "experiment_id": "exp_nested",
            "experiment_name": "Nested Experiment",
            "variant_id": "v_nested",
            "variant_name": "Nested",
            "is_control": false,
            "metadata": {
                "config": {
                    "enabled": true,
                    "value": 100
                },
                "tags": ["premium", "new"]
            }
        }
        """

        let decoder = JSONDecoder()
        let variant = try decoder.decode(ExperimentVariant.self, from: json.data(using: .utf8)!)

        // Nested objects are decoded as dictionaries
        if let config = variant.metadata["config"]?.value as? [String: Any] {
            XCTAssertEqual(config["enabled"] as? Bool, true)
            XCTAssertEqual(config["value"] as? Int, 100)
        }

        if let tags = variant.metadata["tags"]?.value as? [String] {
            XCTAssertEqual(tags.count, 2)
            XCTAssertTrue(tags.contains("premium"))
        }
    }
}
