import SwiftUI

/// Default paywall template with header image, features, and package selector
public struct DefaultPaywallTemplate: View {
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

            ScrollView {
                VStack(spacing: 24) {
                    // Header image
                    if let headerImage = config.layout.headerImage {
                        AsyncImage(url: headerImage) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                        }
                        .frame(height: 200)
                        .clipped()
                    }

                    VStack(spacing: 20) {
                        // Title and subtitle
                        VStack(spacing: 8) {
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

                        // Features
                        if !config.layout.features.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(config.layout.features) { feature in
                                    FeatureRow(feature: feature, theme: theme)
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Package selector
                        PackageSelector(
                            packages: config.offering.packages,
                            selectedPackage: $viewModel.selectedPackage,
                            theme: theme
                        )
                        .padding(.horizontal)

                        // Purchase button
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

                        // Restore button
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

                        // Legal text
                        legalText
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    .padding(.top)
                }
            }

            // Close button
            if config.layout.closeButtonBehavior != "hidden" {
                closeButton
            }

            // Error overlay
            if case .failed(let error) = viewModel.purchaseState {
                errorOverlay(error)
            }
        }
    }

    private var closeButton: some View {
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

    private var legalText: some View {
        VStack(spacing: 4) {
            Text("Cancel anytime. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.")
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
    }

    private func errorOverlay(_ error: Error) -> some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text(error.localizedDescription)
                    .font(.subheadline)
            }
            .padding()
            .background(Color.platformBackground)
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding()
        }
    }
}
