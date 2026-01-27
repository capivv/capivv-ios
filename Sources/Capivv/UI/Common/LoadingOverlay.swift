import SwiftUI

/// A loading overlay with spinner
public struct LoadingOverlay: View {
    let message: String?

    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.platformBackground.opacity(0.9))
    }
}

/// A full-screen loading view
public struct FullScreenLoadingView: View {
    let message: String?

    public init(message: String? = "Loading...") {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            if let message = message {
                Text(message)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.platformBackground)
    }
}

#Preview {
    LoadingOverlay(message: "Loading paywall...")
}
