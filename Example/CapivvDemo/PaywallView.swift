import SwiftUI
import Capivv

struct PaywallView: View {
    @EnvironmentObject var capivv: Capivv
    @Environment(\.dismiss) var dismiss

    @State private var offerings: [Offering] = []
    @State private var selectedPackage: Package?
    @State private var isLoading = true
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)

                        Text("Unlock Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Get access to all features")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)

                    // Features List
                    VStack(alignment: .leading, spacing: 12) {
                        FeatureCheckRow(text: "Unlimited AI generations")
                        FeatureCheckRow(text: "Cloud sync across devices")
                        FeatureCheckRow(text: "Custom themes & colors")
                        FeatureCheckRow(text: "Priority support")
                        FeatureCheckRow(text: "No ads")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Packages
                    if isLoading {
                        ProgressView("Loading packages...")
                            .padding()
                    } else if offerings.isEmpty {
                        Text("No packages available")
                            .foregroundColor(.secondary)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(offerings.first?.packages ?? []) { package in
                                PackageCard(
                                    package: package,
                                    isSelected: selectedPackage?.id == package.id,
                                    onSelect: {
                                        selectedPackage = package
                                    }
                                )
                            }
                        }
                    }

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }

                    // Purchase Button
                    Button {
                        purchase()
                    } label: {
                        if isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Subscribe Now")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(selectedPackage == nil || isPurchasing)

                    // Restore Purchases
                    Button("Restore Purchases") {
                        restorePurchases()
                    }
                    .font(.footnote)

                    // Terms
                    Text("Subscription automatically renews unless canceled at least 24 hours before the end of the current period. You can manage your subscription in Settings.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadOfferings()
            }
        }
    }

    private func loadOfferings() async {
        isLoading = true
        errorMessage = nil

        do {
            offerings = try await capivv.getOfferings()
            // Auto-select the first package
            selectedPackage = offerings.first?.packages.first
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func purchase() {
        guard let package = selectedPackage else { return }

        isPurchasing = true
        errorMessage = nil

        Task {
            do {
                let result = try await capivv.purchase(package: package)

                switch result {
                case .success:
                    dismiss()
                case .userCancelled:
                    break
                case .pending:
                    errorMessage = "Purchase is pending approval"
                case .failed(let error):
                    errorMessage = error.localizedDescription
                }

                isPurchasing = false
            } catch {
                errorMessage = error.localizedDescription
                isPurchasing = false
            }
        }
    }

    private func restorePurchases() {
        isPurchasing = true
        errorMessage = nil

        Task {
            do {
                try await capivv.restorePurchases()
                if capivv.hasEntitlement("premium") {
                    dismiss()
                } else {
                    errorMessage = "No purchases to restore"
                }
                isPurchasing = false
            } catch {
                errorMessage = error.localizedDescription
                isPurchasing = false
            }
        }
    }
}

// MARK: - Supporting Views

struct FeatureCheckRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(text)
            Spacer()
        }
    }
}

struct PackageCard: View {
    let package: Package
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if let description = package.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(package.localizedPriceString ?? "N/A")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(periodString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    var periodString: String {
        switch package.packageType {
        case .weekly: return "per week"
        case .monthly: return "per month"
        case .annual: return "per year"
        case .lifetime: return "one-time"
        default: return ""
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(Capivv.shared)
}
