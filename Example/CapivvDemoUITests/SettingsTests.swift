import XCTest

/// UI tests for the Settings screen
final class SettingsTests: CapivvDemoUITests {

    override func setUpWithError() throws {
        try super.setUpWithError()
        app.launch()
        // Login before each test
        loginWithUser(TestConstants.testUserId)
    }

    // MARK: - Navigation Tests

    func testNavigateToSettings() {
        // Wait for login
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        // Navigate to settings
        navigateToSettings()

        // Verify settings screen is visible
        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))
    }

    func testNavigateBackFromSettings() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        // Navigate back
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.exists {
            backButton.tap()
        } else {
            // Try swipe gesture
            app.swipeRight()
        }

        // Verify main screen is visible
        XCTAssertTrue(waitForElement(app.staticTexts["Capivv Demo"]))
    }

    // MARK: - Account Section Tests

    func testSettingsShowsUserIdWhenLoggedIn() {
        let userId = TestConstants.testUserId

        // Already logged in from setUp
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        // User ID should be displayed
        XCTAssertTrue(app.staticTexts["User ID"].exists)
        XCTAssertTrue(app.staticTexts[userId].exists)
    }

    func testAccountSectionExists() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        // Account section should exist
        XCTAssertTrue(app.staticTexts["Account"].exists)
    }

    // MARK: - Entitlements Section Tests

    func testEntitlementsSectionExists() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        // Entitlements section should exist
        XCTAssertTrue(app.staticTexts["Entitlements"].exists)
    }

    func testNoEntitlementsMessage() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        // For a new user, "No entitlements" should be visible
        // (or entitlements list if they have some)
        let noEntitlementsText = app.staticTexts["No entitlements"]
        let entitlementsSection = app.staticTexts["Entitlements"]

        XCTAssertTrue(entitlementsSection.exists)
        // Either shows no entitlements or has actual entitlements
        XCTAssertTrue(noEntitlementsText.exists || !app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'premium'")).firstMatch.exists)
    }

    func testRefreshEntitlementsButtonExists() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        let refreshButton = app.buttons["Refresh Entitlements"]
        XCTAssertTrue(refreshButton.exists)
    }

    func testRefreshEntitlementsButtonIsEnabled() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        let refreshButton = app.buttons["Refresh Entitlements"]
        XCTAssertTrue(refreshButton.isEnabled)
    }

    // MARK: - Subscription Section Tests

    func testSubscriptionSectionExists() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        XCTAssertTrue(app.staticTexts["Subscription"].exists)
    }

    func testRestorePurchasesButtonInSettings() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        // May need to scroll to see it
        app.swipeUp()

        let restoreButton = app.buttons["Restore Purchases"]
        XCTAssertTrue(restoreButton.exists)
    }

    func testManageSubscriptionLinkExists() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        app.swipeUp()

        // SwiftUI Link elements can appear as various element types
        let managePredicate = NSPredicate(format: "label == 'Manage Subscription'")
        let manageElements = app.descendants(matching: .any).matching(managePredicate)
        XCTAssertTrue(manageElements.count > 0, "Manage Subscription link should exist")
    }

    // MARK: - About Section Tests

    func testAboutSectionExists() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        app.swipeUp()

        XCTAssertTrue(app.staticTexts["About"].exists)
    }

    func testSDKVersionDisplayed() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        app.swipeUp()

        XCTAssertTrue(app.staticTexts["SDK Version"].exists)
        XCTAssertTrue(app.staticTexts["1.0.0"].exists)
    }

    func testAppVersionDisplayed() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        app.swipeUp()

        XCTAssertTrue(app.staticTexts["App Version"].exists)
    }

    func testPrivacyPolicyLinkExists() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        app.swipeUp()

        // SwiftUI Link elements can appear as various element types
        let predicate = NSPredicate(format: "label == 'Privacy Policy'")
        let elements = app.descendants(matching: .any).matching(predicate)
        XCTAssertTrue(elements.count > 0, "Privacy Policy link should exist")
    }

    func testTermsOfServiceLinkExists() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        app.swipeUp()

        // SwiftUI Link elements can appear as various element types
        let predicate = NSPredicate(format: "label == 'Terms of Service'")
        let elements = app.descendants(matching: .any).matching(predicate)
        XCTAssertTrue(elements.count > 0, "Terms of Service link should exist")
    }

    // MARK: - Debug Section Tests (only in DEBUG builds)

    #if DEBUG
    func testDebugSectionExists() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        app.swipeUp()
        app.swipeUp()

        XCTAssertTrue(app.staticTexts["Debug"].exists)
    }

    func testClearStoredUserButton() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        navigateToSettings()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(waitForElement(settingsTitle))

        app.swipeUp()
        app.swipeUp()

        let clearButton = app.buttons["Clear Stored User"]
        XCTAssertTrue(clearButton.exists)
    }
    #endif
}
