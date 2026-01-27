import SwiftUI

/// A dynamic paywall view that renders templates from JSON definitions.
/// This enables over-the-air template updates without requiring app store releases.
public struct DynamicPaywallView: View {
    let config: PaywallConfig
    @ObservedObject var viewModel: PaywallViewModel
    let templateDefinition: TemplateDefinition
    let onDismiss: (() -> Void)?

    private let theme: ThemeProvider
    private let factory: ComponentFactory

    public init(
        config: PaywallConfig,
        viewModel: PaywallViewModel,
        templateDefinition: TemplateDefinition,
        onDismiss: (() -> Void)? = nil
    ) {
        self.config = config
        self.viewModel = viewModel
        self.templateDefinition = templateDefinition
        self.onDismiss = onDismiss

        // Create theme based on template definition
        let themeMode = templateDefinition.theme == "dark"
            ? PaywallTheme(
                primaryColor: config.theme.primaryColor,
                backgroundColor: "#1C1C1E",
                textColor: "#FFFFFF",
                accentColor: config.theme.accentColor,
                fontFamily: config.theme.fontFamily,
                cornerRadius: config.theme.cornerRadius
            )
            : config.theme

        self.theme = ThemeProvider(theme: themeMode)
        self.factory = ComponentFactory(theme: theme, viewModel: viewModel, config: config)
    }

    public var body: some View {
        ZStack {
            // Background
            backgroundView
                .ignoresSafeArea()

            // Content
            ScrollView {
                VStack(spacing: settings.componentSpacing) {
                    ForEach(sortedComponents) { component in
                        factory.createView(for: component)
                    }
                }
                .padding(.horizontal, settings.horizontalPadding)
            }

            // Close button
            if settings.showCloseButton {
                closeButtonOverlay
            }

            // Error overlay
            if case .failed(let error) = viewModel.purchaseState {
                errorOverlay(error)
            }

            // Loading overlay
            if viewModel.purchaseState == .purchasing || viewModel.purchaseState == .restoring {
                loadingOverlay
            }
        }
    }

    // MARK: - Private Views

    private var backgroundView: some View {
        Group {
            if let bgStyle = templateDefinition.settings?.backgroundStyle {
                switch bgStyle.type {
                case .solid:
                    if let color = bgStyle.color {
                        Color(hex: color)
                    } else {
                        theme.backgroundColor
                    }

                case .gradient:
                    if let colors = bgStyle.gradientColors, colors.count >= 2 {
                        LinearGradient(
                            colors: colors.compactMap { Color(hex: $0) },
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        theme.backgroundColor
                    }

                case .image:
                    if let urlString = bgStyle.imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            theme.backgroundColor
                        }
                    } else {
                        theme.backgroundColor
                    }
                }
            } else {
                theme.backgroundColor
            }
        }
    }

    private var closeButtonOverlay: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    Task {
                        await viewModel.trackClose()
                        onDismiss?()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(theme.textColor.opacity(0.5))
                }
                .padding()
            }
            Spacer()
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)

                Text(viewModel.purchaseState == .restoring ? L10n.paywallRestoring : L10n.commonProcessing)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(Color.black.opacity(0.7))
            .cornerRadius(16)
        }
    }

    private func errorOverlay(_ error: Error) -> some View {
        VStack {
            Spacer()

            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.errorSomethingWentWrong)
                        .font(.subheadline.weight(.semibold))

                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(L10n.errorDismiss) {
                    viewModel.clearError()
                }
                .font(.subheadline.weight(.medium))
            }
            .padding()
            .background(Color.platformBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            .padding()
        }
    }

    // MARK: - Private Helpers

    private var sortedComponents: [TemplateComponent] {
        templateDefinition.components.sorted { $0.order < $1.order }
    }

    private var settings: LayoutSettings {
        LayoutSettings(
            componentSpacing: templateDefinition.settings?.componentSpacing ?? 16,
            horizontalPadding: templateDefinition.settings?.horizontalPadding ?? 0,
            showCloseButton: templateDefinition.settings?.showCloseButton ?? true,
            closeButtonDelay: templateDefinition.settings?.closeButtonDelay ?? 0
        )
    }

    private struct LayoutSettings {
        let componentSpacing: CGFloat
        let horizontalPadding: CGFloat
        let showCloseButton: Bool
        let closeButtonDelay: Int
    }
}

// MARK: - Template Parser

/// Parses JSON template definitions into TemplateDefinition objects
public enum TemplateParser {

    /// Parse a template definition from JSON data
    public static func parse(from data: Data) throws -> TemplateDefinition {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(TemplateDefinition.self, from: data)
    }

    /// Parse a template definition from a JSON dictionary
    public static func parse(from dictionary: [String: Any]) throws -> TemplateDefinition {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return try parse(from: data)
    }

    /// Parse a template definition from a JSON string
    public static func parse(from jsonString: String) throws -> TemplateDefinition {
        guard let data = jsonString.data(using: .utf8) else {
            throw TemplateParseError.invalidJSON
        }
        return try parse(from: data)
    }

    /// Convert a PaywallConfig layout to a basic template definition
    /// This is used as fallback when no dynamic template is available
    public static func createFromLayout(_ layout: PaywallLayout, theme: String = "dark") -> TemplateDefinition {
        var components: [TemplateComponent] = []
        var order = 0

        // Header image
        if layout.headerImage != nil {
            components.append(TemplateComponent(
                id: "header-image",
                type: .image,
                props: ComponentProps(
                    imageUrl: layout.headerImage?.absoluteString,
                    aspectRatio: .landscape
                ),
                order: order
            ))
            order += 1
        }

        // Title
        components.append(TemplateComponent(
            id: "title",
            type: .headline,
            props: ComponentProps(
                text: layout.title,
                alignment: .center,
                fontSize: .xlarge,
                fontWeight: .bold
            ),
            order: order
        ))
        order += 1

        // Subtitle
        if let subtitle = layout.subtitle {
            components.append(TemplateComponent(
                id: "subtitle",
                type: .subtitle,
                props: ComponentProps(
                    text: subtitle,
                    alignment: .center
                ),
                order: order
            ))
            order += 1
        }

        // Features
        if !layout.features.isEmpty {
            components.append(TemplateComponent(
                id: "features",
                type: .featureList,
                props: ComponentProps(
                    features: layout.features.map {
                        FeatureItem(
                            title: $0.title,
                            description: $0.description,
                            icon: $0.icon,
                            included: true
                        )
                    },
                    showIcons: true
                ),
                order: order
            ))
            order += 1
        }

        // Price selector
        components.append(TemplateComponent(
            id: "price-selector",
            type: .priceSelector,
            props: ComponentProps(),
            order: order
        ))
        order += 1

        // CTA button
        components.append(TemplateComponent(
            id: "cta-button",
            type: .ctaButton,
            props: ComponentProps(
                text: layout.ctaText,
                showPrice: true
            ),
            order: order
        ))
        order += 1

        // Restore button
        if let restoreText = layout.restoreText {
            components.append(TemplateComponent(
                id: "restore-button",
                type: .restoreButton,
                props: ComponentProps(text: restoreText),
                order: order
            ))
            order += 1
        }

        // Legal
        components.append(TemplateComponent(
            id: "legal",
            type: .legal,
            props: ComponentProps(),
            order: order
        ))

        return TemplateDefinition(
            components: components,
            theme: theme,
            settings: TemplateSettings(
                showCloseButton: layout.closeButtonBehavior != "hidden",
                closeButtonDelay: layout.closeButtonDelay
            )
        )
    }
}

// MARK: - Errors

public enum TemplateParseError: LocalizedError {
    case invalidJSON
    case missingRequiredField(String)
    case unknownComponentType(String)

    public var errorDescription: String? {
        switch self {
        case .invalidJSON:
            return "Invalid JSON format for template definition"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .unknownComponentType(let type):
            return "Unknown component type: \(type)"
        }
    }
}
