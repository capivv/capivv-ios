import Foundation
import Security

/// Helper for secure keychain storage
enum KeychainHelper {
    private static let service = "com.capivv.sdk"
    private static let userIdKey = "capivv_user_id"

    /// Save user ID to keychain
    static func saveUserId(_ userId: String) {
        guard let data = userId.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: userIdKey,
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        var newQuery = query
        newQuery[kSecValueData as String] = data
        newQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(newQuery as CFDictionary, nil)
        if status != errSecSuccess {
            Logger.error("Failed to save user ID to keychain: \(status)")
        }
    }

    /// Get user ID from keychain
    static func getUserId() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: userIdKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let userId = String(data: data, encoding: .utf8) else {
            return nil
        }

        return userId
    }

    /// Remove user ID from keychain
    static func removeUserId() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: userIdKey,
        ]

        SecItemDelete(query as CFDictionary)
    }
}
