import SwiftUI

/// Primary purchase button for paywall
public struct PurchaseButton: View {
    let title: String
    let subtitle: String?
    let isLoading: Bool
    let isDisabled: Bool
    let theme: ThemeProvider
    let action: () -> Void

    public init(
        title: String,
        subtitle: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        theme: ThemeProvider,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.theme = theme
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .opacity(0.9)
                    }
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(isDisabled ? theme.primaryColor.opacity(0.5) : theme.primaryColor)
            )
        }
        .disabled(isLoading || isDisabled)
    }
}

/// Secondary button style for restore, etc.
public struct SecondaryButton: View {
    let title: String
    let isLoading: Bool
    let theme: ThemeProvider
    let action: () -> Void

    public init(
        title: String,
        isLoading: Bool = false,
        theme: ThemeProvider,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.theme = theme
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.primaryColor))
            } else {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(theme.primaryColor)
            }
        }
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        PurchaseButton(
            title: "Continue",
            subtitle: "7-day free trial, then $9.99/month",
            theme: ThemeProvider(theme: PaywallTheme()),
            action: {}
        )

        PurchaseButton(
            title: "Continue",
            isLoading: true,
            theme: ThemeProvider(theme: PaywallTheme()),
            action: {}
        )

        SecondaryButton(
            title: "Restore Purchases",
            theme: ThemeProvider(theme: PaywallTheme()),
            action: {}
        )
    }
    .padding()
}
