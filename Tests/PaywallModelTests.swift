import XCTest
@testable import Capivv

/// Tests for Paywall model parsing and initialization
final class PaywallModelTests: XCTestCase {

    // MARK: - PaywallConfig Tests

    func testPaywallConfigResponseParsing() throws {
        let json = """
        {
            "id": "paywall_123",
            "identifier": "premium_paywall",
            "name": "Premium Paywall",
            "paywall_type": "soft",
            "offering": {
                "identifier": "default",
                "display_name": "Default Offering",
                "packages": [
                    {
                        "id": "pkg_1",
                        "identifier": "monthly",
                        "package_type": "monthly",
                        "store_product_id": "com.app.monthly",
                        "display_name": "Monthly",
                        "localized_price_string": "$9.99"
                    }
                ]
            },
            "layout": {
                "template": "default",
                "header_image": "https://example.com/image.png",
                "title": "Unlock Premium",
                "subtitle": "Get all features",
                "features": [
                    {
                        "id": "f1",
                        "title": "Unlimited Access",
                        "description": "Access all content",
                        "icon": "star.fill",
                        "is_highlighted": true
                    }
                ],
                "cta_text": "Subscribe",
                "restore_text": "Restore",
                "close_button_behavior": "visible"
            },
            "theme": {
                "primary_color": "#007AFF",
                "background_color": "#FFFFFF",
                "text_color": "#000000",
                "accent_color": "#FF9500",
                "corner_radius": 12
            },
            "experiment_variant": "variant_a"
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(PaywallConfigResponse.self, from: json.data(using: .utf8)!)
        let config = PaywallConfig(from: response)

        XCTAssertEqual(config.id, "paywall_123")
        XCTAssertEqual(config.identifier, "premium_paywall")
        XCTAssertEqual(config.name, "Premium Paywall")
        XCTAssertEqual(config.paywallType, .soft)
        XCTAssertEqual(config.experimentVariant, "variant_a")
    }

    func testPaywallLayoutParsing() throws {
        let json = """
        {
            "template": "feature-list",
            "header_image": null,
            "title": "Go Premium",
            "subtitle": "Unlock everything",
            "features": [
                {
                    "id": "f1",
                    "title": "Feature 1",
                    "description": "Description 1",
                    "icon": "checkmark",
                    "is_highlighted": false
                },
                {
                    "id": "f2",
                    "title": "Feature 2",
                    "description": null,
                    "icon": null,
                    "is_highlighted": true
                }
            ],
            "cta_text": "Continue",
            "restore_text": "Already purchased?",
            "close_button_behavior": "hidden"
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(PaywallLayoutResponse.self, from: json.data(using: .utf8)!)
        let layout = PaywallLayout(from: response)

        XCTAssertEqual(layout.template, "feature-list")
        XCTAssertNil(layout.headerImage)
        XCTAssertEqual(layout.title, "Go Premium")
        XCTAssertEqual(layout.subtitle, "Unlock everything")
        XCTAssertEqual(layout.features.count, 2)
        XCTAssertEqual(layout.ctaText, "Continue")
        XCTAssertEqual(layout.restoreText, "Already purchased?")
        XCTAssertEqual(layout.closeButtonBehavior, "hidden")
    }

    func testPaywallFeatureParsing() throws {
        let json = """
        {
            "title": "Unlimited Downloads",
            "description": "Download as much as you want",
            "icon": "arrow.down.circle.fill",
            "is_highlighted": true
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(PaywallFeatureResponse.self, from: json.data(using: .utf8)!)
        let feature = PaywallFeature(from: response)

        // PaywallFeature.id is a computed property that returns title
        XCTAssertEqual(feature.id, feature.title)
        XCTAssertEqual(feature.title, "Unlimited Downloads")
        XCTAssertEqual(feature.description, "Download as much as you want")
        XCTAssertEqual(feature.icon, "arrow.down.circle.fill")
        XCTAssertTrue(feature.isHighlighted)
    }

    func testPaywallThemeParsing() throws {
        let json = """
        {
            "primary_color": "#FF5733",
            "background_color": "#1A1A1A",
            "text_color": "#FFFFFF",
            "accent_color": "#33FF57",
            "corner_radius": 16
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(PaywallThemeResponse.self, from: json.data(using: .utf8)!)
        let theme = PaywallTheme(from: response)

        XCTAssertEqual(theme.primaryColor, "#FF5733")
        XCTAssertEqual(theme.backgroundColor, "#1A1A1A")
        XCTAssertEqual(theme.textColor, "#FFFFFF")
        XCTAssertEqual(theme.accentColor, "#33FF57")
        XCTAssertEqual(theme.cornerRadius, 16)
    }

    func testPaywallTypeEnum() {
        XCTAssertEqual(PaywallType(rawValue: "hard"), .hard)
        XCTAssertEqual(PaywallType(rawValue: "soft"), .soft)
        XCTAssertEqual(PaywallType(rawValue: "upsell"), .upsell)
        XCTAssertEqual(PaywallType(rawValue: "promo"), .promo)
        XCTAssertNil(PaywallType(rawValue: "unknown"))
    }

    // MARK: - PaywallEvent Tests

    func testPaywallEventEncoding() throws {
        let event = PaywallEvent(type: .conversion, variant: "variant_a", packageId: "pkg_123")

        let encoder = JSONEncoder()
        let data = try encoder.encode(event)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertEqual(json?["type"] as? String, "conversion")
        XCTAssertEqual(json?["package_id"] as? String, "pkg_123")
        XCTAssertEqual(json?["variant"] as? String, "variant_a")
    }

    func testPaywallEventTypes() {
        XCTAssertEqual(PaywallEventType.view.rawValue, "view")
        XCTAssertEqual(PaywallEventType.conversion.rawValue, "conversion")
        XCTAssertEqual(PaywallEventType.close.rawValue, "close")
    }

    // MARK: - Edge Cases

    func testPaywallConfigWithMinimalData() throws {
        let json = """
        {
            "id": "pw_1",
            "identifier": "basic",
            "name": "Basic",
            "paywall_type": "hard",
            "offering": {
                "identifier": "default",
                "display_name": "Default",
                "packages": []
            },
            "layout": {
                "template": "minimal",
                "header_image": null,
                "title": "Subscribe",
                "subtitle": null,
                "features": [],
                "cta_text": "Go",
                "restore_text": null,
                "close_button_behavior": "visible"
            },
            "theme": {
                "primary_color": "#000000",
                "background_color": "#FFFFFF",
                "text_color": "#000000",
                "accent_color": "#000000",
                "corner_radius": 0
            },
            "experiment_variant": null
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(PaywallConfigResponse.self, from: json.data(using: .utf8)!)
        let config = PaywallConfig(from: response)

        XCTAssertEqual(config.id, "pw_1")
        XCTAssertTrue(config.offering.packages.isEmpty)
        XCTAssertTrue(config.layout.features.isEmpty)
        XCTAssertNil(config.layout.subtitle)
        XCTAssertNil(config.layout.restoreText)
        XCTAssertNil(config.experimentVariant)
    }
}
