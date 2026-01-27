import XCTest
@testable import Capivv

final class CapivvTests: XCTestCase {

    // MARK: - Configuration Tests

    func testConfigurationCreation() {
        let config = CapivvConfiguration(
            apiKey: "test_api_key",
            baseURL: URL(string: "https://api.example.com")!
        )

        XCTAssertEqual(config.apiKey, "test_api_key")
        XCTAssertEqual(config.baseURL.absoluteString, "https://api.example.com")
        XCTAssertEqual(config.timeoutInterval, 30)
    }

    func testConfigurationWithCustomTimeout() {
        let config = CapivvConfiguration(
            apiKey: "test_key",
            baseURL: URL(string: "https://api.test.com")!,
            timeoutInterval: 60
        )

        XCTAssertEqual(config.timeoutInterval, 60)
    }

    func testConfigurationWithDebugLogging() {
        let config = CapivvConfiguration(
            apiKey: "test_key",
            debugLoggingEnabled: true
        )

        XCTAssertTrue(config.debugLoggingEnabled)
    }

    func testConfigurationDefaultValues() {
        let config = CapivvConfiguration(apiKey: "minimal_key")

        XCTAssertEqual(config.apiKey, "minimal_key")
        XCTAssertEqual(config.baseURL.absoluteString, "https://api.capivv.com/v1")
        XCTAssertEqual(config.timeoutInterval, 30)
        XCTAssertFalse(config.debugLoggingEnabled)
    }

    // MARK: - EntitlementSource Tests

    func testEntitlementSource() {
        XCTAssertEqual(EntitlementSource(rawValue: "purchase"), .purchase)
        XCTAssertEqual(EntitlementSource(rawValue: "grant"), .grant)
        XCTAssertNil(EntitlementSource(rawValue: "unknown"))
    }

    func testEntitlementSourceRawValue() {
        XCTAssertEqual(EntitlementSource.purchase.rawValue, "purchase")
        XCTAssertEqual(EntitlementSource.grant.rawValue, "grant")
    }

    // MARK: - PackageType Tests

    func testPackageType() {
        XCTAssertEqual(PackageType(from: "monthly"), .monthly)
        XCTAssertEqual(PackageType(from: "annual"), .annual)
        XCTAssertEqual(PackageType(from: "yearly"), .annual)
        XCTAssertEqual(PackageType(from: "weekly"), .weekly)
        XCTAssertEqual(PackageType(from: "lifetime"), .lifetime)
        XCTAssertEqual(PackageType(from: "unknown"), .custom)
    }

    func testPackageTypeCaseInsensitive() {
        XCTAssertEqual(PackageType(from: "MONTHLY"), .monthly)
        XCTAssertEqual(PackageType(from: "Annual"), .annual)
        XCTAssertEqual(PackageType(from: "WEEKLY"), .weekly)
        XCTAssertEqual(PackageType(from: "Lifetime"), .lifetime)
    }

    func testPackageTypeMultiMonth() {
        XCTAssertEqual(PackageType(from: "two_month"), .twoMonth)
        XCTAssertEqual(PackageType(from: "three_month"), .threeMonth)
        XCTAssertEqual(PackageType(from: "six_month"), .sixMonth)
    }

    // MARK: - CapivvError Tests

    func testCapivvErrorDescriptions() {
        XCTAssertNotNil(CapivvError.notConfigured.errorDescription)
        XCTAssertNotNil(CapivvError.notLoggedIn.errorDescription)
        XCTAssertNotNil(CapivvError.productNotFound.errorDescription)
    }

    func testCapivvErrorNotConfiguredMessage() {
        let error = CapivvError.notConfigured
        XCTAssertTrue(error.errorDescription?.contains("configure") ?? false)
    }

    func testCapivvErrorNotLoggedInMessage() {
        let error = CapivvError.notLoggedIn
        XCTAssertTrue(error.errorDescription?.contains("login") ?? false)
    }

    func testCapivvErrorProductNotFoundMessage() {
        let error = CapivvError.productNotFound
        XCTAssertTrue(error.errorDescription?.lowercased().contains("product") ?? false)
    }

    func testCapivvErrorNetworkError() {
        let urlError = URLError(.notConnectedToInternet)
        let error = CapivvError.networkError(underlying: urlError)
        XCTAssertNotNil(error.errorDescription)
    }

    func testCapivvErrorAPIError() {
        let error = CapivvError.apiError(code: "INVALID_KEY", message: "API key is invalid")
        XCTAssertNotNil(error.errorDescription)
    }

    func testCapivvErrorStoreKitError() {
        let storeError = NSError(domain: "StoreKit", code: 1, userInfo: nil)
        let error = CapivvError.storeKitError(underlying: storeError)
        XCTAssertNotNil(error.errorDescription)
    }

    func testCapivvErrorReceiptValidationFailed() {
        let error = CapivvError.receiptValidationFailed(reason: "Invalid signature")
        XCTAssertNotNil(error.errorDescription)
    }

    func testCapivvErrorUnknown() {
        let error = CapivvError.unknown(underlying: nil)
        XCTAssertNotNil(error.errorDescription)
    }

    func testCapivvErrorUnknownWithUnderlying() {
        let underlyingError = NSError(domain: "Test", code: 123, userInfo: nil)
        let error = CapivvError.unknown(underlying: underlyingError)
        XCTAssertNotNil(error.errorDescription)
    }

    // MARK: - Entitlement Tests

    func testEntitlementIdentifiable() {
        let entitlement = Entitlement(
            id: "ent_123",
            identifier: "premium",
            displayName: "Premium",
            isActive: true,
            expiresAt: nil,
            source: .purchase,
            productId: nil
        )

        XCTAssertEqual(entitlement.id, "ent_123")
    }

    func testEntitlementWithExpiry() {
        let futureDate = Date().addingTimeInterval(86400 * 30)

        let entitlement = Entitlement(
            id: "ent_456",
            identifier: "subscription",
            displayName: "Monthly Subscription",
            isActive: true,
            expiresAt: futureDate,
            source: .purchase,
            productId: "com.app.monthly"
        )

        XCTAssertNotNil(entitlement.expiresAt)
        XCTAssertEqual(entitlement.productId, "com.app.monthly")
    }

    func testEntitlementFromGrant() {
        let entitlement = Entitlement(
            id: "ent_grant",
            identifier: "beta_access",
            displayName: "Beta Access",
            isActive: true,
            expiresAt: nil,
            source: .grant,
            productId: nil
        )

        XCTAssertEqual(entitlement.source, .grant)
        XCTAssertNil(entitlement.productId)
    }

    // MARK: - Package Tests

    func testPackageIdentifiable() {
        let package = Package(
            id: "pkg_monthly",
            identifier: "monthly",
            packageType: .monthly,
            storeProductId: "com.app.monthly",
            storeProduct: nil,
            displayName: "Monthly",
            description: nil
        )

        XCTAssertEqual(package.id, "pkg_monthly")
    }

    func testPackageWithDescription() {
        let package = Package(
            id: "pkg_annual",
            identifier: "annual",
            packageType: .annual,
            storeProductId: "com.app.annual",
            storeProduct: nil,
            displayName: "Annual - Save 20%",
            description: "Pay once, save 20% compared to monthly"
        )

        XCTAssertNotNil(package.description)
        XCTAssertEqual(package.packageType, .annual)
    }

    // MARK: - Offering Tests

    func testOfferingIdentifiable() {
        let offering = Offering(
            id: "default",
            identifier: "default",
            displayName: "Default Offering",
            description: nil,
            packages: [],
            metadata: [:]
        )

        XCTAssertEqual(offering.id, "default")
    }

    func testOfferingWithPackages() {
        let packages = [
            Package(id: "m", identifier: "monthly", packageType: .monthly, storeProductId: "m", displayName: "Monthly", description: nil),
            Package(id: "a", identifier: "annual", packageType: .annual, storeProductId: "a", displayName: "Annual", description: nil)
        ]

        let offering = Offering(
            id: "premium",
            identifier: "premium",
            displayName: "Premium Offering",
            description: "Get full access",
            packages: packages,
            metadata: ["highlighted": "annual"]
        )

        XCTAssertEqual(offering.packages.count, 2)
        XCTAssertNotNil(offering.monthly)
        XCTAssertNotNil(offering.annual)
        XCTAssertEqual(offering.metadata["highlighted"], "annual")
    }

    func testOfferingConvenienceAccessors() {
        let packages = [
            Package(id: "w", identifier: "weekly", packageType: .weekly, storeProductId: "w", displayName: "Weekly", description: nil),
            Package(id: "m", identifier: "monthly", packageType: .monthly, storeProductId: "m", displayName: "Monthly", description: nil),
            Package(id: "a", identifier: "annual", packageType: .annual, storeProductId: "a", displayName: "Annual", description: nil),
            Package(id: "l", identifier: "lifetime", packageType: .lifetime, storeProductId: "l", displayName: "Lifetime", description: nil)
        ]

        let offering = Offering(
            id: "full",
            identifier: "full",
            displayName: "Full Offering",
            description: nil,
            packages: packages,
            metadata: [:]
        )

        XCTAssertNotNil(offering.weekly)
        XCTAssertNotNil(offering.monthly)
        XCTAssertNotNil(offering.annual)
        XCTAssertNotNil(offering.lifetime)
    }

    // MARK: - UserInfo Tests

    func testUserInfoHasEntitlement() {
        let entitlements = [
            Entitlement(id: "1", identifier: "premium", displayName: "Premium", isActive: true, expiresAt: nil, source: .purchase, productId: nil),
            Entitlement(id: "2", identifier: "inactive", displayName: "Inactive", isActive: false, expiresAt: nil, source: .grant, productId: nil)
        ]

        let userInfo = UserInfo(
            userId: "user",
            capivvUserId: "capivv",
            entitlements: entitlements,
            attributes: [:],
            firstSeenAt: Date(),
            lastSeenAt: Date()
        )

        XCTAssertTrue(userInfo.hasEntitlement("premium"))
        XCTAssertFalse(userInfo.hasEntitlement("inactive"))
        XCTAssertFalse(userInfo.hasEntitlement("nonexistent"))
    }

    // MARK: - JSON Decoding Tests

    func testEntitlementResponseDecoding() throws {
        let json = """
        {
            "identifier": "premium",
            "is_active": true,
            "expires_at": "2025-12-31T23:59:59Z",
            "source": "purchase"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(EntitlementResponse.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(response.identifier, "premium")
        XCTAssertTrue(response.isActive)
        XCTAssertNotNil(response.expiresAt)
        XCTAssertEqual(response.source, "purchase")
    }

    func testEntitlementResponseDecodingWithNullExpiry() throws {
        let json = """
        {
            "identifier": "lifetime",
            "is_active": true,
            "expires_at": null,
            "source": "purchase"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(EntitlementResponse.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(response.identifier, "lifetime")
        XCTAssertNil(response.expiresAt)
    }

    func testPackageResponseDecoding() throws {
        let json = """
        {
            "identifier": "annual",
            "package_type": "annual",
            "store_product_id": "com.app.annual",
            "display_name": "Annual Subscription",
            "description": "Save 20% with annual"
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(PackageResponse.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(response.identifier, "annual")
        XCTAssertEqual(response.packageType, "annual")
        XCTAssertEqual(response.storeProductId, "com.app.annual")
        XCTAssertEqual(response.displayName, "Annual Subscription")
        XCTAssertEqual(response.description, "Save 20% with annual")
    }

    func testOfferingResponseDecoding() throws {
        let json = """
        {
            "identifier": "default",
            "display_name": "Default Offering",
            "description": null,
            "packages": [],
            "metadata": {"key": "value"}
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(OfferingResponse.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(response.identifier, "default")
        XCTAssertEqual(response.displayName, "Default Offering")
        XCTAssertNil(response.description)
        XCTAssertTrue(response.packages.isEmpty)
        XCTAssertEqual(response.metadata?["key"], "value")
    }

    func testUserResponseDecoding() throws {
        let json = """
        {
            "id": "capivv_123",
            "external_id": "user_456",
            "first_seen_at": "2024-01-01T00:00:00Z",
            "last_seen_at": "2024-06-15T12:30:00Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(UserResponse.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(response.id, "capivv_123")
        XCTAssertEqual(response.externalId, "user_456")
        XCTAssertNotNil(response.firstSeenAt)
        XCTAssertNotNil(response.lastSeenAt)
    }
}
