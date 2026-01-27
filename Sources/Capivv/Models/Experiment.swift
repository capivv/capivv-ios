import Foundation

// MARK: - Public Types

/// An A/B test experiment assignment
public struct ExperimentVariant: Codable, Sendable {
    /// Experiment ID
    public let experimentId: String

    /// Experiment name
    public let experimentName: String

    /// Assigned variant ID
    public let variantId: String

    /// Variant name (e.g., "control", "variant_a")
    public let variantName: String

    /// Whether this is the control group
    public let isControl: Bool

    /// Key-value metadata for the variant
    public let metadata: [String: AnyCodable]

    public init(
        experimentId: String,
        experimentName: String,
        variantId: String,
        variantName: String,
        isControl: Bool,
        metadata: [String: AnyCodable] = [:]
    ) {
        self.experimentId = experimentId
        self.experimentName = experimentName
        self.variantId = variantId
        self.variantName = variantName
        self.isControl = isControl
        self.metadata = metadata
    }

    /// Get a string value from metadata
    public func getString(_ key: String, default defaultValue: String = "") -> String {
        metadata[key]?.value as? String ?? defaultValue
    }

    /// Get an integer value from metadata
    public func getInt(_ key: String, default defaultValue: Int = 0) -> Int {
        metadata[key]?.value as? Int ?? defaultValue
    }

    /// Get a boolean value from metadata
    public func getBool(_ key: String, default defaultValue: Bool = false) -> Bool {
        metadata[key]?.value as? Bool ?? defaultValue
    }

    /// Get a double value from metadata
    public func getDouble(_ key: String, default defaultValue: Double = 0.0) -> Double {
        metadata[key]?.value as? Double ?? defaultValue
    }

    enum CodingKeys: String, CodingKey {
        case experimentId = "experiment_id"
        case experimentName = "experiment_name"
        case variantId = "variant_id"
        case variantName = "variant_name"
        case isControl = "is_control"
        case metadata
    }
}

/// An experiment conversion event
public struct ExperimentConversion: Codable, Sendable {
    /// Event name (e.g., "purchase", "signup", "feature_used")
    public let event: String

    /// Optional value associated with the conversion
    public let value: Double?

    /// Additional metadata
    public let metadata: [String: String]?

    public init(
        event: String,
        value: Double? = nil,
        metadata: [String: String]? = nil
    ) {
        self.event = event
        self.value = value
        self.metadata = metadata
    }
}

// MARK: - AnyCodable Helper

/// A type-erased codable value for experiment metadata
public struct AnyCodable: Codable, Sendable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}

// MARK: - API Response Mapping

extension ExperimentVariant {
    init(from response: ExperimentVariantResponse) {
        self.experimentId = response.experimentId
        self.experimentName = response.experimentName
        self.variantId = response.variantId
        self.variantName = response.variantName
        self.isControl = response.isControl
        self.metadata = response.metadata ?? [:]
    }
}

// MARK: - Response Types

struct ExperimentVariantResponse: Codable {
    let experimentId: String
    let experimentName: String
    let variantId: String
    let variantName: String
    let isControl: Bool
    let metadata: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case experimentId = "experiment_id"
        case experimentName = "experiment_name"
        case variantId = "variant_id"
        case variantName = "variant_name"
        case isControl = "is_control"
        case metadata
    }
}

struct ExperimentAssignmentResponse: Codable {
    let variant: ExperimentVariantResponse
}
