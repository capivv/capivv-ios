import Foundation

/// API client for communicating with the Capivv backend
actor CapivvAPI {
    private let configuration: CapivvConfiguration
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(configuration: CapivvConfiguration) {
        self.configuration = configuration

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeoutInterval
        self.session = URLSession(configuration: sessionConfig)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - User Endpoints

    /// Log in or create a user
    func login(userId: String) async throws -> UserInfo {
        let body = ["external_id": userId]
        let response: UserInfoResponse = try await post(path: "/sdk/users", body: body)
        return UserInfo(from: response)
    }

    /// Get user entitlements
    func getUserEntitlements(userId: String) async throws -> UserInfo {
        let response: UserInfoResponse = try await get(path: "/sdk/users/\(userId)/entitlements")
        return UserInfo(from: response)
    }

    // MARK: - Offerings Endpoints

    /// Get offerings for a user
    func getOfferings(userId: String, bundleId: String? = nil) async throws -> [Offering] {
        var queryItems = [URLQueryItem(name: "user_id", value: userId)]
        queryItems.append(URLQueryItem(name: "platform", value: "ios"))
        if let bundleId = bundleId {
            queryItems.append(URLQueryItem(name: "bundle_id", value: bundleId))
        }
        let response: OfferingsResponse = try await get(path: "/sdk/offerings", queryItems: queryItems)
        return response.offerings.map { Offering(from: $0) }
    }

    // MARK: - Receipt Validation

    /// Validate a receipt with the backend
    func validateReceipt(
        userId: String,
        receiptData: String,
        productId: String,
        transactionId: String,
        originalTransactionId: String
    ) async throws -> ReceiptValidationResult {
        let body: [String: Any] = [
            "user_id": userId,
            "platform": "ios",
            "receipt_data": receiptData,
            "product_id": productId,
            "transaction_id": transactionId,
            "original_transaction_id": originalTransactionId
        ]

        let response: ReceiptValidationResponse = try await post(path: "/sdk/receipts", body: body)
        return ReceiptValidationResult(from: response)
    }

    // MARK: - Paywalls

    /// Get paywall configuration by identifier
    func getPaywall(identifier: String, userId: String) async throws -> PaywallConfig {
        let queryItems = [
            URLQueryItem(name: "user_id", value: userId),
            URLQueryItem(name: "platform", value: "ios")
        ]
        let response: PaywallConfigResponse = try await get(
            path: "/sdk/paywalls/\(identifier)",
            queryItems: queryItems
        )
        return PaywallConfig(from: response)
    }

    /// Get dynamic template definition for a paywall.
    /// This enables OTA template updates without requiring app store releases.
    func getPaywallTemplate(identifier: String) async throws -> TemplateLoadResult {
        let response: TemplateDefinitionResponse = try await get(
            path: "/sdk/paywalls/by-identifier/\(identifier)/template"
        )
        return TemplateLoadResult(from: response)
    }

    /// Track a paywall event
    func trackPaywallEvent(paywallId: String, event: PaywallEvent, userId: String) async throws {
        var body: [String: Any] = [
            "paywall_id": paywallId,
            "user_id": userId,
            "event_type": event.type.rawValue,
            "platform": "ios"
        ]
        if let variant = event.variant {
            body["variant"] = variant
        }
        if let packageId = event.packageId {
            body["package_id"] = packageId
        }
        if let sessionId = event.sessionId {
            body["session_id"] = sessionId
        }

        let _: EmptyResponse = try await post(path: "/sdk/paywalls/events", body: body)
    }

    // MARK: - Cancellation/Rescue Flows

    /// Get cancellation flow for a subscription
    func getCancellationFlow(subscriptionId: String, userId: String) async throws -> CancellationFlow {
        let queryItems = [
            URLQueryItem(name: "user_id", value: userId),
            URLQueryItem(name: "subscription_id", value: subscriptionId)
        ]
        let response: CancellationFlowResponse = try await get(
            path: "/sdk/rescue/flow",
            queryItems: queryItems
        )
        return CancellationFlow(from: response)
    }

    /// Accept a rescue offer
    func acceptRescueOffer(offerId: String, subscriptionId: String, userId: String) async throws -> RescueResult {
        let body: [String: Any] = [
            "offer_id": offerId,
            "subscription_id": subscriptionId,
            "user_id": userId
        ]
        let response: RescueResultResponse = try await post(path: "/sdk/rescue/accept", body: body)
        return RescueResult(from: response)
    }

    /// Submit cancellation reason
    func submitCancellationReason(
        subscriptionId: String,
        userId: String,
        reason: CancellationReason,
        feedback: String?
    ) async throws {
        var body: [String: Any] = [
            "subscription_id": subscriptionId,
            "user_id": userId,
            "reason": reason.rawValue
        ]
        if let feedback = feedback {
            body["feedback"] = feedback
        }
        let _: EmptyResponse = try await post(path: "/sdk/rescue/reason", body: body)
    }

    /// Confirm subscription cancellation
    func confirmCancellation(subscriptionId: String, userId: String) async throws {
        let body: [String: Any] = [
            "subscription_id": subscriptionId,
            "user_id": userId
        ]
        let _: EmptyResponse = try await post(path: "/sdk/rescue/cancel", body: body)
    }

    // MARK: - Promotions

    /// Get active promotions for the user
    func getActivePromotions(userId: String) async throws -> [Promotion] {
        let queryItems = [
            URLQueryItem(name: "user_id", value: userId),
            URLQueryItem(name: "platform", value: "ios")
        ]
        let response: PromotionsResponse = try await get(
            path: "/sdk/promotions/active",
            queryItems: queryItems
        )
        return response.promotions.map { Promotion(from: $0) }
    }

    /// Redeem a promotion code
    func redeemPromotion(code: String, userId: String) async throws -> RedemptionResult {
        let body: [String: Any] = [
            "code": code,
            "user_id": userId
        ]
        let response: RedemptionResultResponse = try await post(path: "/sdk/promotions/redeem", body: body)
        return RedemptionResult(from: response)
    }

    // MARK: - Experiments

    /// Get experiment assignment for a user
    func getExperimentAssignment(experimentId: String, userId: String) async throws -> ExperimentVariant {
        let queryItems = [
            URLQueryItem(name: "user_id", value: userId)
        ]
        let response: ExperimentAssignmentResponse = try await get(
            path: "/sdk/experiments/\(experimentId)/assignment",
            queryItems: queryItems
        )
        return ExperimentVariant(from: response.variant)
    }

    /// Track an experiment conversion
    func trackExperimentConversion(
        variantId: String,
        userId: String,
        event: String,
        value: Double? = nil
    ) async throws {
        var body: [String: Any] = [
            "variant_id": variantId,
            "user_id": userId,
            "event": event
        ]
        if let value = value {
            body["value"] = value
        }
        let _: EmptyResponse = try await post(path: "/sdk/experiments/conversion", body: body)
    }

    // MARK: - HTTP Methods

    private func get<T: Decodable>(path: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        guard var urlComponents = URLComponents(url: configuration.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true) else {
            throw CapivvError.networkError(underlying: URLError(.badURL))
        }
        if let queryItems = queryItems, !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }
        guard let url = urlComponents.url else {
            throw CapivvError.networkError(underlying: URLError(.badURL))
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addHeaders(to: &request)

        return try await perform(request)
    }

    private func post<T: Decodable>(path: String, body: [String: Any]) async throws -> T {
        let url = configuration.baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        addHeaders(to: &request)

        return try await perform(request)
    }

    private func addHeaders(to request: inout URLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(configuration.apiKey, forHTTPHeaderField: "X-Capivv-Key")
        request.setValue("ios", forHTTPHeaderField: "X-Platform")
        request.setValue(sdkVersion, forHTTPHeaderField: "X-SDK-Version")
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        Logger.debug("API Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CapivvError.networkError(underlying: URLError(.badServerResponse))
        }

        Logger.debug("API Response: \(httpResponse.statusCode)")

        // Handle error responses
        if httpResponse.statusCode >= 400 {
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw CapivvError.apiError(
                    code: errorResponse.error.code,
                    message: errorResponse.error.message
                )
            }
            throw CapivvError.apiError(
                code: "HTTP_\(httpResponse.statusCode)",
                message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            )
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            Logger.error("Decoding error: \(error)")
            throw CapivvError.networkError(underlying: error)
        }
    }

    private var sdkVersion: String {
        "1.0.0"
    }
}

// MARK: - Response Types

struct OfferingsResponse: Codable {
    let offerings: [OfferingResponse]
}

struct ReceiptValidationResponse: Codable {
    let success: Bool
    let purchaseId: String?
    let entitlements: [EntitlementResponse]?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case success
        case purchaseId = "purchase_id"
        case entitlements
        case message
    }
}

struct ReceiptValidationResult {
    let success: Bool
    let purchaseId: String?
    let entitlements: [Entitlement]

    init(from response: ReceiptValidationResponse) {
        self.success = response.success
        self.purchaseId = response.purchaseId
        self.entitlements = response.entitlements?.map { Entitlement(from: $0) } ?? []
    }
}

struct APIErrorResponse: Codable {
    let error: APIError

    struct APIError: Codable {
        let code: String
        let message: String
    }
}

struct EmptyResponse: Codable {}
