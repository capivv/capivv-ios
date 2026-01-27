import Foundation
import StoreKit

/// A collection of packages available for purchase
public struct Offering: Identifiable, Sendable {
    /// Unique identifier for this offering
    public let id: String

    /// The offering identifier (e.g., "default", "premium_tier")
    public let identifier: String

    /// Display name
    public let displayName: String

    /// Description
    public let description: String?

    /// Available packages in this offering
    public var packages: [Package]

    /// Metadata from the backend
    public let metadata: [String: String]

    public init(
        id: String,
        identifier: String,
        displayName: String,
        description: String?,
        packages: [Package],
        metadata: [String: String]
    ) {
        self.id = id
        self.identifier = identifier
        self.displayName = displayName
        self.description = description
        self.packages = packages
        self.metadata = metadata
    }

    // MARK: - Convenience Accessors

    /// The monthly package, if available
    public var monthly: Package? {
        packages.first { $0.packageType == .monthly }
    }

    /// The annual package, if available
    public var annual: Package? {
        packages.first { $0.packageType == .annual }
    }

    /// The weekly package, if available
    public var weekly: Package? {
        packages.first { $0.packageType == .weekly }
    }

    /// The lifetime package, if available
    public var lifetime: Package? {
        packages.first { $0.packageType == .lifetime }
    }
}

/// A purchasable package within an offering
public struct Package: Identifiable, Sendable {
    /// Unique identifier
    public let id: String

    /// Package identifier
    public let identifier: String

    /// The type of package (monthly, annual, etc.)
    public let packageType: PackageType

    /// Store product ID (App Store Connect product ID)
    public let storeProductId: String

    /// The StoreKit product (populated after fetching from App Store)
    public var storeProduct: Product?

    /// Display name from backend
    public let displayName: String

    /// Description from backend
    public let description: String?

    public init(
        id: String,
        identifier: String,
        packageType: PackageType,
        storeProductId: String,
        storeProduct: Product? = nil,
        displayName: String,
        description: String?
    ) {
        self.id = id
        self.identifier = identifier
        self.packageType = packageType
        self.storeProductId = storeProductId
        self.storeProduct = storeProduct
        self.displayName = displayName
        self.description = description
    }

    // MARK: - Convenience Accessors

    /// Localized price string from StoreKit
    public var localizedPriceString: String? {
        storeProduct?.displayPrice
    }

    /// Price as Decimal
    public var price: Decimal? {
        storeProduct?.price
    }

    /// Subscription period, if applicable
    public var subscriptionPeriod: Product.SubscriptionPeriod? {
        storeProduct?.subscription?.subscriptionPeriod
    }
}

/// Type of package
public enum PackageType: String, Codable, Sendable {
    case weekly
    case monthly
    case twoMonth
    case threeMonth
    case sixMonth
    case annual
    case lifetime
    case custom

    init(from string: String) {
        switch string.lowercased() {
        case "weekly": self = .weekly
        case "monthly": self = .monthly
        case "two_month", "twomonth": self = .twoMonth
        case "three_month", "threemonth": self = .threeMonth
        case "six_month", "sixmonth": self = .sixMonth
        case "annual", "yearly": self = .annual
        case "lifetime": self = .lifetime
        default: self = .custom
        }
    }
}

// MARK: - API Response Mapping

extension Offering {
    init(from response: OfferingResponse) {
        self.id = response.identifier
        self.identifier = response.identifier
        self.displayName = response.displayName
        self.description = response.description
        self.packages = response.packages.map { Package(from: $0) }
        self.metadata = response.metadata ?? [:]
    }
}

extension Package {
    init(from response: PackageResponse) {
        self.id = response.identifier
        self.identifier = response.identifier
        self.packageType = PackageType(from: response.packageType)
        self.storeProductId = response.storeProductId
        self.storeProduct = nil
        self.displayName = response.displayName
        self.description = response.description
    }
}

struct OfferingResponse: Codable {
    let identifier: String
    let displayName: String
    let description: String?
    let packages: [PackageResponse]
    let metadata: [String: String]?

    enum CodingKeys: String, CodingKey {
        case identifier
        case displayName = "display_name"
        case description
        case packages
        case metadata
    }
}

struct PackageResponse: Codable {
    let identifier: String
    let packageType: String
    let storeProductId: String
    let displayName: String
    let description: String?

    enum CodingKeys: String, CodingKey {
        case identifier
        case packageType = "package_type"
        case storeProductId = "store_product_id"
        case displayName = "display_name"
        case description
    }
}
