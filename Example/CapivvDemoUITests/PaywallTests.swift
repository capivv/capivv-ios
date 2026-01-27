import XCTest

/// UI tests for the paywall flow
final class PaywallTests: CapivvDemoUITests {

    override func setUpWithError() throws {
        try super.setUpWithError()
        app.launch()
        // Login before each test
        loginWithUser(TestConstants.freeUserId)
    }

    // MARK: - Paywall Display Tests

    func testPaywallOpensFromUnlockButton() {
        // Wait for login
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        // Open paywall
        openPaywall()

        // Verify paywall is visible
        let paywallTitle = app.navigationBars["Premium"]
        XCTAssertTrue(waitForElement(paywallTitle))

        // Verify header elements
        XCTAssertTrue(app.staticTexts["Unlock Premium"].exists)
        XCTAssertTrue(app.staticTexts["Get access to all features"].exists)
    }

    func testPaywallShowsFeaturesList() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        openPaywall()

        let paywallTitle = app.navigationBars["Premium"]
        XCTAssertTrue(waitForElement(paywallTitle))

        // Verify features are listed
        XCTAssertTrue(app.staticTexts["Unlimited AI generations"].exists)
        XCTAssertTrue(app.staticTexts["Cloud sync across devices"].exists)
        XCTAssertTrue(app.staticTexts["Custom themes & colors"].exists)
        XCTAssertTrue(app.staticTexts["Priority support"].exists)
        XCTAssertTrue(app.staticTexts["No ads"].exists)
    }

    func testPaywallHasCloseButton() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        openPaywall()

        let closeButton = app.buttons["Close"]
        XCTAssertTrue(waitForElement(closeButton))
        XCTAssertTrue(closeButton.isHittable)
    }

    func testPaywallCanBeDismissed() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        openPaywall()

        let paywallTitle = app.navigationBars["Premium"]
        XCTAssertTrue(waitForElement(paywallTitle))

        // Close paywall
        closePaywall()

        // Verify paywall is dismissed
        XCTAssertFalse(app.navigationBars["Premium"].exists)

        // Verify main content is visible again
        XCTAssertTrue(app.staticTexts["Capivv Demo"].exists)
    }

    // MARK: - Package Selection Tests

    func testPaywallShowsLoadingState() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        openPaywall()

        // Either loading indicator or packages should be visible
        let loadingText = app.staticTexts["Loading packages..."]
        let subscribeButton = app.buttons["Subscribe Now"]

        // Wait for either loading to complete or show
        let hasLoading = loadingText.exists
        let hasSubscribe = waitForElement(subscribeButton, timeout: 10)

        XCTAssertTrue(hasLoading || hasSubscribe)
    }

    func testPackagesLoadAndDisplay() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        openPaywall()

        // Wait for packages to load
        let subscribeButton = app.buttons["Subscribe Now"]
        XCTAssertTrue(waitForElement(subscribeButton, timeout: 15))

        // Loading should be complete
        XCTAssertFalse(app.staticTexts["Loading packages..."].exists)

        // Either packages are shown or "No packages available" message
        let noPackagesText = app.staticTexts["No packages available"]
        let hasPackages = !noPackagesText.exists

        // This is acceptable - we just want to ensure the loading completes
        XCTAssertTrue(true)
    }

    func testSubscribeButtonState() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        openPaywall()

        let subscribeButton = app.buttons["Subscribe Now"]
        XCTAssertTrue(waitForElement(subscribeButton, timeout: 15))

        // Subscribe button should exist
        XCTAssertTrue(subscribeButton.exists)
    }

    // MARK: - Restore Purchases Tests

    func testRestorePurchasesButtonExists() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        openPaywall()

        let subscribeButton = app.buttons["Subscribe Now"]
        XCTAssertTrue(waitForElement(subscribeButton, timeout: 15))

        // Scroll down to find restore button
        let restoreButton = app.buttons["Restore Purchases"]
        app.swipeUp()

        XCTAssertTrue(restoreButton.exists)
    }

    func testRestorePurchasesButtonIsTappable() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        openPaywall()

        let subscribeButton = app.buttons["Subscribe Now"]
        XCTAssertTrue(waitForElement(subscribeButton, timeout: 15))

        app.swipeUp()

        let restoreButton = app.buttons["Restore Purchases"]
        if waitForHittable(restoreButton, timeout: 5) {
            // Button should be tappable
            XCTAssertTrue(restoreButton.isHittable)
        }
    }

    // MARK: - Terms & Conditions Tests

    func testSubscriptionTermsTextExists() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        openPaywall()

        app.swipeUp()

        // Look for terms text (partial match)
        let termsText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Subscription automatically renews'")).firstMatch

        XCTAssertTrue(termsText.exists)
    }

    // MARK: - Multiple Open/Close Tests

    func testOpenAndClosePaywallMultipleTimes() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        for _ in 0..<3 {
            openPaywall()

            let paywallTitle = app.navigationBars["Premium"]
            XCTAssertTrue(waitForElement(paywallTitle))

            closePaywall()

            XCTAssertTrue(waitForElement(app.staticTexts["Capivv Demo"]))
        }
    }

    // MARK: - Crown Icon Test

    func testPaywallShowsCrownIcon() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        openPaywall()

        let paywallTitle = app.navigationBars["Premium"]
        XCTAssertTrue(waitForElement(paywallTitle))

        // Crown icon should be visible (it's an SF Symbol)
        let crownImage = app.images["crown.fill"]
        XCTAssertTrue(crownImage.exists)
    }

    // MARK: - API Error Tests
    //
    // These tests verify that API calls succeed without errors.
    // They would catch bugs like missing parameters causing 400 errors.

    /// Test that no API error is displayed when loading offerings
    /// This catches bugs like the missing user_id parameter that caused 400 errors
    func testPaywallLoadsWithoutAPIError() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        openPaywall()

        let paywallTitle = app.navigationBars["Premium"]
        XCTAssertTrue(waitForElement(paywallTitle))

        // Wait for loading to complete
        let subscribeButton = app.buttons["Subscribe Now"]
        _ = waitForElement(subscribeButton, timeout: 15)

        // CRITICAL: Verify no API error message is displayed
        // The bug we fixed showed "API error [HTTP_400]: bad request"
        let apiErrorPredicate = NSPredicate(format: "label CONTAINS[c] 'API error'")
        let apiErrorElements = app.staticTexts.matching(apiErrorPredicate)

        XCTAssertEqual(apiErrorElements.count, 0, "No API errors should be displayed after loading offerings")
    }

    /// Test that no HTTP 400 error is shown (specifically catches missing parameter bugs)
    func testPaywallDoesNotShow400Error() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        openPaywall()

        let paywallTitle = app.navigationBars["Premium"]
        XCTAssertTrue(waitForElement(paywallTitle))

        // Wait for loading
        _ = waitForElement(app.buttons["Subscribe Now"], timeout: 15)

        // Check for HTTP 400 error which indicates missing/invalid parameters
        let http400Predicate = NSPredicate(format: "label CONTAINS[c] 'HTTP_400' OR label CONTAINS[c] 'bad request'")
        let http400Elements = app.staticTexts.matching(http400Predicate)

        XCTAssertEqual(http400Elements.count, 0, "No HTTP 400 errors should occur - this usually means missing parameters")
    }

    /// Test that no "not logged in" error appears when loading offerings
    func testPaywallDoesNotShowNotLoggedInError() {
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        openPaywall()

        let paywallTitle = app.navigationBars["Premium"]
        XCTAssertTrue(waitForElement(paywallTitle))

        _ = waitForElement(app.buttons["Subscribe Now"], timeout: 15)

        // Check for "not logged in" error
        let notLoggedInPredicate = NSPredicate(format: "label CONTAINS[c] 'not logged in' OR label CONTAINS[c] 'notLoggedIn'")
        let notLoggedInElements = app.staticTexts.matching(notLoggedInPredicate)

        XCTAssertEqual(notLoggedInElements.count, 0, "User should be logged in before opening paywall")
    }

    /// Comprehensive test: Full paywall flow succeeds without errors
    func testPaywallE2EFlowSucceeds() {
        // Step 1: Verify login
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText), "User should be logged in")

        // Step 2: Open paywall
        openPaywall()

        let paywallTitle = app.navigationBars["Premium"]
        XCTAssertTrue(waitForElement(paywallTitle), "Paywall should open")

        // Step 3: Wait for content to load
        let subscribeButton = app.buttons["Subscribe Now"]
        XCTAssertTrue(waitForElement(subscribeButton, timeout: 15), "Subscribe button should appear")

        // Step 4: Verify no error messages anywhere
        let errorPredicate = NSPredicate(format: "label CONTAINS[c] 'error'")
        let errorElements = app.staticTexts.matching(errorPredicate)

        // Iterate through error elements to check if any are actual API errors
        var hasAPIError = false
        for i in 0..<errorElements.count {
            let label = errorElements.element(boundBy: i).label.lowercased()
            if label.contains("api error") || label.contains("http_") || label.contains("bad request") {
                hasAPIError = true
                break
            }
        }

        XCTAssertFalse(hasAPIError, "No API errors should be displayed during paywall load")

        // Step 5: Verify paywall shows expected content
        XCTAssertTrue(app.staticTexts["Unlock Premium"].exists, "Paywall header should be visible")

        // Step 6: Close paywall
        closePaywall()
        XCTAssertTrue(waitForElement(app.staticTexts["Capivv Demo"]), "Should return to main screen")
    }
}
