import SwiftUI

/// Feature-focused paywall template with prominent feature list
public struct FeatureListTemplate: View {
    let config: PaywallConfig
    @ObservedObject var viewModel: PaywallViewModel
    let onDismiss: (() -> Void)?

    private let theme: ThemeProvider

    public init(
        config: PaywallConfig,
        viewModel: PaywallViewModel,
        onDismiss: (() -> Void)? = nil
    ) {
        self.config = config
        self.viewModel = viewModel
        self.onDismiss = onDismiss
        self.theme = ThemeProvider(theme: config.theme)
    }

    public var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    theme.primaryColor.opacity(0.1),
                    theme.backgroundColor
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Spacer()
                    if config.layout.closeButtonBehavior != "hidden" {
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
                    }
                }
                .padding()

                ScrollView {
                    VStack(spacing: 24) {
                        // Title section
                        VStack(spacing: 8) {
                            Text("Unlock Premium")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(theme.primaryColor)
                                .textCase(.uppercase)

                            Text(config.layout.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(theme.textColor)
                                .multilineTextAlignment(.center)

                            if let subtitle = config.layout.subtitle {
                                Text(subtitle)
                                    .font(.body)
                                    .foregroundColor(theme.textColor.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal)

                        // Feature cards
                        VStack(spacing: 12) {
                            ForEach(config.layout.features) { feature in
                                FeatureCard(feature: feature, theme: theme)
                            }
                        }
                        .padding(.horizontal)

                        // Price comparison
                        if config.offering.packages.count > 1 {
                            priceComparison
                                .padding(.horizontal)
                        }

                        // Package selector
                        PackageSelector(
                            packages: config.offering.packages,
                            selectedPackage: $viewModel.selectedPackage,
                            theme: theme
                        )
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 150) // Space for fixed bottom
                }

                // Fixed bottom section
                VStack(spacing: 12) {
                    PurchaseButton(
                        title: viewModel.getCtaText(for: config),
                        subtitle: viewModel.getCtaSubtitle(for: config),
                        isLoading: viewModel.purchaseState == .purchasing,
                        isDisabled: viewModel.selectedPackage == nil,
                        theme: theme
                    ) {
                        Task {
                            await viewModel.purchase()
                        }
                    }

                    HStack {
                        if let restoreText = config.layout.restoreText {
                            RestoreButton(
                                text: restoreText,
                                isLoading: viewModel.purchaseState == .restoring,
                                theme: theme
                            ) {
                                Task {
                                    await viewModel.restore()
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(
                    Rectangle()
                        .fill(theme.backgroundColor)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
                )
            }
        }
    }

    private var priceComparison: some View {
        let annual = config.offering.annual
        let monthly = config.offering.monthly

        return Group {
            if let annual = annual, let monthly = monthly,
               let annualPrice = annual.price,
               let monthlyPrice = monthly.price {
                let monthlyTotal = monthlyPrice * 12
                let savings = monthlyTotal - annualPrice
                let savingsPercent = (savings / monthlyTotal) * 100

                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(theme.accentColor)

                    Text("Save \(Int(savingsPercent.doubleValue))% with annual")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(theme.textColor)

                    Spacer()
                }
                .padding()
                .background(theme.accentColor.opacity(0.1))
                .cornerRadius(theme.cornerRadius)
            }
        }
    }
}

/// Feature card for the feature-list template
struct FeatureCard: View {
    let feature: PaywallFeature
    let theme: ThemeProvider

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(theme.primaryColor.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: feature.icon ?? "checkmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(theme.primaryColor)
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.headline)
                    .foregroundColor(theme.textColor)

                if let description = feature.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
            }

            Spacer()

            if feature.isHighlighted {
                Image(systemName: "star.fill")
                    .foregroundColor(theme.accentColor)
            }
        }
        .padding()
        .background(Color.platformBackground)
        .cornerRadius(theme.cornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

extension Decimal {
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
