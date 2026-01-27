import XCTest
@testable import Capivv

/// Tests for SDK model types
final class ModelTests: XCTestCase {

    // MARK: - Entitlement Tests

    func testEntitlementInitialization() {
        let expiresAt = Date().addingTimeInterval(86400 * 30) // 30 days from now

        let entitlement = Entitlement(
            id: "ent_123",
            identifier: "premium",
            displayName: "Premium Access",
            isActive: true,
            expiresAt: expiresAt,
            source: .purchase,
            productId: "com.app.premium"
        )

        XCTAssertEqual(entitlement.id, "ent_123")
        XCTAssertEqual(entitlement.identifier, "premium")
        XCTAssertEqual(entitlement.displayName, "Premium Access")
        XCTAssertTrue(entitlement.isActive)
        XCTAssertEqual(entitlement.expiresAt, expiresAt)
        XCTAssertEqual(entitlement.source, .purchase)
        XCTAssertEqual(entitlement.productId, "com.app.premium")
    }

    func testEntitlementWithNilExpiry() {
        let entitlement = Entitlement(
            id: "ent_lifetime",
            identifier: "lifetime",
            displayName: "Lifetime Access",
            isActive: true,
            expiresAt: nil,
            source: .purchase,
            productId: "com.app.lifetime"
        )

        XCTAssertNil(entitlement.expiresAt)
        XCTAssertTrue(entitlement.isActive)
    }

    func testEntitlementFromResponse() {
        let response = EntitlementResponse(
            identifier: "pro",
            isActive: true,
            expiresAt: nil,
            source: "grant"
        )

        let entitlement = Entitlement(from: response)

        XCTAssertEqual(entitlement.identifier, "pro")
        XCTAssertTrue(entitlement.isActive)
        XCTAssertEqual(entitlement.source, .grant)
        XCTAssertNil(entitlement.expiresAt)
    }

    func testEntitlementFromResponseWithExpiry() {
        let expiryDate = Date()

        let response = EntitlementResponse(
            identifier: "premium",
            isActive: true,
            expiresAt: expiryDate,
            source: "purchase"
        )

        let entitlement = Entitlement(from: response)

        XCTAssertEqual(entitlement.expiresAt, expiryDate)
        XCTAssertEqual(entitlement.source, .purchase)
    }

    func testEntitlementFromResponseWithInactiveStatus() {
        let response = EntitlementResponse(
            identifier: "expired_feature",
            isActive: false,
            expiresAt: Date().addingTimeInterval(-86400),
            source: "purchase"
        )

        let entitlement = Entitlement(from: response)

        XCTAssertFalse(entitlement.isActive)
    }

    func testEntitlementFromResponseWithUnknownSource() {
        let response = EntitlementResponse(
            identifier: "test",
            isActive: true,
            expiresAt: nil,
            source: "unknown_source"
        )

        let entitlement = Entitlement(from: response)

        // Should default to .purchase when unknown
        XCTAssertEqual(entitlement.source, .purchase)
    }

    // MARK: - EntitlementSource Tests

    func testEntitlementSourceFromRawValue() {
        XCTAssertEqual(EntitlementSource(rawValue: "purchase"), .purchase)
        XCTAssertEqual(EntitlementSource(rawValue: "grant"), .grant)
        XCTAssertNil(EntitlementSource(rawValue: "invalid"))
    }

    func testEntitlementSourceRawValues() {
        XCTAssertEqual(EntitlementSource.purchase.rawValue, "purchase")
        XCTAssertEqual(EntitlementSource.grant.rawValue, "grant")
    }

    // MARK: - PackageType Tests

    func testPackageTypeFromString() {
        XCTAssertEqual(PackageType(from: "weekly"), .weekly)
        XCTAssertEqual(PackageType(from: "WEEKLY"), .weekly)
        XCTAssertEqual(PackageType(from: "Weekly"), .weekly)

        XCTAssertEqual(PackageType(from: "monthly"), .monthly)
        XCTAssertEqual(PackageType(from: "MONTHLY"), .monthly)

        XCTAssertEqual(PackageType(from: "annual"), .annual)
        XCTAssertEqual(PackageType(from: "yearly"), .annual)
        XCTAssertEqual(PackageType(from: "YEARLY"), .annual)

        XCTAssertEqual(PackageType(from: "lifetime"), .lifetime)
        XCTAssertEqual(PackageType(from: "LIFETIME"), .lifetime)

        XCTAssertEqual(PackageType(from: "two_month"), .twoMonth)
        XCTAssertEqual(PackageType(from: "twomonth"), .twoMonth)

        XCTAssertEqual(PackageType(from: "three_month"), .threeMonth)
        XCTAssertEqual(PackageType(from: "threemonth"), .threeMonth)

        XCTAssertEqual(PackageType(from: "six_month"), .sixMonth)
        XCTAssertEqual(PackageType(from: "sixmonth"), .sixMonth)
    }

    func testPackageTypeDefaultsToCustom() {
        XCTAssertEqual(PackageType(from: "unknown"), .custom)
        XCTAssertEqual(PackageType(from: "random_string"), .custom)
        XCTAssertEqual(PackageType(from: ""), .custom)
        XCTAssertEqual(PackageType(from: "special_offer"), .custom)
    }

    func testPackageTypeRawValues() {
        XCTAssertEqual(PackageType.weekly.rawValue, "weekly")
        XCTAssertEqual(PackageType.monthly.rawValue, "monthly")
        XCTAssertEqual(PackageType.twoMonth.rawValue, "twoMonth")
        XCTAssertEqual(PackageType.threeMonth.rawValue, "threeMonth")
        XCTAssertEqual(PackageType.sixMonth.rawValue, "sixMonth")
        XCTAssertEqual(PackageType.annual.rawValue, "annual")
        XCTAssertEqual(PackageType.lifetime.rawValue, "lifetime")
        XCTAssertEqual(PackageType.custom.rawValue, "custom")
    }

    // MARK: - Package Tests

    func testPackageInitialization() {
        let package = Package(
            id: "pkg_monthly",
            identifier: "monthly",
            packageType: .monthly,
            storeProductId: "com.app.monthly.subscription",
            storeProduct: nil,
            displayName: "Monthly Subscription",
            description: "Pay monthly for full access"
        )

        XCTAssertEqual(package.id, "pkg_monthly")
        XCTAssertEqual(package.identifier, "monthly")
        XCTAssertEqual(package.packageType, .monthly)
        XCTAssertEqual(package.storeProductId, "com.app.monthly.subscription")
        XCTAssertNil(package.storeProduct)
        XCTAssertEqual(package.displayName, "Monthly Subscription")
        XCTAssertEqual(package.description, "Pay monthly for full access")
    }

    func testPackageFromResponse() {
        let response = PackageResponse(
            identifier: "annual",
            packageType: "annual",
            storeProductId: "com.test.annual",
            displayName: "Annual Plan",
            description: "Save 20%"
        )

        let package = Package(from: response)

        XCTAssertEqual(package.id, "annual")
        XCTAssertEqual(package.identifier, "annual")
        XCTAssertEqual(package.packageType, .annual)
        XCTAssertEqual(package.storeProductId, "com.test.annual")
        XCTAssertNil(package.storeProduct)
        XCTAssertEqual(package.displayName, "Annual Plan")
        XCTAssertEqual(package.description, "Save 20%")
    }

    func testPackageConvenienceAccessorsWithoutStoreProduct() {
        let package = Package(
            id: "test",
            identifier: "test",
            packageType: .monthly,
            storeProductId: "com.test",
            storeProduct: nil,
            displayName: "Test",
            description: nil
        )

        XCTAssertNil(package.localizedPriceString)
        XCTAssertNil(package.price)
        XCTAssertNil(package.subscriptionPeriod)
    }

    // MARK: - Offering Tests

    func testOfferingInitialization() {
        let packages = [
            Package(
                id: "monthly",
                identifier: "monthly",
                packageType: .monthly,
                storeProductId: "com.app.monthly",
                displayName: "Monthly",
                description: nil
            ),
            Package(
                id: "annual",
                identifier: "annual",
                packageType: .annual,
                storeProductId: "com.app.annual",
                displayName: "Annual",
                description: nil
            )
        ]

        let offering = Offering(
            id: "default",
            identifier: "default",
            displayName: "Default Offering",
            description: "Our standard packages",
            packages: packages,
            metadata: ["highlighted": "annual"]
        )

        XCTAssertEqual(offering.id, "default")
        XCTAssertEqual(offering.identifier, "default")
        XCTAssertEqual(offering.displayName, "Default Offering")
        XCTAssertEqual(offering.description, "Our standard packages")
        XCTAssertEqual(offering.packages.count, 2)
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
            id: "test",
            identifier: "test",
            displayName: "Test",
            description: nil,
            packages: packages,
            metadata: [:]
        )

        XCTAssertNotNil(offering.weekly)
        XCTAssertEqual(offering.weekly?.identifier, "weekly")

        XCTAssertNotNil(offering.monthly)
        XCTAssertEqual(offering.monthly?.identifier, "monthly")

        XCTAssertNotNil(offering.annual)
        XCTAssertEqual(offering.annual?.identifier, "annual")

        XCTAssertNotNil(offering.lifetime)
        XCTAssertEqual(offering.lifetime?.identifier, "lifetime")
    }

    func testOfferingConvenienceAccessorsWhenMissing() {
        let offering = Offering(
            id: "minimal",
            identifier: "minimal",
            displayName: "Minimal",
            description: nil,
            packages: [],
            metadata: [:]
        )

        XCTAssertNil(offering.weekly)
        XCTAssertNil(offering.monthly)
        XCTAssertNil(offering.annual)
        XCTAssertNil(offering.lifetime)
    }

    func testOfferingFromResponse() {
        let response = OfferingResponse(
            identifier: "premium_tier",
            displayName: "Premium Tier",
            description: "For power users",
            packages: [
                PackageResponse(
                    identifier: "monthly",
                    packageType: "monthly",
                    storeProductId: "com.test.monthly",
                    displayName: "Monthly",
                    description: nil
                )
            ],
            metadata: ["tier": "premium"]
        )

        let offering = Offering(from: response)

        XCTAssertEqual(offering.id, "premium_tier")
        XCTAssertEqual(offering.identifier, "premium_tier")
        XCTAssertEqual(offering.displayName, "Premium Tier")
        XCTAssertEqual(offering.description, "For power users")
        XCTAssertEqual(offering.packages.count, 1)
        XCTAssertEqual(offering.metadata["tier"], "premium")
    }

    func testOfferingFromResponseWithNoMetadata() {
        let response = OfferingResponse(
            identifier: "basic",
            displayName: "Basic",
            description: nil,
            packages: [],
            metadata: nil
        )

        let offering = Offering(from: response)

        XCTAssertTrue(offering.metadata.isEmpty)
        XCTAssertNil(offering.description)
    }

    // MARK: - UserInfo Tests

    func testUserInfoInitialization() {
        let entitlements = [
            Entitlement(
                id: "ent_1",
                identifier: "premium",
                displayName: "Premium",
                isActive: true,
                expiresAt: nil,
                source: .purchase,
                productId: nil
            )
        ]

        let firstSeen = Date()
        let lastSeen = Date()

        let userInfo = UserInfo(
            userId: "user_123",
            capivvUserId: "capivv_456",
            entitlements: entitlements,
            attributes: ["tier": "gold"],
            firstSeenAt: firstSeen,
            lastSeenAt: lastSeen
        )

        XCTAssertEqual(userInfo.userId, "user_123")
        XCTAssertEqual(userInfo.capivvUserId, "capivv_456")
        XCTAssertEqual(userInfo.entitlements.count, 1)
        XCTAssertEqual(userInfo.attributes["tier"], "gold")
        XCTAssertEqual(userInfo.firstSeenAt, firstSeen)
        XCTAssertEqual(userInfo.lastSeenAt, lastSeen)
    }

    func testUserInfoHasEntitlement() {
        let entitlements = [
            Entitlement(id: "1", identifier: "premium", displayName: "Premium", isActive: true, expiresAt: nil, source: .purchase, productId: nil),
            Entitlement(id: "2", identifier: "pro", displayName: "Pro", isActive: false, expiresAt: nil, source: .grant, productId: nil),
            Entitlement(id: "3", identifier: "beta", displayName: "Beta", isActive: true, expiresAt: nil, source: .grant, productId: nil)
        ]

        let userInfo = UserInfo(
            userId: "user",
            capivvUserId: "capivv",
            entitlements: entitlements,
            attributes: [:],
            firstSeenAt: Date(),
            lastSeenAt: Date()
        )

        // Active entitlements
        XCTAssertTrue(userInfo.hasEntitlement("premium"))
        XCTAssertTrue(userInfo.hasEntitlement("beta"))

        // Inactive entitlement
        XCTAssertFalse(userInfo.hasEntitlement("pro"))

        // Non-existent entitlement
        XCTAssertFalse(userInfo.hasEntitlement("nonexistent"))
    }

    func testUserInfoFromResponse() {
        let response = UserInfoResponse(
            user: UserResponse(
                id: "capivv_abc",
                externalId: "user_xyz",
                firstSeenAt: Date(),
                lastSeenAt: Date()
            ),
            entitlements: [
                EntitlementResponse(
                    identifier: "premium",
                    isActive: true,
                    expiresAt: nil,
                    source: "purchase"
                )
            ]
        )

        let userInfo = UserInfo(from: response)

        XCTAssertEqual(userInfo.userId, "user_xyz")
        XCTAssertEqual(userInfo.capivvUserId, "capivv_abc")
        XCTAssertEqual(userInfo.entitlements.count, 1)
        XCTAssertTrue(userInfo.attributes.isEmpty)
    }

    // MARK: - CapivvConfiguration Tests

    func testConfigurationInitialization() {
        let baseURL = URL(string: "https://api.test.com/v1")!

        let config = CapivvConfiguration(
            apiKey: "pk_test_123",
            baseURL: baseURL,
            timeoutInterval: 60,
            debugLoggingEnabled: true
        )

        XCTAssertEqual(config.apiKey, "pk_test_123")
        XCTAssertEqual(config.baseURL, baseURL)
        XCTAssertEqual(config.timeoutInterval, 60)
        XCTAssertTrue(config.debugLoggingEnabled)
    }

    func testConfigurationDefaults() {
        let config = CapivvConfiguration(apiKey: "test_key")

        XCTAssertEqual(config.apiKey, "test_key")
        XCTAssertEqual(config.baseURL.absoluteString, "https://api.capivv.com/v1")
        XCTAssertEqual(config.timeoutInterval, 30)
        XCTAssertFalse(config.debugLoggingEnabled)
    }

    // MARK: - CapivvError Tests

    func testCapivvErrorDescriptions() {
        XCTAssertNotNil(CapivvError.notConfigured.errorDescription)
        XCTAssertTrue(CapivvError.notConfigured.errorDescription!.contains("configured"))

        XCTAssertNotNil(CapivvError.notLoggedIn.errorDescription)
        XCTAssertTrue(CapivvError.notLoggedIn.errorDescription!.contains("logged in"))

        XCTAssertNotNil(CapivvError.productNotFound.errorDescription)
        XCTAssertTrue(CapivvError.productNotFound.errorDescription!.contains("Product"))
    }

    func testCapivvErrorWithUnderlying() {
        let urlError = URLError(.notConnectedToInternet)
        let networkError = CapivvError.networkError(underlying: urlError)

        XCTAssertNotNil(networkError.errorDescription)
    }

    func testCapivvErrorAPIError() {
        let apiError = CapivvError.apiError(code: "RATE_LIMITED", message: "Too many requests")

        XCTAssertNotNil(apiError.errorDescription)
        XCTAssertTrue(apiError.errorDescription!.contains("RATE_LIMITED") || apiError.errorDescription!.contains("Too many requests"))
    }

    func testCapivvErrorReceiptValidation() {
        let receiptError = CapivvError.receiptValidationFailed(reason: "Invalid signature")

        XCTAssertNotNil(receiptError.errorDescription)
    }

    func testCapivvErrorUnknown() {
        let unknownError = CapivvError.unknown(underlying: nil)

        XCTAssertNotNil(unknownError.errorDescription)
    }
}
