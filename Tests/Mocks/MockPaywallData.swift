import Foundation
@testable import Capivv

// MARK: - Paywall Mock Data

extension MockDataFactory {
    static func paywallConfigResponse(
        id: String = "paywall_123",
        identifier: String = "premium_paywall",
        name: String = "Premium Paywall",
        paywallType: String = "soft",
        template: String = "default"
    ) -> MockPaywallConfigResponse {
        MockPaywallConfigResponse(
            id: id,
            identifier: identifier,
            name: name,
            paywallType: paywallType,
            offering: MockPaywallOfferingResponse(
                id: "offering_123",
                identifier: "default",
                packages: [
                    MockPaywallPackageResponse(
                        id: "pkg_monthly",
                        identifier: "monthly",
                        packageType: "monthly",
                        storeProductId: "com.test.monthly",
                        displayName: "Monthly",
                        localizedPriceString: "$9.99"
                    ),
                    MockPaywallPackageResponse(
                        id: "pkg_annual",
                        identifier: "annual",
                        packageType: "annual",
                        storeProductId: "com.test.annual",
                        displayName: "Annual",
                        localizedPriceString: "$79.99"
                    )
                ]
            ),
            layout: MockPaywallLayoutResponse(
                template: template,
                headerImage: nil,
                title: "Unlock Premium",
                subtitle: "Get access to all features",
                features: [
                    MockPaywallFeatureResponse(
                        id: "feature_1",
                        title: "Unlimited Access",
                        description: "Access all content",
                        icon: "star.fill",
                        isHighlighted: true
                    ),
                    MockPaywallFeatureResponse(
                        id: "feature_2",
                        title: "No Ads",
                        description: "Enjoy ad-free experience",
                        icon: "xmark.circle",
                        isHighlighted: false
                    )
                ],
                ctaText: "Subscribe Now",
                restoreText: "Restore Purchases",
                closeButtonBehavior: "visible"
            ),
            theme: MockPaywallThemeResponse(
                primaryColor: "#007AFF",
                backgroundColor: "#FFFFFF",
                textColor: "#000000",
                accentColor: "#FF9500",
                cornerRadius: 12
            ),
            experimentVariant: nil
        )
    }
}

// MARK: - Mock Response Types

struct MockPaywallConfigResponse: Encodable {
    let id: String
    let identifier: String
    let name: String
    let paywallType: String
    let offering: MockPaywallOfferingResponse
    let layout: MockPaywallLayoutResponse
    let theme: MockPaywallThemeResponse
    let experimentVariant: String?

    enum CodingKeys: String, CodingKey {
        case id
        case identifier
        case name
        case paywallType = "paywall_type"
        case offering
        case layout
        case theme
        case experimentVariant = "experiment_variant"
    }
}

struct MockPaywallOfferingResponse: Encodable {
    let id: String
    let identifier: String
    let packages: [MockPaywallPackageResponse]
}

struct MockPaywallPackageResponse: Encodable {
    let id: String
    let identifier: String
    let packageType: String
    let storeProductId: String
    let displayName: String
    let localizedPriceString: String?

    enum CodingKeys: String, CodingKey {
        case id
        case identifier
        case packageType = "package_type"
        case storeProductId = "store_product_id"
        case displayName = "display_name"
        case localizedPriceString = "localized_price_string"
    }
}

struct MockPaywallLayoutResponse: Encodable {
    let template: String
    let headerImage: String?
    let title: String
    let subtitle: String?
    let features: [MockPaywallFeatureResponse]
    let ctaText: String
    let restoreText: String?
    let closeButtonBehavior: String

    enum CodingKeys: String, CodingKey {
        case template
        case headerImage = "header_image"
        case title
        case subtitle
        case features
        case ctaText = "cta_text"
        case restoreText = "restore_text"
        case closeButtonBehavior = "close_button_behavior"
    }
}

struct MockPaywallFeatureResponse: Encodable {
    let id: String
    let title: String
    let description: String?
    let icon: String?
    let isHighlighted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case icon
        case isHighlighted = "is_highlighted"
    }
}

struct MockPaywallThemeResponse: Encodable {
    let primaryColor: String
    let backgroundColor: String
    let textColor: String
    let accentColor: String
    let cornerRadius: CGFloat

    enum CodingKeys: String, CodingKey {
        case primaryColor = "primary_color"
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case accentColor = "accent_color"
        case cornerRadius = "corner_radius"
    }
}
