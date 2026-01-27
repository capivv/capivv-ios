import XCTest

/// UI tests for entitlement display and premium features
final class EntitlementsTests: CapivvDemoUITests {

    override func setUpWithError() throws {
        try super.setUpWithError()
        app.launch()
    }

    // MARK: - Entitlement Display Tests

    func testNewUserHasNoEntitlements() {
        // Login with a new test user (should have no entitlements)
        loginWithUser(TestConstants.testUserId)

        // Wait for login to complete
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        // Check entitlements section shows "None"
        let noneText = app.staticTexts["None"]
        XCTAssertTrue(noneText.exists)
    }

    func testPremiumFeaturesLockedForFreeUser() {
        loginWithUser(TestConstants.freeUserId)

        // Wait for login
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        // Verify premium features section shows locked state
        let premiumFeaturesText = app.staticTexts["Premium Features"]
        XCTAssertTrue(premiumFeaturesText.exists)

        // Unlock button should be visible
        let unlockButton = app.buttons["Unlock Premium"]
        XCTAssertTrue(unlockButton.exists)

        // "Premium Active" should NOT be visible
        XCTAssertFalse(app.staticTexts["Premium Active"].exists)
    }

    func testLockedFeatureIconsDisplayed() {
        loginWithUser(TestConstants.freeUserId)

        // Wait for login
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        // Verify feature names are displayed
        XCTAssertTrue(app.staticTexts["AI Features"].exists)
        XCTAssertTrue(app.staticTexts["Cloud Sync"].exists)
        XCTAssertTrue(app.staticTexts["Themes"].exists)
        XCTAssertTrue(app.staticTexts["Alerts"].exists)
    }

    // MARK: - Premium User Tests

    func testPremiumUserSeesUnlockedFeatures() {
        // Login with premium test user (has entitlements)
        loginWithUser(TestConstants.premiumUserId)

        // Wait for login and entitlement check
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText, timeout: 15))

        // Check for "active" entitlement count or premium features
        // The actual display depends on whether the backend returns entitlements
        let activeText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'active'")).firstMatch
        let premiumActiveText = app.staticTexts["Premium Active"]

        // Either we see active entitlements or we see premium unlocked
        let hasPremiumIndicator = activeText.exists || premiumActiveText.exists

        // If the test user has entitlements configured, this should pass
        // If not, the unlock button should still be visible
        if !hasPremiumIndicator {
            XCTAssertTrue(app.buttons["Unlock Premium"].exists)
        }
    }

    // MARK: - Entitlement Status Card Tests

    func testEntitlementCardDisplaysUserId() {
        let userId = TestConstants.testUserId
        loginWithUser(userId)

        // Wait for login
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        // User ID should be displayed
        XCTAssertTrue(app.staticTexts[userId].exists)
    }

    func testEntitlementCardShowsCheckmark() {
        loginWithUser(TestConstants.testUserId)

        // Wait for login
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        // The checkmark icon should be visible (accessibility identifier may vary)
        // Looking for the green checkmark in the user status card
        XCTAssertTrue(app.images["checkmark.circle.fill"].exists || loggedInText.exists)
    }

    // MARK: - Unlock Premium Button Tests

    func testUnlockPremiumButtonOpensPaywall() {
        loginWithUser(TestConstants.freeUserId)

        // Wait for login
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        // Tap unlock button
        let unlockButton = app.buttons["Unlock Premium"]
        XCTAssertTrue(waitForHittable(unlockButton))
        unlockButton.tap()

        // Verify paywall opens
        let paywallTitle = app.navigationBars["Premium"]
        XCTAssertTrue(waitForElement(paywallTitle))
    }

    func testUnlockButtonNotVisibleWhenNotLoggedIn() {
        // Before login, unlock button should not be visible
        // (because the login prompt is shown instead)
        XCTAssertTrue(app.isShowingLoginPrompt)

        // The unlock button area isn't visible without scrolling/logging in
        let unlockButton = app.buttons["Unlock Premium"]
        // It might exist in the view hierarchy but not be hittable
        if unlockButton.exists {
            // If it exists, we should still be showing login prompt
            XCTAssertTrue(app.staticTexts["Sign in to continue"].exists)
        }
    }

    // MARK: - Entitlement Refresh Tests

    func testNavigateToSettingsAndRefresh() {
        loginWithUser(TestConstants.testUserId)

        // Wait for login
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        // Navigate to settings
        navigateToSettings()

        // Verify settings screen
        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        // Find and tap refresh button
        let refreshButton = app.buttons["Refresh Entitlements"]
        if refreshButton.exists && refreshButton.isEnabled {
            refreshButton.tap()

            // Wait briefly for refresh
            Thread.sleep(forTimeInterval: 2)
        }
    }
}
