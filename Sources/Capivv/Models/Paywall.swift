import Foundation

// MARK: - Public Types

/// Configuration for a paywall retrieved from the backend
public struct PaywallConfig: Sendable, Identifiable {
    /// Unique identifier
    public let id: String

    /// Paywall identifier (e.g., "default_paywall", "premium_upsell")
    public let identifier: String

    /// Display name
    public let name: String

    /// Type of paywall
    public let paywallType: PaywallType

    /// The offering to display
    public let offering: Offering

    /// Layout configuration
    public let layout: PaywallLayout

    /// Theme/styling configuration
    public let theme: PaywallTheme

    /// A/B test variant (if part of experiment)
    public let experimentVariant: String?

    /// Whether this is part of an A/B test
    public let isABTest: Bool

    /// Additional metadata
    public let metadata: [String: String]

    public init(
        id: String,
        identifier: String,
        name: String,
        paywallType: PaywallType,
        offering: Offering,
        layout: PaywallLayout,
        theme: PaywallTheme,
        experimentVariant: String? = nil,
        isABTest: Bool = false,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.identifier = identifier
        self.name = name
        self.paywallType = paywallType
        self.offering = offering
        self.layout = layout
        self.theme = theme
        self.experimentVariant = experimentVariant
        self.isABTest = isABTest
        self.metadata = metadata
    }
}

/// Type of paywall presentation
public enum PaywallType: String, Codable, Sendable {
    /// Blocks content until purchase
    case hard
    /// Shows content with limited features
    case soft
    /// Upsell to higher tier
    case upsell
    /// Promotional paywall
    case promo
}

/// Layout configuration for paywall UI
public struct PaywallLayout: Codable, Sendable {
    /// Template name: "default", "minimal", "feature-list"
    public let template: String

    /// Optional header image URL
    public let headerImage: URL?

    /// Main title text
    public let title: String

    /// Subtitle text
    public let subtitle: String?

    /// Features to display
    public let features: [PaywallFeature]

    /// Call-to-action button text
    public let ctaText: String

    /// Restore purchases text
    public let restoreText: String?

    /// Close button behavior: "hidden", "visible", "delayed"
    public let closeButtonBehavior: String

    /// Delay before showing close button (seconds)
    public let closeButtonDelay: Int?

    public init(
        template: String,
        headerImage: URL? = nil,
        title: String,
        subtitle: String? = nil,
        features: [PaywallFeature] = [],
        ctaText: String,
        restoreText: String? = nil,
        closeButtonBehavior: String = "visible",
        closeButtonDelay: Int? = nil
    ) {
        self.template = template
        self.headerImage = headerImage
        self.title = title
        self.subtitle = subtitle
        self.features = features
        self.ctaText = ctaText
        self.restoreText = restoreText
        self.closeButtonBehavior = closeButtonBehavior
        self.closeButtonDelay = closeButtonDelay
    }
}

/// A feature to display on the paywall
public struct PaywallFeature: Codable, Sendable, Identifiable {
    public var id: String { title }

    /// Feature title
    public let title: String

    /// Feature description
    public let description: String?

    /// SF Symbol name or custom icon identifier
    public let icon: String?

    /// Whether this feature is highlighted
    public let isHighlighted: Bool

    public init(
        title: String,
        description: String? = nil,
        icon: String? = nil,
        isHighlighted: Bool = false
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.isHighlighted = isHighlighted
    }
}

/// Theme configuration for paywall styling
public struct PaywallTheme: Codable, Sendable {
    /// Primary color (hex string)
    public let primaryColor: String

    /// Background color (hex string)
    public let backgroundColor: String

    /// Text color (hex string)
    public let textColor: String

    /// Accent color for highlights (hex string)
    public let accentColor: String

    /// Font family name (optional)
    public let fontFamily: String?

    /// Corner radius for buttons/cards
    public let cornerRadius: CGFloat

    public init(
        primaryColor: String = "#007AFF",
        backgroundColor: String = "#FFFFFF",
        textColor: String = "#000000",
        accentColor: String = "#34C759",
        fontFamily: String? = nil,
        cornerRadius: CGFloat = 12
    ) {
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.accentColor = accentColor
        self.fontFamily = fontFamily
        self.cornerRadius = cornerRadius
    }
}

/// Events tracked for paywall analytics
public enum PaywallEventType: String, Codable, Sendable {
    case view
    case conversion
    case close
    case restoreTapped = "restore_tapped"
}

/// Paywall event for analytics tracking
public struct PaywallEvent: Codable, Sendable {
    public let type: PaywallEventType
    public let variant: String?
    public let packageId: String?
    public let sessionId: String?

    public init(
        type: PaywallEventType,
        variant: String? = nil,
        packageId: String? = nil,
        sessionId: String? = nil
    ) {
        self.type = type
        self.variant = variant
        self.packageId = packageId
        self.sessionId = sessionId
    }

    enum CodingKeys: String, CodingKey {
        case type
        case variant
        case packageId = "package_id"
        case sessionId = "session_id"
    }
}

// MARK: - API Response Mapping

extension PaywallConfig {
    init(from response: PaywallConfigResponse) {
        self.id = response.id
        self.identifier = response.identifier
        self.name = response.name
        self.paywallType = PaywallType(rawValue: response.paywallType) ?? .soft
        self.offering = Offering(from: response.offering)
        self.layout = PaywallLayout(from: response.layout)
        self.theme = PaywallTheme(from: response.theme)
        self.experimentVariant = response.experimentVariant
        self.isABTest = response.isAbTest ?? false
        self.metadata = response.metadata ?? [:]
    }
}

extension PaywallLayout {
    init(from response: PaywallLayoutResponse) {
        self.template = response.template
        self.headerImage = response.headerImageUrl.flatMap { URL(string: $0) }
        self.title = response.title
        self.subtitle = response.subtitle
        self.features = response.features?.map { PaywallFeature(from: $0) } ?? []
        self.ctaText = response.ctaText ?? "Continue"
        self.restoreText = response.restoreText
        self.closeButtonBehavior = response.closeButtonBehavior ?? "visible"
        self.closeButtonDelay = response.closeButtonDelay
    }
}

extension PaywallFeature {
    init(from response: PaywallFeatureResponse) {
        self.title = response.title
        self.description = response.description
        self.icon = response.icon
        self.isHighlighted = response.isHighlighted ?? false
    }
}

extension PaywallTheme {
    init(from response: PaywallThemeResponse) {
        self.primaryColor = response.primaryColor ?? "#007AFF"
        self.backgroundColor = response.backgroundColor ?? "#FFFFFF"
        self.textColor = response.textColor ?? "#000000"
        self.accentColor = response.accentColor ?? "#34C759"
        self.fontFamily = response.fontFamily
        self.cornerRadius = CGFloat(response.cornerRadius ?? 12)
    }
}

// MARK: - Response Types

struct PaywallConfigResponse: Codable {
    let id: String
    let identifier: String
    let name: String
    let paywallType: String
    let offering: OfferingResponse
    let layout: PaywallLayoutResponse
    let theme: PaywallThemeResponse
    let experimentVariant: String?
    let isAbTest: Bool?
    let metadata: [String: String]?

    enum CodingKeys: String, CodingKey {
        case id
        case identifier
        case name
        case paywallType = "paywall_type"
        case offering
        case layout
        case theme
        case experimentVariant = "experiment_variant"
        case isAbTest = "is_ab_test"
        case metadata
    }
}

struct PaywallLayoutResponse: Codable {
    let template: String
    let headerImageUrl: String?
    let title: String
    let subtitle: String?
    let features: [PaywallFeatureResponse]?
    let ctaText: String?
    let restoreText: String?
    let closeButtonBehavior: String?
    let closeButtonDelay: Int?

    enum CodingKeys: String, CodingKey {
        case template
        case headerImageUrl = "header_image_url"
        case title
        case subtitle
        case features
        case ctaText = "cta_text"
        case restoreText = "restore_text"
        case closeButtonBehavior = "close_button_behavior"
        case closeButtonDelay = "close_button_delay"
    }
}

struct PaywallFeatureResponse: Codable {
    let title: String
    let description: String?
    let icon: String?
    let isHighlighted: Bool?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case icon
        case isHighlighted = "is_highlighted"
    }
}

struct PaywallThemeResponse: Codable {
    let primaryColor: String?
    let backgroundColor: String?
    let textColor: String?
    let accentColor: String?
    let fontFamily: String?
    let cornerRadius: Int?

    enum CodingKeys: String, CodingKey {
        case primaryColor = "primary_color"
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case accentColor = "accent_color"
        case fontFamily = "font_family"
        case cornerRadius = "corner_radius"
    }
}

// MARK: - Template Loading Response Types

/// Result of loading a dynamic template from the server
public struct TemplateLoadResult: Sendable {
    /// The parsed template definition, if available
    public let template: TemplateDefinition?

    /// Template version string for cache invalidation
    public let version: String

    /// Last update timestamp
    public let updatedAt: Date

    /// Suggested cache TTL in seconds
    public let cacheTTL: TimeInterval?

    public init(template: TemplateDefinition?, version: String, updatedAt: Date, cacheTTL: TimeInterval? = nil) {
        self.template = template
        self.version = version
        self.updatedAt = updatedAt
        self.cacheTTL = cacheTTL
    }
}

extension TemplateLoadResult {
    init(from response: TemplateDefinitionResponse) {
        // Try to parse the template JSON into a TemplateDefinition
        if let templateJson = response.template,
           let jsonData = try? JSONSerialization.data(withJSONObject: templateJson),
           let parsed = try? JSONDecoder().decode(TemplateDefinition.self, from: jsonData) {
            self.template = parsed
        } else {
            self.template = nil
        }

        self.version = response.version
        self.updatedAt = response.updatedAt
        self.cacheTTL = response.cacheTtlSeconds.map { TimeInterval($0) }
    }
}

/// API response for template definition endpoint
struct TemplateDefinitionResponse: Codable {
    let template: [String: Any]?
    let version: String
    let updatedAt: Date
    let cacheTtlSeconds: Int?

    enum CodingKeys: String, CodingKey {
        case template
        case version
        case updatedAt = "updated_at"
        case cacheTtlSeconds = "cache_ttl_seconds"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode template as a raw JSON value
        if let templateValue = try? container.decode(AnyCodableValue.self, forKey: .template) {
            self.template = templateValue.value as? [String: Any]
        } else {
            self.template = nil
        }

        self.version = try container.decode(String.self, forKey: .version)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.cacheTtlSeconds = try container.decodeIfPresent(Int.self, forKey: .cacheTtlSeconds)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let template = template {
            try container.encode(AnyCodableValue(template), forKey: .template)
        }
        try container.encode(version, forKey: .version)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(cacheTtlSeconds, forKey: .cacheTtlSeconds)
    }
}

/// Helper for encoding/decoding arbitrary JSON values
private struct AnyCodableValue: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodableValue].self) {
            self.value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodableValue].self) {
            self.value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodableValue($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodableValue($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Cannot encode value"))
        }
    }
}
