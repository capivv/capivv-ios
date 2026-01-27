import SwiftUI

/// Step view for selecting cancellation reason
struct ReasonStepView: View {
    @ObservedObject var viewModel: CancellationFlowViewModel
    let flow: CancellationFlow

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("We're sorry to see you go")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Please let us know why you're cancelling so we can improve.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            // Reason options
            VStack(spacing: 12) {
                ForEach(CancellationReason.allCases, id: \.self) { reason in
                    ReasonOptionButton(
                        reason: reason,
                        isSelected: viewModel.selectedReason == reason
                    ) {
                        viewModel.selectedReason = reason
                    }
                }
            }
            .padding(.horizontal)

            // Feedback text area
            if viewModel.selectedReason != nil {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional feedback (optional)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    TextEditor(text: $viewModel.feedbackText)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.platformSecondaryBackground)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
            }

            Spacer()

            // Continue button
            Button {
                Task {
                    await viewModel.submitReason()
                }
            } label: {
                HStack {
                    if viewModel.isProcessing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Continue")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.selectedReason != nil ? Color.blue : Color.gray)
                .cornerRadius(12)
            }
            .disabled(viewModel.selectedReason == nil || viewModel.isProcessing)
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

/// Individual reason option button
private struct ReasonOptionButton: View {
    let reason: CancellationReason
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: iconForReason(reason))
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(titleForReason(reason))
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(descriptionForReason(reason))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.platformSecondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func iconForReason(_ reason: CancellationReason) -> String {
        switch reason {
        case .tooExpensive: return "dollarsign.circle"
        case .notUsing: return "xmark.circle"
        case .missingFeatures: return "questionmark.circle"
        case .technicalIssues: return "exclamationmark.triangle"
        case .foundAlternative: return "arrow.left.arrow.right"
        case .other: return "ellipsis.circle"
        }
    }

    private func titleForReason(_ reason: CancellationReason) -> String {
        switch reason {
        case .tooExpensive: return "Too expensive"
        case .notUsing: return "Not using enough"
        case .missingFeatures: return "Missing features"
        case .technicalIssues: return "Technical issues"
        case .foundAlternative: return "Found an alternative"
        case .other: return "Other reason"
        }
    }

    private func descriptionForReason(_ reason: CancellationReason) -> String {
        switch reason {
        case .tooExpensive: return "The price doesn't fit my budget"
        case .notUsing: return "I don't use the app often enough"
        case .missingFeatures: return "It's missing something I need"
        case .technicalIssues: return "I'm experiencing bugs or problems"
        case .foundAlternative: return "I'm switching to another service"
        case .other: return "Something else not listed"
        }
    }
}

// MARK: - CancellationReason Conformance

extension CancellationReason: CaseIterable {
    public static var allCases: [CancellationReason] {
        [.tooExpensive, .notUsing, .missingFeatures, .technicalIssues, .foundAlternative, .other]
    }
}
