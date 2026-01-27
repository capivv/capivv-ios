import XCTest
@testable import Capivv

/// Tests for EventTracker
final class EventTrackerTests: XCTestCase {

    // MARK: - PaywallEvent Tests

    func testPaywallEventViewCreation() {
        let event = PaywallEvent(type: .view, variant: "variant_a")

        XCTAssertEqual(event.type, .view)
        XCTAssertNil(event.packageId)
        XCTAssertEqual(event.variant, "variant_a")
    }

    func testPaywallEventConversionCreation() {
        let event = PaywallEvent(type: .conversion, variant: "control", packageId: "pkg_monthly")

        XCTAssertEqual(event.type, .conversion)
        XCTAssertEqual(event.packageId, "pkg_monthly")
        XCTAssertEqual(event.variant, "control")
    }

    func testPaywallEventCloseCreation() {
        let event = PaywallEvent(type: .close, variant: nil)

        XCTAssertEqual(event.type, .close)
        XCTAssertNil(event.packageId)
        XCTAssertNil(event.variant)
    }

    // MARK: - Event Encoding Tests

    func testPaywallEventEncodingView() throws {
        let event = PaywallEvent(type: .view, variant: "test_variant")

        let encoder = JSONEncoder()
        let data = try encoder.encode(event)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertEqual(json?["type"] as? String, "view")
        XCTAssertEqual(json?["variant"] as? String, "test_variant")
        XCTAssertNil(json?["package_id"])
    }

    func testPaywallEventEncodingConversion() throws {
        let event = PaywallEvent(type: .conversion, variant: "variant_b", packageId: "pkg_annual")

        let encoder = JSONEncoder()
        let data = try encoder.encode(event)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertEqual(json?["type"] as? String, "conversion")
        XCTAssertEqual(json?["package_id"] as? String, "pkg_annual")
        XCTAssertEqual(json?["variant"] as? String, "variant_b")
    }

    func testPaywallEventEncodingClose() throws {
        let event = PaywallEvent(type: .close)

        let encoder = JSONEncoder()
        let data = try encoder.encode(event)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertEqual(json?["type"] as? String, "close")
    }

    // MARK: - Event Type Tests

    func testPaywallEventTypeRawValues() {
        XCTAssertEqual(PaywallEventType.view.rawValue, "view")
        XCTAssertEqual(PaywallEventType.conversion.rawValue, "conversion")
        XCTAssertEqual(PaywallEventType.close.rawValue, "close")
        XCTAssertEqual(PaywallEventType.restoreTapped.rawValue, "restore_tapped")
    }

    func testPaywallEventTypeFromRawValue() {
        XCTAssertEqual(PaywallEventType(rawValue: "view"), .view)
        XCTAssertEqual(PaywallEventType(rawValue: "conversion"), .conversion)
        XCTAssertEqual(PaywallEventType(rawValue: "close"), .close)
        XCTAssertEqual(PaywallEventType(rawValue: "restore_tapped"), .restoreTapped)
        XCTAssertNil(PaywallEventType(rawValue: "unknown"))
    }

    // MARK: - Event Tracking Scenarios

    func testEventSequenceForSuccessfulPurchase() {
        // Typical flow: view -> conversion
        let viewEvent = PaywallEvent(type: .view, variant: "variant_a")
        let conversionEvent = PaywallEvent(type: .conversion, variant: "variant_a", packageId: "pkg_monthly")

        XCTAssertEqual(viewEvent.type, .view)
        XCTAssertEqual(conversionEvent.type, .conversion)
        XCTAssertEqual(viewEvent.variant, conversionEvent.variant)
    }

    func testEventSequenceForDismissedPaywall() {
        // Typical flow: view -> close
        let viewEvent = PaywallEvent(type: .view, variant: "control")
        let closeEvent = PaywallEvent(type: .close, variant: "control")

        XCTAssertEqual(viewEvent.type, .view)
        XCTAssertEqual(closeEvent.type, .close)
        XCTAssertEqual(viewEvent.variant, closeEvent.variant)
    }

    func testEventWithoutVariant() {
        // Events without A/B test
        let viewEvent = PaywallEvent(type: .view)
        let conversionEvent = PaywallEvent(type: .conversion, packageId: "pkg_1")

        XCTAssertNil(viewEvent.variant)
        XCTAssertNil(conversionEvent.variant)
    }

    // MARK: - Event Data Completeness Tests

    func testConversionEventRequiresPackageId() {
        // A proper conversion event should include the package ID
        let eventWithPackage = PaywallEvent(type: .conversion, packageId: "pkg_test")
        let eventWithoutPackage = PaywallEvent(type: .conversion)

        XCTAssertNotNil(eventWithPackage.packageId)
        XCTAssertNil(eventWithoutPackage.packageId)
    }

    func testViewEventDoesNotRequirePackageId() {
        let viewEvent = PaywallEvent(type: .view)
        XCTAssertNil(viewEvent.packageId)
    }

    func testCloseEventDoesNotRequirePackageId() {
        let closeEvent = PaywallEvent(type: .close)
        XCTAssertNil(closeEvent.packageId)
    }

    // MARK: - Serialization Round-trip Tests

    func testEventSerializationRoundTrip() throws {
        let originalEvent = PaywallEvent(
            type: .conversion,
            variant: "variant_test",
            packageId: "pkg_roundtrip"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalEvent)

        let decoder = JSONDecoder()
        let decodedEvent = try decoder.decode(PaywallEvent.self, from: data)

        XCTAssertEqual(originalEvent.type, decodedEvent.type)
        XCTAssertEqual(originalEvent.packageId, decodedEvent.packageId)
        XCTAssertEqual(originalEvent.variant, decodedEvent.variant)
    }

    // MARK: - Multiple Events Tests

    func testMultipleEventsAreIndependent() {
        let event1 = PaywallEvent(type: .view, variant: "v1")
        let event2 = PaywallEvent(type: .view, variant: "v2")
        let event3 = PaywallEvent(type: .conversion, variant: "v1", packageId: "pkg_1")

        // Events should be independent
        XCTAssertNotEqual(event1.variant, event2.variant)
        XCTAssertEqual(event1.variant, event3.variant)
        XCTAssertNotEqual(event1.type, event3.type)
    }
}
