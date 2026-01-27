import Foundation
import StoreKit

/// Result of a purchase operation
public enum PurchaseResult: Sendable {
    /// Purchase was successful
    case success(transaction: Transaction)

    /// User cancelled the purchase
    case userCancelled

    /// Purchase is pending (e.g., parental approval needed)
    case pending

    /// Purchase failed with an error
    case failed(Error)
}

/// Errors that can occur in the Capivv SDK
public enum CapivvError: LocalizedError, Sendable {
    /// SDK has not been configured
    case notConfigured

    /// No user is logged in
    case notLoggedIn

    /// Product not found in App Store
    case productNotFound

    /// Network request failed
    case networkError(underlying: Error)

    /// API returned an error
    case apiError(code: String, message: String)

    /// StoreKit error
    case storeKitError(underlying: Error)

    /// Receipt validation failed
    case receiptValidationFailed(reason: String)

    /// Experiment variant not assigned
    case experimentNotAssigned

    /// Paywall not found
    case paywallNotFound

    /// Unknown error
    case unknown(underlying: Error?)

    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Capivv SDK has not been configured. Call Capivv.shared.configure(apiKey:) first."
        case .notLoggedIn:
            return "No user is logged in. Call Capivv.shared.login(userId:) first."
        case .productNotFound:
            return "Product not found in the App Store."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .apiError(let code, let message):
            return "API error [\(code)]: \(message)"
        case .storeKitError(let error):
            return "StoreKit error: \(error.localizedDescription)"
        case .receiptValidationFailed(let reason):
            return "Receipt validation failed: \(reason)"
        case .experimentNotAssigned:
            return "Experiment variant has not been assigned. Call getVariant first."
        case .paywallNotFound:
            return "Paywall configuration not found."
        case .unknown(let error):
            return "Unknown error: \(error?.localizedDescription ?? "No details available")"
        }
    }
}
