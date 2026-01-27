import Foundation
import SwiftUI

// MARK: - Template Definition

/// A dynamic template definition that can be parsed from JSON and rendered at runtime.
/// This allows OTA template updates without app store releases.
public struct TemplateDefinition: Codable, Sendable {
    /// List of components in render order
    public let components: [TemplateComponent]

    /// Theme mode ("dark" or "light")
    public let theme: String

    /// Optional layout settings
    public let settings: TemplateSettings?

    public init(
        components: [TemplateComponent],
        theme: String = "dark",
        settings: TemplateSettings? = nil
    ) {
        self.components = components
        self.theme = theme
        self.settings = settings
    }
}

// MARK: - Template Component

/// A single component in the template
public struct TemplateComponent: Codable, Sendable, Identifiable {
    /// Unique identifier for this component instance
    public let id: String

    /// Component type (e.g., "headline", "subtitle", "featureList", "priceSelector", "ctaButton")
    public let type: ComponentType

    /// Component-specific properties
    public let props: ComponentProps

    /// Display order (lower = earlier)
    public let order: Int

    public init(
        id: String,
        type: ComponentType,
        props: ComponentProps,
        order: Int
    ) {
        self.id = id
        self.type = type
        self.props = props
        self.order = order
    }
}

// MARK: - Component Type

/// All supported component types for dynamic templates
public enum ComponentType: String, Codable, Sendable {
    case headline
    case subtitle
    case body
    case image
    case featureList
    case priceSelector
    case ctaButton
    case restoreButton
    case spacer
    case divider
    case badge
    case timer
    case testimonial
    case comparison
    case guarantee
    case legal
    // Additional template types (E4)
    case video
    case socialProof
    case faq
    case carousel
    case progressIndicator
    case countdown

    /// Whether this component requires package data
    var requiresPackages: Bool {
        switch self {
        case .priceSelector, .ctaButton:
            return true
        default:
            return false
        }
    }
}

// MARK: - Component Props

/// Dynamic properties for components
public struct ComponentProps: Codable, Sendable {
    // Text props
    public let text: String?
    public let alignment: TextAlignment?
    public let fontSize: FontSize?
    public let fontWeight: FontWeight?

    // Image props
    public let imageUrl: String?
    public let aspectRatio: AspectRatio?
    public let cornerRadius: CGFloat?

    // Feature list props
    public let features: [FeatureItem]?
    public let showIcons: Bool?

    // Button props
    public let buttonStyle: ButtonStyle?
    public let showPrice: Bool?
    public let showTrialInfo: Bool?

    // Layout props
    public let padding: EdgePadding?
    public let height: CGFloat?

    // Badge props
    public let badgeText: String?
    public let badgeColor: String?

    // Timer props
    public let expiresAt: Date?
    public let timerStyle: TimerStyle?

    // Testimonial props
    public let authorName: String?
    public let authorTitle: String?
    public let rating: Int?

    // Comparison props
    public let plans: [ComparisonPlan]?

    // Video props (E4)
    public let videoUrl: String?
    public let autoplay: Bool?
    public let showControls: Bool?
    public let thumbnailUrl: String?

    // Social proof props (E4)
    public let reviewCount: Int?
    public let averageRating: Double?
    public let downloadCount: String?

    // FAQ props (E4)
    public let faqItems: [FAQItem]?

    // Carousel props (E4)
    public let carouselItems: [CarouselItem]?
    public let autoRotate: Bool?
    public let rotationInterval: Int?

    // Progress indicator props (E4)
    public let currentStep: Int?
    public let totalSteps: Int?
    public let stepLabels: [String]?

    // Countdown props (E4)
    public let countdownTo: Date?
    public let countdownStyle: CountdownStyle?
    public let showDays: Bool?

    public init(
        text: String? = nil,
        alignment: TextAlignment? = nil,
        fontSize: FontSize? = nil,
        fontWeight: FontWeight? = nil,
        imageUrl: String? = nil,
        aspectRatio: AspectRatio? = nil,
        cornerRadius: CGFloat? = nil,
        features: [FeatureItem]? = nil,
        showIcons: Bool? = nil,
        buttonStyle: ButtonStyle? = nil,
        showPrice: Bool? = nil,
        showTrialInfo: Bool? = nil,
        padding: EdgePadding? = nil,
        height: CGFloat? = nil,
        badgeText: String? = nil,
        badgeColor: String? = nil,
        expiresAt: Date? = nil,
        timerStyle: TimerStyle? = nil,
        authorName: String? = nil,
        authorTitle: String? = nil,
        rating: Int? = nil,
        plans: [ComparisonPlan]? = nil,
        videoUrl: String? = nil,
        autoplay: Bool? = nil,
        showControls: Bool? = nil,
        thumbnailUrl: String? = nil,
        reviewCount: Int? = nil,
        averageRating: Double? = nil,
        downloadCount: String? = nil,
        faqItems: [FAQItem]? = nil,
        carouselItems: [CarouselItem]? = nil,
        autoRotate: Bool? = nil,
        rotationInterval: Int? = nil,
        currentStep: Int? = nil,
        totalSteps: Int? = nil,
        stepLabels: [String]? = nil,
        countdownTo: Date? = nil,
        countdownStyle: CountdownStyle? = nil,
        showDays: Bool? = nil
    ) {
        self.text = text
        self.alignment = alignment
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.imageUrl = imageUrl
        self.aspectRatio = aspectRatio
        self.cornerRadius = cornerRadius
        self.features = features
        self.showIcons = showIcons
        self.buttonStyle = buttonStyle
        self.showPrice = showPrice
        self.showTrialInfo = showTrialInfo
        self.padding = padding
        self.height = height
        self.badgeText = badgeText
        self.badgeColor = badgeColor
        self.expiresAt = expiresAt
        self.timerStyle = timerStyle
        self.authorName = authorName
        self.authorTitle = authorTitle
        self.rating = rating
        self.plans = plans
        self.videoUrl = videoUrl
        self.autoplay = autoplay
        self.showControls = showControls
        self.thumbnailUrl = thumbnailUrl
        self.reviewCount = reviewCount
        self.averageRating = averageRating
        self.downloadCount = downloadCount
        self.faqItems = faqItems
        self.carouselItems = carouselItems
        self.autoRotate = autoRotate
        self.rotationInterval = rotationInterval
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.stepLabels = stepLabels
        self.countdownTo = countdownTo
        self.countdownStyle = countdownStyle
        self.showDays = showDays
    }
}

// MARK: - Supporting Types

public enum TextAlignment: String, Codable, Sendable {
    case leading, center, trailing
}

public enum FontSize: String, Codable, Sendable {
    case small, medium, large, xlarge, xxlarge

    var cgFloatValue: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 16
        case .large: return 20
        case .xlarge: return 28
        case .xxlarge: return 36
        }
    }
}

public enum FontWeight: String, Codable, Sendable {
    case regular, medium, semibold, bold, heavy

    var swiftUIWeight: Font.Weight {
        switch self {
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        }
    }
}

public enum AspectRatio: String, Codable, Sendable {
    case square = "1:1"
    case landscape = "16:9"
    case portrait = "9:16"
    case wide = "21:9"

    var value: CGFloat {
        switch self {
        case .square: return 1.0
        case .landscape: return 16.0/9.0
        case .portrait: return 9.0/16.0
        case .wide: return 21.0/9.0
        }
    }
}

public enum ButtonStyle: String, Codable, Sendable {
    case primary, secondary, outline, text
}

public enum TimerStyle: String, Codable, Sendable {
    case compact, full, minimal
}

public struct EdgePadding: Codable, Sendable {
    public let top: CGFloat?
    public let leading: CGFloat?
    public let bottom: CGFloat?
    public let trailing: CGFloat?

    public init(top: CGFloat? = nil, leading: CGFloat? = nil, bottom: CGFloat? = nil, trailing: CGFloat? = nil) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
}

public struct FeatureItem: Codable, Sendable, Identifiable {
    public var id: String { title }
    public let title: String
    public let description: String?
    public let icon: String?
    public let included: Bool

    public init(title: String, description: String? = nil, icon: String? = nil, included: Bool = true) {
        self.title = title
        self.description = description
        self.icon = icon
        self.included = included
    }
}

public struct ComparisonPlan: Codable, Sendable, Identifiable {
    public var id: String { name }
    public let name: String
    public let features: [String]
    public let isHighlighted: Bool

    public init(name: String, features: [String], isHighlighted: Bool = false) {
        self.name = name
        self.features = features
        self.isHighlighted = isHighlighted
    }
}

// MARK: - Additional Types (E4)

/// FAQ item for accordion-style FAQ component
public struct FAQItem: Codable, Sendable, Identifiable {
    public var id: String { question }
    public let question: String
    public let answer: String

    public init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
}

/// Carousel item for image/feature carousels
public struct CarouselItem: Codable, Sendable, Identifiable {
    public let id: String
    public let imageUrl: String?
    public let title: String?
    public let description: String?
    public let icon: String?

    public init(id: String = UUID().uuidString, imageUrl: String? = nil, title: String? = nil, description: String? = nil, icon: String? = nil) {
        self.id = id
        self.imageUrl = imageUrl
        self.title = title
        self.description = description
        self.icon = icon
    }
}

/// Countdown display style
public enum CountdownStyle: String, Codable, Sendable {
    case simple     // Just numbers: 01:23:45
    case labeled    // With labels: 1d 23h 45m
    case boxed      // Numbers in boxes
    case circular   // Circular progress indicators
}

// MARK: - Template Settings

public struct TemplateSettings: Codable, Sendable {
    /// Spacing between components
    public let componentSpacing: CGFloat?

    /// Horizontal padding for content
    public let horizontalPadding: CGFloat?

    /// Whether to show close button
    public let showCloseButton: Bool?

    /// Close button delay in seconds
    public let closeButtonDelay: Int?

    /// Background style
    public let backgroundStyle: BackgroundStyle?

    /// Safe area handling
    public let respectsSafeArea: Bool?

    public init(
        componentSpacing: CGFloat? = nil,
        horizontalPadding: CGFloat? = nil,
        showCloseButton: Bool? = nil,
        closeButtonDelay: Int? = nil,
        backgroundStyle: BackgroundStyle? = nil,
        respectsSafeArea: Bool? = nil
    ) {
        self.componentSpacing = componentSpacing
        self.horizontalPadding = horizontalPadding
        self.showCloseButton = showCloseButton
        self.closeButtonDelay = closeButtonDelay
        self.backgroundStyle = backgroundStyle
        self.respectsSafeArea = respectsSafeArea
    }
}

public struct BackgroundStyle: Codable, Sendable {
    public let type: BackgroundType
    public let color: String?
    public let gradientColors: [String]?
    public let imageUrl: String?

    public init(type: BackgroundType, color: String? = nil, gradientColors: [String]? = nil, imageUrl: String? = nil) {
        self.type = type
        self.color = color
        self.gradientColors = gradientColors
        self.imageUrl = imageUrl
    }
}

public enum BackgroundType: String, Codable, Sendable {
    case solid, gradient, image
}
