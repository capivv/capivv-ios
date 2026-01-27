import SwiftUI

/// A row displaying a feature in the paywall
public struct FeatureRow: View {
    let feature: PaywallFeature
    let theme: ThemeProvider

    public init(feature: PaywallFeature, theme: ThemeProvider) {
        self.feature = feature
        self.theme = theme
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            if let iconName = feature.icon {
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(feature.isHighlighted ? theme.accentColor : theme.primaryColor)
                    .frame(width: 28, height: 28)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.accentColor)
                    .frame(width: 28, height: 28)
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.subheadline)
                    .fontWeight(feature.isHighlighted ? .semibold : .medium)
                    .foregroundColor(theme.textColor)

                if let description = feature.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack {
        FeatureRow(
            feature: PaywallFeature(
                title: "Unlimited Access",
                description: "Access all premium content",
                icon: "star.fill",
                isHighlighted: true
            ),
            theme: ThemeProvider(theme: PaywallTheme())
        )
        FeatureRow(
            feature: PaywallFeature(
                title: "Ad-Free Experience",
                description: nil,
                icon: nil,
                isHighlighted: false
            ),
            theme: ThemeProvider(theme: PaywallTheme())
        )
    }
    .padding()
}
