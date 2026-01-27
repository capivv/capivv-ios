import SwiftUI

/// A view that displays an error with retry option
public struct ErrorView: View {
    let error: Error
    let onRetry: (() async -> Void)?
    let onDismiss: (() -> Void)?

    @State private var isRetrying = false

    public init(
        error: Error,
        onRetry: (() async -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.error = error
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.headline)

                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            HStack(spacing: 16) {
                if let onDismiss = onDismiss {
                    Button("Close") {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)
                }

                if let onRetry = onRetry {
                    Button {
                        Task {
                            isRetrying = true
                            await onRetry()
                            isRetrying = false
                        }
                    } label: {
                        HStack {
                            if isRetrying {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text("Try Again")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isRetrying)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorView(
        error: CapivvError.networkError(underlying: URLError(.notConnectedToInternet)),
        onRetry: {},
        onDismiss: {}
    )
}
