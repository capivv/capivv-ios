import Foundation
import StoreKit

/// Manages StoreKit 2 operations
actor StoreManager {
    private let api: CapivvAPI
    private var transactionListener: Task<Void, Error>?
    private var cachedProducts: [String: Product] = [:]

    init(api: CapivvAPI) {
        self.api = api
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Transaction Observing

    /// Start listening for transactions (renewals, refunds, etc.)
    func startObservingTransactions() async {
        transactionListener = Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                await self.handleTransactionUpdate(result)
            }
        }
    }

    private func handleTransactionUpdate(_ result: VerificationResult<Transaction>) async {
        switch result {
        case .verified(let transaction):
            Logger.info("Transaction update received: \(transaction.productID)")
            // Only finish once Capivv has recorded it. An unfinished transaction
            // is redelivered by StoreKit on the next launch, which is our retry.
            if await submit(result) == nil {
                await transaction.finish()
            }
        case .unverified(let transaction, let error):
            Logger.error("Unverified transaction: \(error.localizedDescription)")
            // StoreKit couldn't verify it, so Capivv's server-side check would
            // reject it too. Finish to prevent endless redelivery.
            await transaction.finish()
        }
    }

    // MARK: - Product Fetching

    /// Fetch products from the App Store
    func fetchProducts(identifiers: Set<String>) async throws -> [Product] {
        // Return cached products if available
        let uncachedIds = identifiers.filter { cachedProducts[$0] == nil }

        if uncachedIds.isEmpty {
            return identifiers.compactMap { cachedProducts[$0] }
        }

        Logger.debug("Fetching products: \(uncachedIds)")

        do {
            let products = try await Product.products(for: uncachedIds)

            // Cache the products
            for product in products {
                cachedProducts[product.id] = product
            }

            Logger.info("Fetched \(products.count) products")
            return identifiers.compactMap { cachedProducts[$0] }
        } catch {
            Logger.error("Failed to fetch products: \(error)")
            throw CapivvError.storeKitError(underlying: error)
        }
    }

    // MARK: - Purchasing

    /// Purchase a product
    func purchase(product: Product) async throws -> PurchaseResult {
        Logger.info("Starting purchase for: \(product.id)")

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    Logger.info("Purchase successful: \(transaction.productID)")

                    // The user has been charged, so this is a success either way.
                    // If Capivv didn't record it, leave the transaction unfinished
                    // so StoreKit redelivers it via Transaction.updates.
                    if await submit(verification) == nil {
                        await transaction.finish()
                    }

                    return .success(transaction: transaction)

                case .unverified(let transaction, let error):
                    Logger.error("Purchase unverified: \(error)")
                    await transaction.finish()
                    return .failed(CapivvError.receiptValidationFailed(reason: error.localizedDescription))
                }

            case .userCancelled:
                Logger.info("User cancelled purchase")
                return .userCancelled

            case .pending:
                Logger.info("Purchase pending")
                return .pending

            @unknown default:
                Logger.error("Unknown purchase result")
                return .failed(CapivvError.unknown(underlying: nil))
            }
        } catch {
            Logger.error("Purchase failed: \(error)")
            throw CapivvError.storeKitError(underlying: error)
        }
    }

    // MARK: - Restore Purchases

    /// Restore previous purchases
    func restorePurchases() async throws {
        Logger.info("Restoring purchases")

        // Sync with App Store
        try await AppStore.sync()

        let failures = await syncCurrentEntitlements()
        if !failures.isEmpty {
            throw CapivvError.receiptValidationFailed(reason: failures.joined(separator: "; "))
        }

        Logger.info("Purchases restored")
    }

    /// Send every current entitlement to Capivv. Unlike `restorePurchases`,
    /// this never calls `AppStore.sync()`, so it doesn't prompt for an Apple ID
    /// and is safe to run on login to backfill existing subscribers.
    /// - Returns: A description of each transaction that failed to sync.
    @discardableResult
    func syncCurrentEntitlements() async -> [String] {
        var failures: [String] = []
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if let error = await submit(result) {
                    failures.append("\(transaction.productID): \(error)")
                }
            case .unverified(let transaction, let error):
                Logger.error("Unverified entitlement: \(error)")
                failures.append("\(transaction.productID): unverified (\(error.localizedDescription))")
            }
        }
        return failures
    }

    // MARK: - Transaction Submission

    /// Submit a verified transaction's JWS to Capivv.
    /// - Returns: `nil` on success, otherwise a description of the failure,
    ///   which is also logged and published on `Capivv.lastPurchaseSyncError`.
    private func submit(_ result: VerificationResult<Transaction>) async -> String? {
        guard case .verified(let transaction) = result else {
            return "transaction is unverified"
        }
        Logger.debug("Submitting transaction: \(transaction.productID)")

        guard let userId = await Capivv.shared.userId else {
            let message = "No user logged in; transaction \(transaction.id) not sent to Capivv"
            Logger.warning(message)
            await Capivv.shared.recordPurchaseSync(error: message)
            return message
        }

        do {
            let response = try await api.submitTransaction(
                userId: userId,
                signedTransaction: result.jwsRepresentation,
                productId: transaction.productID,
                transactionId: String(transaction.id),
                bundleId: Bundle.main.bundleIdentifier
            )

            guard response.success else {
                let message = response.message ?? "Capivv rejected transaction \(transaction.id)"
                Logger.error("Transaction sync failed: \(message)")
                await Capivv.shared.recordPurchaseSync(error: message)
                return message
            }

            Logger.info("Transaction \(transaction.id) recorded by Capivv")
            await Capivv.shared.recordPurchaseSync(error: nil)
            try? await Capivv.shared.refreshEntitlements()
            return nil
        } catch {
            let message = "\(error)"
            Logger.error("Transaction sync failed: \(message)")
            await Capivv.shared.recordPurchaseSync(error: message)
            return message
        }
    }
}
