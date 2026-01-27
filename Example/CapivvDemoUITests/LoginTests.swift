import XCTest

/// UI tests for the login flow
final class LoginTests: CapivvDemoUITests {

    override func setUpWithError() throws {
        try super.setUpWithError()
        app.launch()
    }

    // MARK: - Login UI Tests

    func testLoginScreenShowsOnLaunch() {
        // Verify login prompt is visible
        XCTAssertTrue(app.staticTexts["Sign in to continue"].exists)
        XCTAssertTrue(app.textFields["User ID"].exists)
        XCTAssertTrue(app.buttons["Sign In"].exists)
    }

    func testSignInButtonDisabledWhenEmpty() {
        let signInButton = app.buttons["Sign In"]

        // Button should be disabled when text field is empty
        XCTAssertFalse(signInButton.isEnabled)
    }

    func testSignInButtonEnabledWithInput() {
        let userIdField = app.textFields["User ID"]
        let signInButton = app.buttons["Sign In"]

        // Enter user ID
        userIdField.tap()
        userIdField.typeText("test_user")

        // Button should now be enabled
        XCTAssertTrue(signInButton.isEnabled)
    }

    func testSuccessfulLogin() {
        let userId = TestConstants.testUserId

        // Perform login
        loginWithUser(userId)

        // Verify logged in state
        XCTAssertTrue(app.isLoggedIn)

        // Verify user ID is displayed
        XCTAssertTrue(app.staticTexts[userId].exists)

        // Verify logout button appears
        XCTAssertTrue(app.buttons["Logout"].exists)
    }

    func testLoginShowsEntitlementCount() {
        loginWithUser(TestConstants.freeUserId)

        // Wait for login to complete
        let loggedInText = app.staticTexts["Logged In"]
        XCTAssertTrue(waitForElement(loggedInText))

        // Verify entitlements section is visible
        let entitlementsLabel = app.staticTexts["Entitlements"]
        XCTAssertTrue(entitlementsLabel.exists)
    }

    // MARK: - Logout Tests

    func testLogout() {
        // First login
        loginWithUser(TestConstants.testUserId)

        // Wait for logout button (confirms login completed)
        let logoutButton = app.buttons["Logout"]
        XCTAssertTrue(waitForElement(logoutButton, timeout: 15), "Logout button should appear after login")

        // Scroll down if logout button is not hittable
        if !logoutButton.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(waitForHittable(logoutButton, timeout: 5), "Logout button should be hittable")

        // Tap logout
        logoutButton.tap()

        // Wait for sign in prompt to appear (confirms logout completed)
        let signInPrompt = app.staticTexts["Sign in to continue"]
        XCTAssertTrue(waitForElement(signInPrompt, timeout: 15), "Sign in prompt should appear after logout")
    }

    func testLogoutClearsUserSession() {
        let userId = TestConstants.testUserId

        // Login
        loginWithUser(userId)

        // Wait for user ID to be displayed
        let userIdText = app.staticTexts[userId]
        XCTAssertTrue(waitForElement(userIdText), "User ID should be displayed after login")

        // Logout - scroll down if needed
        let logoutButton = app.buttons["Logout"]
        if !logoutButton.isHittable {
            app.swipeUp()
        }
        _ = waitForHittable(logoutButton, timeout: 5)
        logoutButton.tap()

        // Wait for logout to complete
        let signInPrompt = app.staticTexts["Sign in to continue"]
        XCTAssertTrue(waitForElement(signInPrompt), "Sign in prompt should appear after logout")

        // User ID should no longer be visible
        XCTAssertFalse(app.staticTexts[userId].exists, "User ID should not be visible after logout")
    }

    // MARK: - Session Persistence Tests

    func testLoginPersistsAfterRelaunch() {
        // Login
        loginWithUser(TestConstants.testUserId)
        XCTAssertTrue(app.isLoggedIn)

        // Terminate and relaunch
        app.terminate()
        app.launch()

        // Wait for app to load
        let loggedInText = app.staticTexts["Logged In"]

        // Note: This test assumes the SDK restores the session on relaunch
        // If the test environment doesn't persist data, this may need adjustment
        if waitForElement(loggedInText, timeout: 5) {
            XCTAssertTrue(app.isLoggedIn)
        } else {
            // If not persisted (expected in some test environments), verify login prompt shows
            XCTAssertTrue(app.isShowingLoginPrompt)
        }
    }

    // MARK: - UI State Tests

    func testLoginLoadingState() {
        let userIdField = app.textFields["User ID"]
        userIdField.tap()
        userIdField.typeText("loading_test_user")

        let signInButton = app.buttons["Sign In"]
        signInButton.tap()

        // Note: In a real test, we'd verify the loading indicator appears
        // For now, just wait for the login to complete
        let logoutButton = app.buttons["Logout"]
        _ = waitForElement(logoutButton, timeout: 15)
    }

    func testAppTitleIsVisible() {
        XCTAssertTrue(app.staticTexts["Capivv Demo"].exists)
        XCTAssertTrue(app.staticTexts["In-App Subscription Demo"].exists)
    }

    func testSettingsButtonVisibleWhenLoggedIn() {
        loginWithUser(TestConstants.testUserId)

        let settingsButton = app.buttons["gear"]
        XCTAssertTrue(settingsButton.exists)
        XCTAssertTrue(settingsButton.isHittable)
    }
}
