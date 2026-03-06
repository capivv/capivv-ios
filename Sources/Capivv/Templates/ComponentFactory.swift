import SwiftUI

// MARK: - Component Factory

/// Factory that creates SwiftUI views from template component definitions.
/// This enables dynamic rendering of paywall templates without hardcoded layouts.
@MainActor
public struct ComponentFactory {
    private let theme: ThemeProvider
    private let viewModel: PaywallViewModel
    private let config: PaywallConfig

    public init(theme: ThemeProvider, viewModel: PaywallViewModel, config: PaywallConfig) {
        self.theme = theme
        self.viewModel = viewModel
        self.config = config
    }

    /// Creates a SwiftUI view for the given component
    @ViewBuilder
    public func createView(for component: TemplateComponent) -> some View {
        switch component.type {
        case .headline:
            HeadlineComponentView(props: component.props, theme: theme)

        case .subtitle:
            SubtitleComponentView(props: component.props, theme: theme)

        case .body:
            BodyComponentView(props: component.props, theme: theme)

        case .image:
            ImageComponentView(props: component.props, theme: theme)

        case .featureList:
            FeatureListComponentView(props: component.props, theme: theme)

        case .priceSelector:
            PriceSelectorComponentView(
                props: component.props,
                theme: theme,
                packages: config.offering.packages,
                selectedPackage: Binding(
                    get: { viewModel.selectedPackage },
                    set: { viewModel.selectedPackage = $0 }
                )
            )

        case .ctaButton:
            CTAButtonComponentView(
                props: component.props,
                theme: theme,
                viewModel: viewModel,
                config: config
            )

        case .restoreButton:
            RestoreButtonComponentView(props: component.props, theme: theme, viewModel: viewModel)

        case .spacer:
            SpacerComponentView(props: component.props)

        case .divider:
            DividerComponentView(props: component.props, theme: theme)

        case .badge:
            BadgeComponentView(props: component.props, theme: theme)

        case .timer:
            TimerComponentView(props: component.props, theme: theme)

        case .testimonial:
            TestimonialComponentView(props: component.props, theme: theme)

        case .comparison:
            ComparisonComponentView(props: component.props, theme: theme)

        case .guarantee:
            GuaranteeComponentView(props: component.props, theme: theme)

        case .legal:
            LegalComponentView(props: component.props, theme: theme)

        // Additional template types (E4)
        case .video:
            VideoComponentView(props: component.props, theme: theme)

        case .socialProof:
            SocialProofComponentView(props: component.props, theme: theme)

        case .faq:
            FAQComponentView(props: component.props, theme: theme)

        case .carousel:
            CarouselComponentView(props: component.props, theme: theme)

        case .progressIndicator:
            ProgressIndicatorComponentView(props: component.props, theme: theme)

        case .countdown:
            CountdownComponentView(props: component.props, theme: theme)
        }
    }
}

// MARK: - Headline Component

private struct HeadlineComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider

    var body: some View {
        Text(props.text ?? "")
            .font(.system(size: props.fontSize?.cgFloatValue ?? 28, weight: props.fontWeight?.swiftUIWeight ?? .bold))
            .foregroundColor(theme.textColor)
            .multilineTextAlignment(textAlignment)
            .frame(maxWidth: .infinity, alignment: frameAlignment)
            .padding(edgePadding)
    }

    private var textAlignment: SwiftUI.TextAlignment {
        switch props.alignment {
        case .leading: return .leading
        case .trailing: return .trailing
        default: return .center
        }
    }

    private var frameAlignment: Alignment {
        switch props.alignment {
        case .leading: return .leading
        case .trailing: return .trailing
        default: return .center
        }
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 0,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 0,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Subtitle Component

private struct SubtitleComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider

    var body: some View {
        Text(props.text ?? "")
            .font(.system(size: props.fontSize?.cgFloatValue ?? 16, weight: props.fontWeight?.swiftUIWeight ?? .regular))
            .foregroundColor(theme.textColor.opacity(0.8))
            .multilineTextAlignment(textAlignment)
            .frame(maxWidth: .infinity, alignment: frameAlignment)
            .padding(edgePadding)
    }

    private var textAlignment: SwiftUI.TextAlignment {
        switch props.alignment {
        case .leading: return .leading
        case .trailing: return .trailing
        default: return .center
        }
    }

    private var frameAlignment: Alignment {
        switch props.alignment {
        case .leading: return .leading
        case .trailing: return .trailing
        default: return .center
        }
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 4,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 0,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Body Component

private struct BodyComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider

    var body: some View {
        Text(props.text ?? "")
            .font(.system(size: props.fontSize?.cgFloatValue ?? 14))
            .foregroundColor(theme.textColor.opacity(0.7))
            .multilineTextAlignment(textAlignment)
            .frame(maxWidth: .infinity, alignment: frameAlignment)
            .padding(edgePadding)
    }

    private var textAlignment: SwiftUI.TextAlignment {
        switch props.alignment {
        case .leading: return .leading
        case .trailing: return .trailing
        default: return .center
        }
    }

    private var frameAlignment: Alignment {
        switch props.alignment {
        case .leading: return .leading
        case .trailing: return .trailing
        default: return .center
        }
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 8,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 8,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Image Component

private struct ImageComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider

    var body: some View {
        if let urlString = props.imageUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(props.aspectRatio?.value ?? 1.0, contentMode: .fill)
                        .cornerRadius(props.cornerRadius ?? 0)

                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(props.aspectRatio?.value ?? 1.0, contentMode: .fill)

                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .aspectRatio(props.aspectRatio?.value ?? 1.0, contentMode: .fill)
                        .overlay(ProgressView())

                @unknown default:
                    EmptyView()
                }
            }
            .padding(edgePadding)
        }
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 0,
            leading: props.padding?.leading ?? 0,
            bottom: props.padding?.bottom ?? 0,
            trailing: props.padding?.trailing ?? 0
        )
    }
}

// MARK: - Feature List Component

private struct FeatureListComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(props.features ?? []) { feature in
                HStack(spacing: 12) {
                    if props.showIcons ?? true {
                        Image(systemName: feature.icon ?? (feature.included ? "checkmark.circle.fill" : "xmark.circle"))
                            .foregroundColor(feature.included ? theme.accentColor : theme.textColor.opacity(0.3))
                            .font(.system(size: 20))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(theme.textColor)

                        if let description = feature.description {
                            Text(description)
                                .font(.system(size: 13))
                                .foregroundColor(theme.textColor.opacity(0.6))
                        }
                    }

                    Spacer()
                }
            }
        }
        .padding(edgePadding)
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 12,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 12,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Price Selector Component

private struct PriceSelectorComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider
    let packages: [Package]
    @Binding var selectedPackage: Package?

    var body: some View {
        PackageSelector(
            packages: packages,
            selectedPackage: $selectedPackage,
            theme: theme
        )
        .padding(edgePadding)
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 16,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 8,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - CTA Button Component

@MainActor
private struct CTAButtonComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider
    @ObservedObject var viewModel: PaywallViewModel
    let config: PaywallConfig

    var body: some View {
        PurchaseButton(
            title: props.text ?? viewModel.getCtaText(for: config),
            subtitle: props.showPrice ?? true ? viewModel.getCtaSubtitle(for: config) : nil,
            isLoading: viewModel.purchaseState == .purchasing,
            isDisabled: viewModel.selectedPackage == nil,
            theme: theme
        ) {
            Task {
                await viewModel.purchase()
            }
        }
        .padding(edgePadding)
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 8,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 8,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Restore Button Component

@MainActor
private struct RestoreButtonComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider
    @ObservedObject var viewModel: PaywallViewModel

    var body: some View {
        RestoreButton(
            text: props.text ?? "Restore Purchases",
            isLoading: viewModel.purchaseState == .restoring,
            theme: theme
        ) {
            Task {
                await viewModel.restore()
            }
        }
        .padding(edgePadding)
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 4,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 4,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Spacer Component

private struct SpacerComponentView: View {
    let props: ComponentProps

    var body: some View {
        Spacer()
            .frame(height: props.height ?? 16)
    }
}

// MARK: - Divider Component

private struct DividerComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider

    var body: some View {
        Rectangle()
            .fill(theme.textColor.opacity(0.1))
            .frame(height: 1)
            .padding(edgePadding)
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 8,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 8,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Badge Component

private struct BadgeComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider

    var body: some View {
        Text(props.badgeText ?? "")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(badgeColor)
            .cornerRadius(12)
            .padding(edgePadding)
    }

    private var badgeColor: Color {
        if let hex = props.badgeColor {
            return Color(hex: hex)
        }
        return theme.accentColor
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 8,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 8,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Timer Component

private struct TimerComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider
    @State private var timeRemaining: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        if let expiresAt = props.expiresAt, expiresAt > Date() {
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14))

                Text(formattedTime)
                    .font(.system(size: 14, weight: .semibold))
                    .monospacedDigit()
            }
            .foregroundColor(theme.accentColor)
            .padding(edgePadding)
            .onReceive(timer) { _ in
                timeRemaining = expiresAt.timeIntervalSinceNow
            }
            .onAppear {
                timeRemaining = expiresAt.timeIntervalSinceNow
            }
        }
    }

    private var formattedTime: String {
        let hours = Int(timeRemaining) / 3600
        let minutes = Int(timeRemaining) / 60 % 60
        let seconds = Int(timeRemaining) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 8,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 8,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Testimonial Component

private struct TestimonialComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Quote
            Text("\"\(props.text ?? "")\"")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(theme.textColor)
                .italic()

            // Rating stars
            if let rating = props.rating, rating > 0 {
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < rating ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                    }
                }
            }

            // Author
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if let name = props.authorName {
                        Text(name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(theme.textColor)
                    }
                    if let title = props.authorTitle {
                        Text(title)
                            .font(.system(size: 12))
                            .foregroundColor(theme.textColor.opacity(0.6))
                    }
                }
                Spacer()
            }
        }
        .padding(16)
        .background(theme.textColor.opacity(0.05))
        .cornerRadius(12)
        .padding(edgePadding)
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 8,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 8,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Comparison Component

private struct ComparisonComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider

    var body: some View {
        VStack(spacing: 0) {
            ForEach(props.plans ?? []) { plan in
                VStack(alignment: .leading, spacing: 8) {
                    Text(plan.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.textColor)

                    ForEach(plan.features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(theme.accentColor)

                            Text(feature)
                                .font(.system(size: 14))
                                .foregroundColor(theme.textColor.opacity(0.8))
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(plan.isHighlighted ? theme.primaryColor.opacity(0.1) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(plan.isHighlighted ? theme.primaryColor : theme.textColor.opacity(0.1), lineWidth: plan.isHighlighted ? 2 : 1)
                )
            }
        }
        .cornerRadius(12)
        .padding(edgePadding)
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 8,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 8,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Guarantee Component

private struct GuaranteeComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 24))
                .foregroundColor(theme.accentColor)

            Text(props.text ?? "Money-back guarantee")
                .font(.system(size: 14))
                .foregroundColor(theme.textColor.opacity(0.8))
        }
        .padding(edgePadding)
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 8,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 8,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Legal Component

private struct LegalComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider

    var body: some View {
        VStack(spacing: 4) {
            Text(props.text ?? L10n.paywallLegalDisclaimer)
                .font(.caption2)
                .foregroundColor(theme.textColor.opacity(0.5))
                .multilineTextAlignment(.center)

            HStack {
                Link("Terms of Service", destination: URL(string: "https://capivv.com/terms")!)
                Text("•")
                Link("Privacy Policy", destination: URL(string: "https://capivv.com/privacy")!)
            }
            .font(.caption2)
            .foregroundColor(theme.primaryColor)
        }
        .padding(edgePadding)
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 8,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 16,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Video Component (E4)

private struct VideoComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider

    var body: some View {
        VStack {
            if let thumbnailUrl = props.thumbnailUrl ?? props.imageUrl,
               let url = URL(string: thumbnailUrl) {
                ZStack {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(theme.backgroundColor.opacity(0.3))
                    }
                    .frame(height: props.height ?? 200)
                    .clipped()
                    .cornerRadius(props.cornerRadius ?? 12)

                    // Play button overlay
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "play.fill")
                                .foregroundColor(theme.primaryColor)
                                .font(.title2)
                                .offset(x: 2)
                        )
                        .shadow(radius: 8)
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: props.cornerRadius ?? 12)
                        .fill(theme.backgroundColor.opacity(0.3))
                        .frame(height: props.height ?? 200)

                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(theme.textColor.opacity(0.3))
                }
            }
        }
        .padding(edgePadding)
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 8,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 8,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Social Proof Component (E4)

private struct SocialProofComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider

    var body: some View {
        HStack(spacing: 24) {
            // Rating
            if let rating = props.averageRating {
                VStack(spacing: 4) {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(rating.rounded()) ? "star.fill" : "star")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                        }
                    }
                    Text(String(format: "%.1f", rating))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(theme.textColor)
                }
            }

            // Review count
            if let count = props.reviewCount {
                VStack(spacing: 4) {
                    Text("\(count)+")
                        .font(.headline.weight(.bold))
                        .foregroundColor(theme.textColor)
                    Text("Reviews")
                        .font(.caption)
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
            }

            // Download count
            if let downloads = props.downloadCount {
                VStack(spacing: 4) {
                    Text(downloads)
                        .font(.headline.weight(.bold))
                        .foregroundColor(theme.textColor)
                    Text("Downloads")
                        .font(.caption)
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(edgePadding)
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 12,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 12,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - FAQ Component (E4)

private struct FAQComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider
    @State private var expandedId: String?

    var body: some View {
        VStack(spacing: 8) {
            if let items = props.faqItems {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 0) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                expandedId = expandedId == item.id ? nil : item.id
                            }
                        } label: {
                            HStack {
                                Text(item.question)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(theme.textColor)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                Image(systemName: expandedId == item.id ? "chevron.up" : "chevron.down")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(theme.textColor.opacity(0.5))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                        }
                        .buttonStyle(.plain)

                        if expandedId == item.id {
                            Text(item.answer)
                                .font(.caption)
                                .foregroundColor(theme.textColor.opacity(0.7))
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                        }
                    }
                    .background(theme.backgroundColor.opacity(0.5))
                    .cornerRadius(8)
                }
            }
        }
        .padding(edgePadding)
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 8,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 8,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

// MARK: - Carousel Component (E4)

private struct CarouselComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider
    @State private var currentIndex = 0

    var body: some View {
        VStack(spacing: 12) {
            if let items = props.carouselItems, !items.isEmpty {
                TabView(selection: $currentIndex) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        VStack(spacing: 12) {
                            if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(height: 120)
                            } else if let icon = item.icon {
                                Image(systemName: icon)
                                    .font(.system(size: 48))
                                    .foregroundColor(theme.primaryColor)
                            }

                            if let title = item.title {
                                Text(title)
                                    .font(.headline)
                                    .foregroundColor(theme.textColor)
                            }

                            if let description = item.description {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(theme.textColor.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding()
                        .tag(index)
                    }
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                .frame(height: props.height ?? 200)

                // Page indicators
                HStack(spacing: 6) {
                    ForEach(0..<items.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? theme.primaryColor : theme.textColor.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
        .padding(edgePadding)
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 8,
            leading: props.padding?.leading ?? 0,
            bottom: props.padding?.bottom ?? 8,
            trailing: props.padding?.trailing ?? 0
        )
    }
}

// MARK: - Progress Indicator Component (E4)

private struct ProgressIndicatorComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(0..<totalSteps, id: \.self) { step in
                    HStack(spacing: 0) {
                        Circle()
                            .fill(step < currentStep ? theme.primaryColor : (step == currentStep ? theme.accentColor : theme.textColor.opacity(0.2)))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Group {
                                    if step < currentStep {
                                        Image(systemName: "checkmark")
                                            .font(.caption.weight(.bold))
                                            .foregroundColor(.white)
                                    } else {
                                        Text("\(step + 1)")
                                            .font(.caption.weight(.semibold))
                                            .foregroundColor(step == currentStep ? .white : theme.textColor.opacity(0.5))
                                    }
                                }
                            )

                        if step < totalSteps - 1 {
                            Rectangle()
                                .fill(step < currentStep ? theme.primaryColor : theme.textColor.opacity(0.2))
                                .frame(height: 2)
                        }
                    }
                }
            }

            // Step labels
            if let labels = props.stepLabels, !labels.isEmpty {
                HStack {
                    ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                        Text(label)
                            .font(.caption2)
                            .foregroundColor(index <= currentStep ? theme.textColor : theme.textColor.opacity(0.5))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(edgePadding)
    }

    private var currentStep: Int {
        props.currentStep ?? 0
    }

    private var totalSteps: Int {
        props.totalSteps ?? 3
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 16,
            leading: props.padding?.leading ?? 24,
            bottom: props.padding?.bottom ?? 16,
            trailing: props.padding?.trailing ?? 24
        )
    }
}

// MARK: - Countdown Component (E4)

private struct CountdownComponentView: View {
    let props: ComponentProps
    let theme: ThemeProvider
    @State private var timeRemaining: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        if let countdownTo = props.countdownTo, countdownTo > Date() {
            VStack(spacing: 8) {
                Text(props.text ?? L10n.promotionLimitedTime)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(theme.textColor.opacity(0.7))

                HStack(spacing: 12) {
                    if showDays && days > 0 {
                        DynamicCountdownUnit(value: days, label: "Days", theme: theme, style: countdownStyle)
                    }
                    DynamicCountdownUnit(value: hours, label: "Hours", theme: theme, style: countdownStyle)
                    DynamicCountdownUnit(value: minutes, label: "Min", theme: theme, style: countdownStyle)
                    DynamicCountdownUnit(value: seconds, label: "Sec", theme: theme, style: countdownStyle)
                }
            }
            .padding(edgePadding)
            .onReceive(timer) { _ in
                timeRemaining = countdownTo.timeIntervalSinceNow
            }
            .onAppear {
                timeRemaining = countdownTo.timeIntervalSinceNow
            }
        }
    }

    private var showDays: Bool {
        props.showDays ?? true
    }

    private var countdownStyle: CountdownStyle {
        props.countdownStyle ?? .labeled
    }

    private var days: Int {
        Int(timeRemaining) / 86400
    }

    private var hours: Int {
        Int(timeRemaining) / 3600 % 24
    }

    private var minutes: Int {
        Int(timeRemaining) / 60 % 60
    }

    private var seconds: Int {
        Int(timeRemaining) % 60
    }

    private var edgePadding: EdgeInsets {
        EdgeInsets(
            top: props.padding?.top ?? 16,
            leading: props.padding?.leading ?? 16,
            bottom: props.padding?.bottom ?? 16,
            trailing: props.padding?.trailing ?? 16
        )
    }
}

private struct DynamicCountdownUnit: View {
    let value: Int
    let label: String
    let theme: ThemeProvider
    let style: CountdownStyle

    var body: some View {
        VStack(spacing: 4) {
            switch style {
            case .boxed:
                Text(String(format: "%02d", value))
                    .font(.title2.weight(.bold).monospacedDigit())
                    .foregroundColor(theme.textColor)
                    .frame(width: 50, height: 50)
                    .background(theme.backgroundColor.opacity(0.3))
                    .cornerRadius(8)
            case .circular:
                ZStack {
                    Circle()
                        .stroke(theme.textColor.opacity(0.2), lineWidth: 3)
                        .frame(width: 50, height: 50)
                    Text(String(format: "%02d", value))
                        .font(.headline.weight(.bold).monospacedDigit())
                        .foregroundColor(theme.textColor)
                }
            default:
                Text(String(format: "%02d", value))
                    .font(.title2.weight(.bold).monospacedDigit())
                    .foregroundColor(theme.textColor)
            }

            Text(label)
                .font(.caption2)
                .foregroundColor(theme.textColor.opacity(0.5))
        }
    }
}
