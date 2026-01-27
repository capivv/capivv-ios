import XCTest

/// Base class for UI tests with common setup and helper methods
class CapivvDemoUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()

        // Set launch arguments for testing
        // -UITesting: enables test mode in app
        // -ClearSession: clears any existing user session for test isolation
        app.launchArguments = ["-UITesting", "-ClearSession"]

        // Set launch environment for test backend
        app.launchEnvironment = [
            "API_BASE_URL": "http://localhost:3001/v1",
            "API_KEY": "capivv_pk_test_gtua3fc6yx4vat6mfbasyfez"
        ]
    }

    override func tearDownWithError() throws {
        // Note: We use -ClearSession launch argument instead of teardown logout
        // to ensure test isolation. This avoids race conditions between teardown
        // and the next test's setup.
        app = nil
    }

    // MARK: - Helper Methods

    /// Wait for an element to exist
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 10) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }

    /// Wait for an element to be hittable (visible and enabled)
    func waitForHittable(_ element: XCUIElement, timeout: TimeInterval = 10) -> Bool {
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }

    /// Tap an element after waiting for it to be hittable
    func tapElement(_ element: XCUIElement, timeout: TimeInterval = 10) {
        guard waitForHittable(element, timeout: timeout) else {
            XCTFail("Element not hittable: \(element)")
            return
        }
        element.tap()
    }

    /// Type text into a text field after waiting for it
    func typeInTextField(_ element: XCUIElement, text: String, timeout: TimeInterval = 10) {
        guard waitForHittable(element, timeout: timeout) else {
            XCTFail("Text field not hittable: \(element)")
            return
        }
        element.tap()
        element.typeText(text)
    }

    /// Login with a test user ID
    func loginWithUser(_ userId: String) {
        let userIdTextField = app.textFields["User ID"]
        typeInTextField(userIdTextField, text: userId)

        let signInButton = app.buttons["Sign In"]
        tapElement(signInButton)

        // Wait for login to complete (look for logout button)
        let logoutButton = app.buttons["Logout"]
        _ = waitForElement(logoutButton, timeout: 15)
    }

    /// Logout the current user and wait for logout to complete
    func logout() {
        let logoutButton = app.buttons["Logout"]

        // Scroll down to make logout button visible if needed
        if logoutButton.exists && !logoutButton.isHittable {
            app.swipeUp()
        }

        if logoutButton.exists && waitForHittable(logoutButton, timeout: 5) {
            logoutButton.tap()
            // Wait for logout to complete by checking for login prompt
            let signInPrompt = app.staticTexts["Sign in to continue"]
            _ = waitForElement(signInPrompt, timeout: 10)
        }
    }

    /// Navigate to Settings
    func navigateToSettings() {
        let settingsButton = app.buttons["gear"]
        tapElement(settingsButton)
    }

    /// Open the paywall
    func openPaywall() {
        let unlockButton = app.buttons["Unlock Premium"]
        tapElement(unlockButton)
    }

    /// Close the paywall
    func closePaywall() {
        let closeButton = app.buttons["Close"]
        tapElement(closeButton)
    }
}

// MARK: - Test Constants

enum TestConstants {
    static let testUserId = "ui_test_user_\(UUID().uuidString.prefix(8))"
    static let premiumUserId = "test_premium_user"
    static let freeUserId = "test_free_user"
    static let shortTimeout: TimeInterval = 5
    static let standardTimeout: TimeInterval = 10
    static let longTimeout: TimeInterval = 30
}

// MARK: - XCUIApplication Extensions

extension XCUIApplication {
    /// Check if the login prompt is visible
    var isShowingLoginPrompt: Bool {
        staticTexts["Sign in to continue"].exists
    }

    /// Check if user is logged in
    var isLoggedIn: Bool {
        staticTexts["Logged In"].exists
    }

    /// Check if the paywall is visible
    var isShowingPaywall: Bool {
        staticTexts["Unlock Premium"].exists && navigationBars["Premium"].exists
    }

    /// Check if premium features are unlocked
    var isPremiumUnlocked: Bool {
        staticTexts["Premium Active"].exists
    }
}
