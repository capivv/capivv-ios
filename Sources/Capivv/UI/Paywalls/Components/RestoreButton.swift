import SwiftUI

/// Restore purchases button
public struct RestoreButton: View {
    let text: String
    let isLoading: Bool
    let theme: ThemeProvider
    let action: () -> Void

    public init(
        text: String? = nil,
        isLoading: Bool = false,
        theme: ThemeProvider,
        action: @escaping () -> Void
    ) {
        self.text = text ?? L10n.paywallRestore
        self.isLoading = isLoading
        self.theme = theme
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                Text(isLoading ? L10n.paywallRestoring : text)
                    .font(.footnote)
            }
            .foregroundColor(theme.textColor.opacity(0.7))
        }
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        RestoreButton(
            theme: ThemeProvider(theme: PaywallTheme()),
            action: {}
        )
        RestoreButton(
            isLoading: true,
            theme: ThemeProvider(theme: PaywallTheme()),
            action: {}
        )
    }
}
