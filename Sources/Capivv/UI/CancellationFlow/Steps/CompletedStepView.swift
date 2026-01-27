import SwiftUI

/// Completed step showing success state
struct CompletedStepView: View {
    let rescued: Bool
    let onDismiss: (() -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(rescued ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: rescued ? "checkmark.circle.fill" : "hand.wave.fill")
                    .font(.system(size: 44))
                    .foregroundColor(rescued ? .green : .gray)
            }

            // Title and message
            VStack(spacing: 8) {
                Text(rescued ? "Welcome Back!" : "We'll Miss You")
                    .font(.title)
                    .fontWeight(.bold)

                Text(rescued ? rescuedMessage : cancelledMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            // Additional info
            if rescued {
                rescuedInfoCard
            } else {
                cancelledInfoCard
            }

            Spacer()

            // Done button
            Button {
                onDismiss?()
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(rescued ? Color.green : Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }

    private var rescuedMessage: String {
        "Your subscription has been updated. Thank you for staying with us!"
    }

    private var cancelledMessage: String {
        "Your subscription has been cancelled. You'll retain access until the end of your billing period."
    }

    private var rescuedInfoCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(.green)
                Text("Your special offer has been applied")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Text("Check your email for confirmation details.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var cancelledInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What happens next:")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                InfoRow(
                    icon: "calendar",
                    text: "Access continues until billing period ends"
                )
                InfoRow(
                    icon: "arrow.counterclockwise",
                    text: "You can resubscribe anytime"
                )
                InfoRow(
                    icon: "envelope",
                    text: "Check email for confirmation"
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.platformSecondaryBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

private struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
