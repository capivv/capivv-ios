import SwiftUI

/// State for the paywall view
public enum PaywallState: Sendable {
    case loading
    case loaded(PaywallConfig)
    case error(Error)
}

/// Purchase state
public enum PurchaseState: Sendable, Equatable {
    case idle
    case purchasing
    case restoring
    case success
    case failed(Error)

    public static func == (lhs: PurchaseState, rhs: PurchaseState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.purchasing, .purchasing), (.restoring, .restoring), (.success, .success):
            return true
        case (.failed, .failed):
            return true // Just check if both are failed, ignore error details
        default:
            return false
        }
    }
}

/// ViewModel for paywall views
@MainActor
public final class PaywallViewModel: ObservableObject {
    /// Current state
    @Published public private(set) var state: PaywallState = .loading

    /// Purchase state
    @Published public private(set) var purchaseState: PurchaseState = .idle

    /// Selected package
    @Published public var selectedPackage: Package?

    /// Dynamic template definition (fetched from server for OTA updates)
    @Published public private(set) var dynamicTemplate: TemplateDefinition?

    /// Paywall identifier
    public let identifier: String

    /// Session ID for analytics
    private let sessionId = UUID().uuidString

    public init(identifier: String) {
        self.identifier = identifier
    }

    /// Initialize with a pre-loaded dynamic template
    public init(identifier: String, dynamicTemplate: TemplateDefinition?) {
        self.identifier = identifier
        self.dynamicTemplate = dynamicTemplate
    }

    // MARK: - Loading

    /// Load the paywall configuration
    public func load() async {
        state = .loading

        do {
            // Fetch paywall config and template in parallel
            async let configTask = Capivv.shared.getPaywallConfig(identifier: identifier)
            async let templateTask = loadDynamicTemplate()

            let config = try await configTask
            let template = await templateTask

            // Set the dynamic template if one was fetched
            if let template = template {
                self.dynamicTemplate = template
                Logger.info("Dynamic template loaded for paywall: \(identifier)")
            }

            state = .loaded(config)

            // Select first package by default
            if selectedPackage == nil {
                selectedPackage = config.offering.packages.first
            }

            // Track view
            await Capivv.shared.events?.trackPaywallView(
                paywallId: config.id,
                variant: config.experimentVariant
            )

            Logger.info("Paywall loaded: \(identifier)")
        } catch {
            state = .error(error)
            Logger.error("Failed to load paywall: \(error)")
        }
    }

    // MARK: - Purchase

    /// Purchase the selected package
    public func purchase() async {
        guard let package = selectedPackage else {
            Logger.warning("No package selected for purchase")
            return
        }

        guard case .loaded(let config) = state else {
            return
        }

        purchaseState = .purchasing

        do {
            let result = try await Capivv.shared.purchase(package: package)

            switch result {
            case .success:
                purchaseState = .success
                // Track conversion
                await Capivv.shared.events?.trackPaywallConversion(
                    paywallId: config.id,
                    packageId: package.id,
                    variant: config.experimentVariant
                )
                Logger.info("Purchase successful: \(package.id)")

            case .userCancelled:
                purchaseState = .idle
                Logger.info("Purchase cancelled by user")

            case .pending:
                purchaseState = .idle
                Logger.info("Purchase pending")

            case .failed(let error):
                purchaseState = .failed(error)
                Logger.error("Purchase failed: \(error)")
            }
        } catch {
            purchaseState = .failed(error)
            Logger.error("Purchase error: \(error)")
        }
    }

    /// Restore purchases
    public func restore() async {
        purchaseState = .restoring

        do {
            try await Capivv.shared.restorePurchases()
            purchaseState = .success
            Logger.info("Restore successful")
        } catch {
            purchaseState = .failed(error)
            Logger.error("Restore failed: \(error)")
        }
    }

    /// Track close event
    public func trackClose() async {
        guard case .loaded(let config) = state else { return }
        await Capivv.shared.events?.trackPaywallClose(
            paywallId: config.id,
            variant: config.experimentVariant
        )
    }

    /// Clear error state
    public func clearError() {
        purchaseState = .idle
    }

    /// Set dynamic template (for OTA updates)
    public func setDynamicTemplate(_ template: TemplateDefinition?) {
        self.dynamicTemplate = template
    }

    /// Load a dynamic template from the server.
    /// Returns nil if template loading fails or no template is available.
    private func loadDynamicTemplate() async -> TemplateDefinition? {
        do {
            let result = try await Capivv.shared.getPaywallTemplate(identifier: identifier)
            return result.template
        } catch {
            // Template loading is optional - don't fail the whole paywall load
            Logger.debug("Dynamic template not available for \(identifier): \(error)")
            return nil
        }
    }

    // MARK: - Helpers

    /// Get the call-to-action text with price
    public func getCtaText(for config: PaywallConfig) -> String {
        guard let package = selectedPackage,
              let price = package.localizedPriceString else {
            return config.layout.ctaText
        }

        // Check for trial
        if let subscription = package.storeProduct?.subscription,
           let introOffer = subscription.introductoryOffer,
           introOffer.paymentMode == .freeTrial {
            let trialDays = introOffer.period.value
            return "Start \(trialDays)-day free trial"
        }

        return "\(config.layout.ctaText) - \(price)"
    }

    /// Get subtitle for purchase button
    public func getCtaSubtitle(for config: PaywallConfig) -> String? {
        guard let package = selectedPackage,
              let subscription = package.storeProduct?.subscription,
              let introOffer = subscription.introductoryOffer,
              introOffer.paymentMode == .freeTrial,
              let price = package.localizedPriceString else {
            return nil
        }

        return "Then \(price)/\(periodShort(subscription.subscriptionPeriod))"
    }

    private func periodShort(_ period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        @unknown default: return ""
        }
    }
}

import StoreKit
