import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Main paywall view that loads configuration and renders the appropriate template
public struct PaywallView: View {
    /// Paywall identifier
    let identifier: String

    /// Dismiss callback
    let onDismiss: (() -> Void)?

    /// Purchase success callback
    let onPurchaseSuccess: ((Package) -> Void)?

    @StateObject private var viewModel: PaywallViewModel

    public init(
        identifier: String,
        onDismiss: (() -> Void)? = nil,
        onPurchaseSuccess: ((Package) -> Void)? = nil
    ) {
        self.identifier = identifier
        self.onDismiss = onDismiss
        self.onPurchaseSuccess = onPurchaseSuccess
        self._viewModel = StateObject(wrappedValue: PaywallViewModel(identifier: identifier))
    }

    public var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                loadingView

            case .loaded(let config):
                templateView(for: config)
                    .onChange(of: viewModel.purchaseState) { newValue in
                        if case .success = newValue,
                           let package = viewModel.selectedPackage {
                            onPurchaseSuccess?(package)
                        }
                    }

            case .error(let error):
                errorView(error)
            }
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        ZStack {
            Color.platformBackground
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)

                Text(L10n.commonLoading)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Error View

    private func errorView(_ error: Error) -> some View {
        ZStack {
            Color.platformBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)

                VStack(spacing: 8) {
                    Text(L10n.errorUnableToLoad)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    Task {
                        await viewModel.load()
                    }
                } label: {
                    Text(L10n.commonTryAgain)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 160, height: 44)
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                if onDismiss != nil {
                    Button(L10n.commonClose) {
                        onDismiss?()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - Template Selection

    @ViewBuilder
    private func templateView(for config: PaywallConfig) -> some View {
        // Check if we have a dynamic template definition
        if let dynamicTemplate = viewModel.dynamicTemplate {
            DynamicPaywallView(
                config: config,
                viewModel: viewModel,
                templateDefinition: dynamicTemplate,
                onDismiss: onDismiss
            )
        } else if config.layout.template == "dynamic" {
            // Use dynamic view with a template created from the layout config
            DynamicPaywallView(
                config: config,
                viewModel: viewModel,
                templateDefinition: TemplateParser.createFromLayout(config.layout),
                onDismiss: onDismiss
            )
        } else {
            // Fall back to hardcoded templates
            staticTemplateView(for: config)
        }
    }

    @ViewBuilder
    private func staticTemplateView(for config: PaywallConfig) -> some View {
        switch config.layout.template {
        case "minimal":
            MinimalPaywallTemplate(
                config: config,
                viewModel: viewModel,
                onDismiss: onDismiss
            )

        case "feature-list":
            FeatureListTemplate(
                config: config,
                viewModel: viewModel,
                onDismiss: onDismiss
            )

        default:
            // Default template for "default" or unknown templates
            DefaultPaywallTemplate(
                config: config,
                viewModel: viewModel,
                onDismiss: onDismiss
            )
        }
    }
}

// MARK: - Convenience Modifiers

extension PaywallView {
    /// Present as a sheet
    public func asSheet(isPresented: Binding<Bool>) -> some View {
        EmptyView()
            .sheet(isPresented: isPresented) {
                self
            }
    }

    #if os(iOS)
    /// Present as a full screen cover
    public func asFullScreenCover(isPresented: Binding<Bool>) -> some View {
        EmptyView()
            .fullScreenCover(isPresented: isPresented) {
                self
            }
    }
    #endif
}

// MARK: - Static Factory Methods

#if canImport(UIKit)
extension PaywallView {
    /// Create a paywall view with a completion handler
    public static func present(
        identifier: String,
        from presenter: UIViewController? = nil,
        onDismiss: (() -> Void)? = nil,
        onPurchaseSuccess: ((Package) -> Void)? = nil
    ) {
        let paywallView = PaywallView(
            identifier: identifier,
            onDismiss: {
                presenter?.dismiss(animated: true)
                onDismiss?()
            },
            onPurchaseSuccess: onPurchaseSuccess
        )

        let hostingController = UIHostingController(rootView: paywallView)
        hostingController.modalPresentationStyle = .fullScreen

        if let presenter = presenter {
            presenter.present(hostingController, animated: true)
        } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(hostingController, animated: true)
        }
    }
}
#endif

// MARK: - Preview Support

#if DEBUG
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(identifier: "premium")
    }
}
#endif
