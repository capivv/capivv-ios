import Foundation
@testable import Capivv

/// Mock URLProtocol for intercepting network requests in tests
final class MockURLProtocol: URLProtocol {
    /// Handler for mock responses
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    /// Captured requests for verification
    static var capturedRequests: [URLRequest] = []

    /// Reset all mocks
    static func reset() {
        requestHandler = nil
        capturedRequests = []
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        MockURLProtocol.capturedRequests.append(request)

        guard let handler = MockURLProtocol.requestHandler else {
            let error = NSError(domain: "MockURLProtocol", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "No request handler set"
            ])
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // Nothing to do
    }
}

// MARK: - Test Helpers

extension MockURLProtocol {
    /// Set up a successful JSON response
    static func setSuccessResponse<T: Encodable>(for path: String, response: T, statusCode: Int = 200) {
        requestHandler = { request in
            guard let url = request.url, url.path.hasSuffix(path) else {
                throw URLError(.badURL)
            }

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(response)

            let httpResponse = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!

            return (httpResponse, data)
        }
    }

    /// Set up an error response
    static func setErrorResponse(statusCode: Int, code: String, message: String) {
        requestHandler = { request in
            let errorResponse = MockAPIErrorResponse(
                error: MockAPIError(code: code, message: message)
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(errorResponse)

            let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!

            return (httpResponse, data)
        }
    }

    /// Set up a network error
    static func setNetworkError(_ error: URLError) {
        requestHandler = { _ in
            throw error
        }
    }
}

// MARK: - Mock Response Types

struct MockAPIErrorResponse: Encodable {
    let error: MockAPIError
}

struct MockAPIError: Encodable {
    let code: String
    let message: String
}

// MARK: - Mock Data Factories

enum MockDataFactory {
    static func userInfoResponse(
        userId: String = "test_user_123",
        capivvId: String = "capivv_user_abc",
        entitlements: [MockEntitlementResponse] = []
    ) -> MockUserInfoResponse {
        MockUserInfoResponse(
            user: MockUserResponse(
                id: capivvId,
                externalId: userId,
                firstSeenAt: Date(),
                lastSeenAt: Date()
            ),
            entitlements: entitlements
        )
    }

    static func entitlementResponse(
        identifier: String = "premium",
        isActive: Bool = true,
        expiresAt: Date? = nil,
        source: String = "purchase"
    ) -> MockEntitlementResponse {
        MockEntitlementResponse(
            identifier: identifier,
            isActive: isActive,
            expiresAt: expiresAt,
            source: source
        )
    }

    static func offeringsResponse(offerings: [MockOfferingResponse] = []) -> MockOfferingsResponse {
        MockOfferingsResponse(offerings: offerings)
    }

    static func offeringResponse(
        identifier: String = "default",
        displayName: String = "Default Offering",
        packages: [MockPackageResponse] = []
    ) -> MockOfferingResponse {
        MockOfferingResponse(
            identifier: identifier,
            displayName: displayName,
            description: "Test offering",
            packages: packages,
            metadata: [:]
        )
    }

    static func packageResponse(
        identifier: String = "monthly",
        packageType: String = "monthly",
        storeProductId: String = "com.test.monthly",
        displayName: String = "Monthly"
    ) -> MockPackageResponse {
        MockPackageResponse(
            identifier: identifier,
            packageType: packageType,
            storeProductId: storeProductId,
            displayName: displayName,
            description: nil
        )
    }
}

// MARK: - Encodable Mock Types (for test responses)

struct MockUserInfoResponse: Encodable {
    let user: MockUserResponse
    let entitlements: [MockEntitlementResponse]
}

struct MockUserResponse: Encodable {
    let id: String
    let externalId: String
    let firstSeenAt: Date
    let lastSeenAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case externalId = "external_id"
        case firstSeenAt = "first_seen_at"
        case lastSeenAt = "last_seen_at"
    }
}

struct MockEntitlementResponse: Encodable {
    let identifier: String
    let isActive: Bool
    let expiresAt: Date?
    let source: String

    enum CodingKeys: String, CodingKey {
        case identifier
        case isActive = "is_active"
        case expiresAt = "expires_at"
        case source
    }
}

struct MockOfferingsResponse: Encodable {
    let offerings: [MockOfferingResponse]
}

struct MockOfferingResponse: Encodable {
    let identifier: String
    let displayName: String
    let description: String?
    let packages: [MockPackageResponse]
    let metadata: [String: String]?

    enum CodingKeys: String, CodingKey {
        case identifier
        case displayName = "display_name"
        case description
        case packages
        case metadata
    }
}

struct MockPackageResponse: Encodable {
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
