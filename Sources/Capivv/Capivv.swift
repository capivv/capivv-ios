import Foundation
import StoreKit

/// Main entry point for the Capivv SDK
@MainActor
public final class Capivv: ObservableObject {

    /// Shared singleton instance
    public static let shared = Capivv()

    /// Current configuration
    private var configuration: CapivvConfiguration?

    /// API client for backend communication
    private var api: CapivvAPI?

    /// Store manager for StoreKit operations
    private var store: StoreManager?

    /// Experiment manager for A/B testing
    public private(set) var experiments: ExperimentManager?

    /// Event tracker for analytics
    public private(set) var events: EventTracker?

    /// Current user ID
    @Published public private(set) var userId: String?

    /// Current user's entitlements
    @Published public private(set) var entitlements: [Entitlement] = []

    /// Whether the SDK is configured
    public var isConfigured: Bool { configuration != nil }

    /// Whether a user is logged in
    public var isLoggedIn: Bool { userId != nil }

    private init() {}

    // MARK: - Configuration

    /// Configure the SDK with your API key
    /// - Parameters:
    ///   - apiKey: Your Capivv public API key
    ///   - baseURL: Optional custom API base URL (defaults to production)
    public func configure(apiKey: String, baseURL: URL? = nil) {
        let config = CapivvConfiguration(
            apiKey: apiKey,
            baseURL: baseURL
        )
        self.configuration = config
        self.api = CapivvAPI(configuration: config)
        self.store = StoreManager(api: api!)
        self.experiments = ExperimentManager(api: api!, capivv: self)
        self.events = EventTracker(api: api!, capivv: self)

        Logger.info("Capivv SDK configured")
    }

    /// Start background services after view hierarchy is ready
    /// Call this from .onAppear or .task modifier on your root view
    public func start() async {
        guard isConfigured else { return }

        // Start listening for StoreKit transactions
        await store?.startObservingTransactions()

        // Restore user from keychain if available
        if let savedUserId = KeychainHelper.getUserId() {
            try? await login(userId: savedUserId)
        }
    }

    // MARK: - User Management

    /// Log in a user to associate purchases and entitlements
    /// - Parameter userId: Your app's user identifier
    @discardableResult
    public func login(userId: String) async throws -> UserInfo {
        guard let api = api else {
            throw CapivvError.notConfigured
        }

        let userInfo = try await api.login(userId: userId)

        self.userId = userId
        self.entitlements = userInfo.entitlements

        // Save to keychain for persistence
        KeychainHelper.saveUserId(userId)

        Logger.info("User logged in")

        return userInfo
    }

    /// Log out the current user
    public func logout() {
        userId = nil
        entitlements = []
        experiments?.clearCache()
        KeychainHelper.removeUserId()
        Logger.info("User logged out")
    }

    // MARK: - Offerings

    /// Fetch available offerings (products and pricing)
    /// - Returns: List of offerings with products
    public func getOfferings() async throws -> [Offering] {
        guard let api = api, let store = store else {
            throw CapivvError.notConfigured
        }

        guard let userId = userId else {
            throw CapivvError.notLoggedIn
        }

        // Fetch offerings from backend (passing user_id for personalization)
        let offerings = try await api.getOfferings(userId: userId)

        // Enrich with StoreKit product info
        let productIds = offerings.flatMap { $0.packages.map { $0.storeProductId } }
        let storeProducts = try await store.fetchProducts(identifiers: Set(productIds))

        // Merge store product data into offerings
        return offerings.map { offering in
            var enrichedOffering = offering
            enrichedOffering.packages = offering.packages.map { package in
                var enrichedPackage = package
                enrichedPackage.storeProduct = storeProducts.first { $0.id == package.storeProductId }
                return enrichedPackage
            }
            return enrichedOffering
        }
    }

    // MARK: - Purchases

    /// Purchase a product
    /// - Parameter package: The package to purchase
    /// - Returns: The result of the purchase
    @discardableResult
    public func purchase(package: Package) async throws -> PurchaseResult {
        guard let store = store else {
            throw CapivvError.notConfigured
        }

        guard let storeProduct = package.storeProduct else {
            throw CapivvError.productNotFound
        }

        // Perform StoreKit purchase
        let result = try await store.purchase(product: storeProduct)

        // Update entitlements after successful purchase
        if case .success = result {
            try? await refreshEntitlements()
        }

        return result
    }

    /// Restore previous purchases
    public func restorePurchases() async throws {
        guard let store = store else {
            throw CapivvError.notConfigured
        }

        try await store.restorePurchases()
        try await refreshEntitlements()

        Logger.info("Purchases restored")
    }

    // MARK: - Entitlements

    /// Refresh the current user's entitlements
    public func refreshEntitlements() async throws {
        guard let api = api, let userId = userId else {
            throw CapivvError.notLoggedIn
        }

        let userInfo = try await api.getUserEntitlements(userId: userId)
        self.entitlements = userInfo.entitlements
    }

    /// Check if the user has a specific entitlement
    /// - Parameter identifier: The entitlement identifier
    /// - Returns: Whether the entitlement is active
    public func hasEntitlement(_ identifier: String) -> Bool {
        entitlements.contains { $0.identifier == identifier && $0.isActive }
    }

    /// Get a specific entitlement by identifier
    /// - Parameter identifier: The entitlement identifier
    /// - Returns: The entitlement if found
    public func getEntitlement(_ identifier: String) -> Entitlement? {
        entitlements.first { $0.identifier == identifier }
    }

    // MARK: - Paywalls

    /// Get paywall configuration by identifier
    /// - Parameter identifier: The paywall identifier from the dashboard
    /// - Returns: Paywall configuration with layout, theme, and offering
    public func getPaywallConfig(identifier: String) async throws -> PaywallConfig {
        guard let api = api else {
            throw CapivvError.notConfigured
        }

        guard let userId = userId else {
            throw CapivvError.notLoggedIn
        }

        var config = try await api.getPaywall(identifier: identifier, userId: userId)

        // Enrich offering with StoreKit product info
        if let store = store {
            let productIds = config.offering.packages.map { $0.storeProductId }
            let storeProducts = try await store.fetchProducts(identifiers: Set(productIds))

            var enrichedOffering = config.offering
            enrichedOffering.packages = config.offering.packages.map { package in
                var enrichedPackage = package
                enrichedPackage.storeProduct = storeProducts.first { $0.id == package.storeProductId }
                return enrichedPackage
            }
            config = PaywallConfig(
                id: config.id,
                identifier: config.identifier,
                name: config.name,
                paywallType: config.paywallType,
                offering: enrichedOffering,
                layout: config.layout,
                theme: config.theme,
                experimentVariant: config.experimentVariant,
                isABTest: config.isABTest,
                metadata: config.metadata
            )
        }

        return config
    }

    /// Get dynamic template for a paywall
    /// This enables OTA template updates without requiring app store releases
    /// - Parameter identifier: The paywall identifier from the dashboard
    /// - Returns: Template load result containing the template definition if available
    public func getPaywallTemplate(identifier: String) async throws -> TemplateLoadResult {
        guard let api = api else {
            throw CapivvError.notConfigured
        }

        return try await api.getPaywallTemplate(identifier: identifier)
    }

    // MARK: - Cancellation/Rescue Flow

    /// Get cancellation flow for a subscription
    /// Use this to present the cancellation rescue flow
    /// - Parameter subscriptionId: The subscription identifier
    /// - Returns: Cancellation flow configuration with steps and offers
    public func getCancellationFlow(subscriptionId: String) async throws -> CancellationFlow {
        guard let api = api else {
            throw CapivvError.notConfigured
        }

        guard let userId = userId else {
            throw CapivvError.notLoggedIn
        }

        return try await api.getCancellationFlow(subscriptionId: subscriptionId, userId: userId)
    }

    /// Accept a rescue offer during cancellation flow
    /// - Parameters:
    ///   - offerId: The rescue offer identifier
    ///   - subscriptionId: The subscription identifier
    /// - Returns: Result of accepting the offer
    public func acceptRescueOffer(offerId: String, subscriptionId: String) async throws -> RescueResult {
        guard let api = api else {
            throw CapivvError.notConfigured
        }

        guard let userId = userId else {
            throw CapivvError.notLoggedIn
        }

        let result = try await api.acceptRescueOffer(
            offerId: offerId,
            subscriptionId: subscriptionId,
            userId: userId
        )

        // Update entitlements if offer was accepted
        if result.success {
            try? await refreshEntitlements()
        }

        return result
    }

    /// Submit cancellation reason
    /// - Parameters:
    ///   - subscriptionId: The subscription identifier
    ///   - reason: The cancellation reason
    ///   - feedback: Optional additional feedback
    public func submitCancellationReason(
        subscriptionId: String,
        reason: CancellationReason,
        feedback: String? = nil
    ) async throws {
        guard let api = api else {
            throw CapivvError.notConfigured
        }

        guard let userId = userId else {
            throw CapivvError.notLoggedIn
        }

        try await api.submitCancellationReason(
            subscriptionId: subscriptionId,
            userId: userId,
            reason: reason,
            feedback: feedback
        )
    }

    /// Confirm subscription cancellation
    /// Call this after the user confirms they want to cancel
    /// - Parameter subscriptionId: The subscription identifier
    public func confirmCancellation(subscriptionId: String) async throws {
        guard let api = api else {
            throw CapivvError.notConfigured
        }

        guard let userId = userId else {
            throw CapivvError.notLoggedIn
        }

        try await api.confirmCancellation(subscriptionId: subscriptionId, userId: userId)
        try? await refreshEntitlements()
    }

    // MARK: - Promotions

    /// Get active promotions for the current user
    /// - Returns: List of active promotions
    public func getActivePromotions() async throws -> [Promotion] {
        guard let api = api else {
            throw CapivvError.notConfigured
        }

        guard let userId = userId else {
            throw CapivvError.notLoggedIn
        }

        return try await api.getActivePromotions(userId: userId)
    }

    /// Redeem a promotion code
    /// - Parameter code: The promotion code to redeem
    /// - Returns: Result of the redemption
    public func redeemPromotion(code: String) async throws -> RedemptionResult {
        guard let api = api else {
            throw CapivvError.notConfigured
        }

        guard let userId = userId else {
            throw CapivvError.notLoggedIn
        }

        let result = try await api.redeemPromotion(code: code, userId: userId)

        // Refresh entitlements if redemption was successful
        if result.success {
            try? await refreshEntitlements()
        }

        return result
    }
}
