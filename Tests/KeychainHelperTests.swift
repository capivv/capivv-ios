import XCTest
@testable import Capivv

/// Tests for KeychainHelper
/// Note: These tests require a keychain-capable environment (device or simulator)
final class KeychainHelperTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Clean up before each test
        KeychainHelper.removeUserId()
    }

    override func tearDown() {
        // Clean up after each test
        KeychainHelper.removeUserId()
        super.tearDown()
    }

    // MARK: - Save and Retrieve Tests

    func testSaveAndRetrieveUserId() {
        let testUserId = "test_user_12345"

        KeychainHelper.saveUserId(testUserId)
        let retrieved = KeychainHelper.getUserId()

        XCTAssertEqual(retrieved, testUserId)
    }

    func testSaveEmptyUserId() {
        let emptyUserId = ""

        KeychainHelper.saveUserId(emptyUserId)
        let retrieved = KeychainHelper.getUserId()

        XCTAssertEqual(retrieved, emptyUserId)
    }

    func testSaveLongUserId() {
        let longUserId = String(repeating: "a", count: 1000)

        KeychainHelper.saveUserId(longUserId)
        let retrieved = KeychainHelper.getUserId()

        XCTAssertEqual(retrieved, longUserId)
    }

    func testSaveUserIdWithSpecialCharacters() {
        let specialUserId = "user_with-special.chars@domain.com/path?query=value&other=123"

        KeychainHelper.saveUserId(specialUserId)
        let retrieved = KeychainHelper.getUserId()

        XCTAssertEqual(retrieved, specialUserId)
    }

    func testSaveUserIdWithUnicode() {
        let unicodeUserId = "用户_🎉_émoji_αβγ"

        KeychainHelper.saveUserId(unicodeUserId)
        let retrieved = KeychainHelper.getUserId()

        XCTAssertEqual(retrieved, unicodeUserId)
    }

    // MARK: - Overwrite Tests

    func testOverwriteExistingUserId() {
        let firstUserId = "first_user"
        let secondUserId = "second_user"

        KeychainHelper.saveUserId(firstUserId)
        XCTAssertEqual(KeychainHelper.getUserId(), firstUserId)

        KeychainHelper.saveUserId(secondUserId)
        XCTAssertEqual(KeychainHelper.getUserId(), secondUserId)
    }

    func testMultipleOverwrites() {
        for i in 0..<10 {
            let userId = "user_\(i)"
            KeychainHelper.saveUserId(userId)
            XCTAssertEqual(KeychainHelper.getUserId(), userId)
        }
    }

    // MARK: - Remove Tests

    func testRemoveUserId() {
        let userId = "user_to_remove"

        KeychainHelper.saveUserId(userId)
        XCTAssertNotNil(KeychainHelper.getUserId())

        KeychainHelper.removeUserId()
        XCTAssertNil(KeychainHelper.getUserId())
    }

    func testRemoveNonexistentUserId() {
        // Should not crash when removing non-existent item
        KeychainHelper.removeUserId()
        KeychainHelper.removeUserId()

        XCTAssertNil(KeychainHelper.getUserId())
    }

    func testRemoveAndSaveAgain() {
        let firstUserId = "first"
        let secondUserId = "second"

        KeychainHelper.saveUserId(firstUserId)
        KeychainHelper.removeUserId()
        XCTAssertNil(KeychainHelper.getUserId())

        KeychainHelper.saveUserId(secondUserId)
        XCTAssertEqual(KeychainHelper.getUserId(), secondUserId)
    }

    // MARK: - Retrieve Tests

    func testRetrieveWhenNothingSaved() {
        let retrieved = KeychainHelper.getUserId()
        XCTAssertNil(retrieved)
    }

    func testMultipleRetrievesReturnSameValue() {
        let userId = "consistent_user"

        KeychainHelper.saveUserId(userId)

        for _ in 0..<5 {
            XCTAssertEqual(KeychainHelper.getUserId(), userId)
        }
    }
}
