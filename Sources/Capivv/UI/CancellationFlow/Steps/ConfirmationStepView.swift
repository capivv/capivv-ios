import SwiftUI

/// Final confirmation step before cancellation
struct ConfirmationStepView: View {
    @ObservedObject var viewModel: CancellationFlowViewModel
    let onDismiss: (() -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Warning icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.red)
            }

            // Title
            VStack(spacing: 8) {
                Text("Confirm Cancellation")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Are you sure you want to cancel your subscription?")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            // What you'll lose - dynamic entitlements
            VStack(alignment: .leading, spacing: 12) {
                Text("You will lose access to:")
                    .font(.headline)
                    .foregroundColor(.primary)

                VStack(alignment: .leading, spacing: 8) {
                    if !viewModel.entitlementsAtRisk.isEmpty {
                        // Dynamic entitlements from backend
                        ForEach(viewModel.entitlementsAtRisk) { entitlement in
                            LossItem(
                                text: entitlement.displayName,
                                description: entitlement.description
                            )
                        }
                    } else {
                        // Fallback to generic messaging if no entitlements provided
                        LossItem(text: "Premium features and content", description: nil)
                        LossItem(text: "Offline downloads", description: nil)
                        LossItem(text: "Priority customer support", description: nil)
                        LossItem(text: "Ad-free experience", description: nil)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal)

            // Note about access period
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)

                Text("Your access continues until the end of your current billing period.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                // Keep subscription button
                Button {
                    onDismiss?()
                } label: {
                    Text("Keep My Subscription")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                // Confirm cancel button
                Button {
                    Task {
                        await viewModel.confirmCancellation()
                    }
                } label: {
                    HStack {
                        if viewModel.isProcessing {
                            ProgressView()
                                .tint(.red)
                        } else {
                            Text("Cancel Subscription")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
                .disabled(viewModel.isProcessing)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

/// Item showing what user will lose
private struct LossItem: View {
    let text: String
    let description: String?

    var body: some View {
        HStack(alignment: description != nil ? .top : .center, spacing: 8) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.subheadline)

            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                if let description = description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
