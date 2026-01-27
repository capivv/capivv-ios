import SwiftUI
import Capivv

struct SettingsView: View {
    @EnvironmentObject var capivv: Capivv
    @State private var isRefreshing = false

    var body: some View {
        List {
            // Account Section
            Section("Account") {
                if capivv.isLoggedIn {
                    HStack {
                        Text("User ID")
                        Spacer()
                        Text(capivv.userId ?? "Unknown")
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Not logged in")
                        .foregroundColor(.secondary)
                }
            }

            // Entitlements Section
            Section("Entitlements") {
                if capivv.entitlements.isEmpty {
                    Text("No entitlements")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(capivv.entitlements) { entitlement in
                        EntitlementRow(entitlement: entitlement)
                    }
                }

                Button {
                    refreshEntitlements()
                } label: {
                    HStack {
                        Text("Refresh Entitlements")
                        Spacer()
                        if isRefreshing {
                            ProgressView()
                        }
                    }
                }
                .disabled(isRefreshing || !capivv.isLoggedIn)
            }

            // Subscription Section
            Section("Subscription") {
                Button("Restore Purchases") {
                    restorePurchases()
                }
                .disabled(!capivv.isLoggedIn)

                Link("Manage Subscription", destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
            }

            // About Section
            Section("About") {
                HStack {
                    Text("SDK Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("App Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                        .foregroundColor(.secondary)
                }

                Link("Privacy Policy", destination: URL(string: "https://capivv.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://capivv.com/terms")!)
            }

            // Debug Section (only in DEBUG builds)
            #if DEBUG
            Section("Debug") {
                Button("Log SDK State") {
                    debugPrintState()
                }

                Button("Clear Stored User", role: .destructive) {
                    capivv.logout()
                }
            }
            #endif
        }
        .navigationTitle("Settings")
    }

    private func refreshEntitlements() {
        isRefreshing = true
        Task {
            try? await capivv.refreshEntitlements()
            isRefreshing = false
        }
    }

    private func restorePurchases() {
        Task {
            try? await capivv.restorePurchases()
        }
    }

    private func debugPrintState() {
        print("=== Capivv SDK State ===")
        print("Configured: \(capivv.isConfigured)")
        print("Logged In: \(capivv.isLoggedIn)")
        print("User ID: \(capivv.userId ?? "nil")")
        print("Entitlements: \(capivv.entitlements.count)")
        for ent in capivv.entitlements {
            print("  - \(ent.identifier): \(ent.isActive ? "active" : "inactive")")
        }
        print("========================")
    }
}

struct EntitlementRow: View {
    let entitlement: Entitlement

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entitlement.displayName)
                    .font(.body)

                Text(entitlement.identifier)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(entitlement.isActive ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(entitlement.isActive ? "Active" : "Inactive")
                        .font(.caption)
                        .foregroundColor(entitlement.isActive ? .green : .red)
                }

                if let expiresAt = entitlement.expiresAt {
                    Text("Expires \(expiresAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(Capivv.shared)
    }
}
