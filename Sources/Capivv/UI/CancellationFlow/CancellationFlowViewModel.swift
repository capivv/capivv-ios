import SwiftUI

/// State for cancellation flow
public enum CancellationFlowState: Sendable {
    case loading
    case loaded(CancellationFlow)
    case error(Error)
}

/// Current step in the cancellation flow
public enum CancellationFlowStep: Sendable, Equatable {
    case reason
    case rescueOffer(RescueOffer)
    case confirmation
    case completed(rescued: Bool)
}

/// ViewModel for cancellation flow
@MainActor
public final class CancellationFlowViewModel: ObservableObject {
    /// Current state
    @Published public private(set) var state: CancellationFlowState = .loading

    /// Current step
    @Published public private(set) var currentStep: CancellationFlowStep = .reason

    /// Selected reason
    @Published public var selectedReason: CancellationReason?

    /// Feedback text
    @Published public var feedbackText: String = ""

    /// Is processing
    @Published public private(set) var isProcessing: Bool = false

    /// Subscription ID being cancelled
    public let subscriptionId: String

    /// Flow configuration
    private var flow: CancellationFlow?

    /// Current rescue offer index
    private var currentOfferIndex: Int = 0

    public init(subscriptionId: String) {
        self.subscriptionId = subscriptionId
    }

    // MARK: - Loading

    /// Load the cancellation flow
    public func load() async {
        state = .loading

        do {
            let flow = try await Capivv.shared.getCancellationFlow(subscriptionId: subscriptionId)
            self.flow = flow
            state = .loaded(flow)
            Logger.info("Cancellation flow loaded: \(flow.id)")
        } catch {
            state = .error(error)
            Logger.error("Failed to load cancellation flow: \(error)")
        }
    }

    // MARK: - Navigation

    /// Submit the selected reason and move to next step
    public func submitReason() async {
        guard let reason = selectedReason else { return }
        guard let flow = flow else { return }

        isProcessing = true

        do {
            try await Capivv.shared.submitCancellationReason(
                subscriptionId: subscriptionId,
                reason: reason,
                feedback: feedbackText.isEmpty ? nil : feedbackText
            )

            // Check if we have rescue offers
            if !flow.offers.isEmpty {
                currentOfferIndex = 0
                currentStep = .rescueOffer(flow.offers[0])
            } else {
                currentStep = .confirmation
            }

            Logger.info("Reason submitted: \(reason.rawValue)")
        } catch {
            Logger.error("Failed to submit reason: \(error)")
        }

        isProcessing = false
    }

    /// Decline current offer and show next or go to confirmation
    public func declineOffer() {
        guard let flow = flow else {
            currentStep = .confirmation
            return
        }

        currentOfferIndex += 1

        if currentOfferIndex < flow.offers.count {
            currentStep = .rescueOffer(flow.offers[currentOfferIndex])
        } else {
            currentStep = .confirmation
        }
    }

    /// Accept a rescue offer
    public func acceptOffer(_ offer: RescueOffer) async {
        isProcessing = true

        do {
            let result = try await Capivv.shared.acceptRescueOffer(
                offerId: offer.id,
                subscriptionId: subscriptionId
            )

            if result.success {
                currentStep = .completed(rescued: true)
                Logger.info("Rescue offer accepted: \(offer.id)")
            } else {
                // Offer application failed, proceed to next step
                declineOffer()
            }
        } catch {
            Logger.error("Failed to accept rescue offer: \(error)")
            declineOffer()
        }

        isProcessing = false
    }

    /// Confirm cancellation
    public func confirmCancellation() async {
        isProcessing = true

        do {
            try await Capivv.shared.confirmCancellation(subscriptionId: subscriptionId)
            currentStep = .completed(rescued: false)
            Logger.info("Cancellation confirmed for: \(subscriptionId)")
        } catch {
            Logger.error("Failed to confirm cancellation: \(error)")
        }

        isProcessing = false
    }

    /// Go back to previous step
    public func goBack() {
        switch currentStep {
        case .reason:
            break // Can't go back from first step
        case .rescueOffer:
            if currentOfferIndex > 0 {
                currentOfferIndex -= 1
                if let flow = flow {
                    currentStep = .rescueOffer(flow.offers[currentOfferIndex])
                }
            } else {
                currentStep = .reason
            }
        case .confirmation:
            if let flow = flow, !flow.offers.isEmpty {
                currentOfferIndex = flow.offers.count - 1
                currentStep = .rescueOffer(flow.offers[currentOfferIndex])
            } else {
                currentStep = .reason
            }
        case .completed:
            break // Can't go back from completed
        }
    }

    // MARK: - Helpers

    /// Entitlements at risk if user cancels
    public var entitlementsAtRisk: [EntitlementAtRisk] {
        flow?.entitlementsAtRisk ?? []
    }

    /// Get progress (0-1) through the flow
    public var progress: Double {
        guard let flow = flow else { return 0 }
        let totalSteps = 2 + flow.offers.count // reason + offers + confirmation

        switch currentStep {
        case .reason:
            return 1.0 / Double(totalSteps)
        case .rescueOffer:
            return Double(2 + currentOfferIndex) / Double(totalSteps)
        case .confirmation:
            return Double(totalSteps - 1) / Double(totalSteps)
        case .completed:
            return 1.0
        }
    }
}
