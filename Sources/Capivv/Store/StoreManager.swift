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
            await processTransaction(transaction)
            await transaction.finish()
        case .unverified(let transaction, let error):
            Logger.error("Unverified transaction: \(error.localizedDescription)")
            // Still finish to prevent it from being delivered again
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

                    // Validate receipt with backend
                    await processTransaction(transaction)

                    // Finish the transaction
                    await transaction.finish()

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

        // Process all current entitlements
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                await processTransaction(transaction)
            case .unverified(_, let error):
                Logger.error("Unverified entitlement: \(error)")
            }
        }

        Logger.info("Purchases restored")
    }

    // MARK: - Receipt Processing

    private func processTransaction(_ transaction: Transaction) async {
        Logger.debug("Processing transaction: \(transaction.productID)")

        // Get the user ID from Capivv
        guard let userId = await Capivv.shared.userId else {
            Logger.warning("No user logged in, skipping receipt validation")
            return
        }

        // Get app receipt data
        guard let receiptData = await getReceiptData() else {
            Logger.error("Could not get receipt data")
            return
        }

        do {
            let result = try await api.validateReceipt(
                userId: userId,
                receiptData: receiptData,
                productId: transaction.productID,
                transactionId: String(transaction.id),
                originalTransactionId: String(transaction.originalID)
            )

            if result.success {
                Logger.info("Receipt validated successfully")
                // Refresh entitlements to get updated status
                try? await Capivv.shared.refreshEntitlements()
            } else {
                Logger.error("Receipt validation failed")
            }
        } catch {
            Logger.error("Receipt validation error: \(error)")
        }
    }

    private func getReceiptData() async -> String? {
        // For StoreKit 2, we use the App Store receipt
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            return nil
        }

        do {
            let receiptData = try Data(contentsOf: appStoreReceiptURL)
            return receiptData.base64EncodedString()
        } catch {
            Logger.error("Failed to read receipt: \(error)")
            return nil
        }
    }
}
