import SwiftUI

/// Minimal paywall template with simple layout
public struct MinimalPaywallTemplate: View {
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
            theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Icon or badge
                Image(systemName: "crown.fill")
                    .font(.system(size: 64))
                    .foregroundColor(theme.primaryColor)

                // Title
                VStack(spacing: 12) {
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
                .padding(.horizontal, 32)

                Spacer()

                // Package cards (horizontal scroll for minimal)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(config.offering.packages) { package in
                            MinimalPackageCard(
                                package: package,
                                isSelected: viewModel.selectedPackage?.id == package.id,
                                theme: theme
                            ) {
                                viewModel.selectedPackage = package
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Actions
                VStack(spacing: 16) {
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
                    .padding(.horizontal)

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

                // Legal
                legalLinks
                    .padding(.bottom)
            }

            // Close button
            if config.layout.closeButtonBehavior != "hidden" {
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
        }
    }

    private var legalLinks: some View {
        HStack {
            Link("Terms", destination: URL(string: "https://capivv.com/terms")!)
            Text("•")
            Link("Privacy", destination: URL(string: "https://capivv.com/privacy")!)
        }
        .font(.caption)
        .foregroundColor(theme.textColor.opacity(0.5))
    }
}

/// Compact package card for minimal template
struct MinimalPackageCard: View {
    let package: Package
    let isSelected: Bool
    let theme: ThemeProvider
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(package.displayName)
                    .font(.headline)
                    .foregroundColor(theme.textColor)

                Text(package.localizedPriceString ?? "")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.primaryColor)

                if package.packageType == .annual {
                    Text("Best Value")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(theme.accentColor)
                        .cornerRadius(4)
                }
            }
            .frame(width: 140, height: 120)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(isSelected ? theme.primaryColor.opacity(0.1) : Color.platformSecondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(isSelected ? theme.primaryColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
