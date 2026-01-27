import SwiftUI

/// A selector for choosing between subscription packages
public struct PackageSelector: View {
    let packages: [Package]
    @Binding var selectedPackage: Package?
    let theme: ThemeProvider

    public init(
        packages: [Package],
        selectedPackage: Binding<Package?>,
        theme: ThemeProvider
    ) {
        self.packages = packages
        self._selectedPackage = selectedPackage
        self.theme = theme
    }

    public var body: some View {
        VStack(spacing: 12) {
            ForEach(packages) { package in
                PackageCard(
                    package: package,
                    isSelected: selectedPackage?.id == package.id,
                    theme: theme
                ) {
                    selectedPackage = package
                }
            }
        }
    }
}

/// Individual package card
struct PackageCard: View {
    let package: Package
    let isSelected: Bool
    let theme: ThemeProvider
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.displayName)
                        .font(.headline)
                        .foregroundColor(theme.textColor)

                    if let description = package.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(theme.textColor.opacity(0.7))
                    }

                    // Show subscription period info
                    if let period = package.subscriptionPeriod {
                        Text(periodDescription(period))
                            .font(.caption2)
                            .foregroundColor(theme.textColor.opacity(0.6))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(package.localizedPriceString ?? "")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(theme.primaryColor)

                    // Show per-month price for annual
                    if package.packageType == .annual,
                       let price = package.price {
                        let monthlyPrice = price / 12
                        Text("\(formatPrice(monthlyPrice))/mo")
                            .font(.caption)
                            .foregroundColor(theme.textColor.opacity(0.7))
                    }
                }

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? theme.primaryColor : theme.textColor.opacity(0.3))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(isSelected ? theme.primaryColor.opacity(0.1) : Color.platformSecondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(isSelected ? theme.primaryColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func periodDescription(_ period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .day:
            return period.value == 1 ? "Daily" : "Every \(period.value) days"
        case .week:
            return period.value == 1 ? "Weekly" : "Every \(period.value) weeks"
        case .month:
            return period.value == 1 ? "Monthly" : "Every \(period.value) months"
        case .year:
            return period.value == 1 ? "Yearly" : "Every \(period.value) years"
        @unknown default:
            return ""
        }
    }

    private func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: price as NSNumber) ?? ""
    }
}

import StoreKit

#Preview {
    PackageSelector(
        packages: [],
        selectedPackage: .constant(nil),
        theme: ThemeProvider(theme: PaywallTheme())
    )
    .padding()
}
