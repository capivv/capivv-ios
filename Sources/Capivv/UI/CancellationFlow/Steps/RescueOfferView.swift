import SwiftUI

/// View for displaying a rescue offer
struct RescueOfferView: View {
    let offer: RescueOffer
    @ObservedObject var viewModel: CancellationFlowViewModel

    var body: some View {
        VStack(spacing: 24) {
            // Badge
            Text("SPECIAL OFFER")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange)
                .cornerRadius(4)

            // Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: iconForOfferType(offer.offerType))
                    .font(.system(size: 36))
                    .foregroundColor(iconBackgroundColor)
            }

            // Title and description
            VStack(spacing: 8) {
                Text(offer.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(offer.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            // Value highlight
            if let valueText = valueText {
                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.green)

                    Text(valueText)
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }

            // Offer details
            offerDetails

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                // Accept button
                Button {
                    Task {
                        await viewModel.acceptOffer(offer)
                    }
                } label: {
                    HStack {
                        if viewModel.isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(acceptButtonText)
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(iconBackgroundColor)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isProcessing)

                // Decline button
                Button {
                    viewModel.declineOffer()
                } label: {
                    Text("No thanks, continue cancelling")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .disabled(viewModel.isProcessing)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }

    // MARK: - Offer Type Specific

    private var iconBackgroundColor: Color {
        switch offer.offerType {
        case .discount:
            return .green
        case .pause:
            return .blue
        case .downgrade:
            return .purple
        case .freeExtension:
            return .orange
        }
    }

    private func iconForOfferType(_ type: RescueOfferType) -> String {
        switch type {
        case .discount:
            return "percent"
        case .pause:
            return "pause.circle.fill"
        case .downgrade:
            return "arrow.down.circle.fill"
        case .freeExtension:
            return "calendar.badge.plus"
        }
    }

    private var valueText: String? {
        switch offer.offerType {
        case .discount:
            if let percent = offer.discountPercent {
                return "Save \(percent)% off"
            }
            return nil
        case .pause:
            if let days = offer.pauseDays {
                return "Pause for \(days) days"
            }
            return nil
        case .downgrade:
            return "Lower monthly cost"
        case .freeExtension:
            return "Extended free access"
        }
    }

    private var acceptButtonText: String {
        switch offer.offerType {
        case .discount:
            return "Apply Discount"
        case .pause:
            return "Pause Subscription"
        case .downgrade:
            return "Switch Plan"
        case .freeExtension:
            return "Extend Free"
        }
    }

    @ViewBuilder
    private var offerDetails: some View {
        switch offer.offerType {
        case .discount:
            if let percent = offer.discountPercent {
                VStack(spacing: 4) {
                    Text("\(percent)% OFF")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.green)

                    Text("on your subscription")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

        case .pause:
            if let days = offer.pauseDays {
                VStack(spacing: 4) {
                    Text("\(days)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)

                    Text("days pause")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

        case .downgrade:
            VStack(spacing: 8) {
                HStack {
                    Text("Current:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Premium")
                        .strikethrough()
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("New:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Basic")
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
            }
            .font(.subheadline)
            .padding()
            .background(Color.platformSecondaryBackground)
            .cornerRadius(12)
            .padding(.horizontal)

        case .freeExtension:
            VStack(spacing: 4) {
                if let days = offer.freeExtensionDays {
                    Text("+\(days)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.orange)

                    Text("free days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
