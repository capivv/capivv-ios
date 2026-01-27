import SwiftUI
import Capivv

struct ContentView: View {
    @EnvironmentObject var capivv: Capivv
    @State private var showPaywall = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.yellow, .orange)

                        Text("Capivv Demo")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("In-App Subscription Demo")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)

                    // User Status
                    if capivv.isLoggedIn, let userId = capivv.userId {
                        UserStatusCard(userId: userId, entitlements: capivv.entitlements)
                    } else {
                        LoginPrompt(isLoading: $isLoading, errorMessage: $errorMessage)
                    }

                    // Premium Features
                    VStack(spacing: 16) {
                        Text("Premium Features")
                            .font(.headline)

                        if capivv.hasEntitlement("premium") {
                            PremiumUnlockedView()
                        } else {
                            PremiumLockedView(showPaywall: $showPaywall)
                        }
                    }

                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    // Footer
                    if capivv.isLoggedIn {
                        Button("Logout") {
                            Task {
                                await capivv.logout()
                            }
                        }
                        .foregroundColor(.red)
                        .padding(.top, 20)
                    }
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

// MARK: - User Status Card

struct UserStatusCard: View {
    let userId: String
    let entitlements: [Entitlement]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text("Logged In")
                        .font(.headline)
                    Text(userId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }

            Divider()

            HStack {
                Text("Entitlements")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                let activeCount = entitlements.filter { $0.isActive }.count
                if activeCount > 0 {
                    Text("\(activeCount) active")
                        .foregroundColor(.green)
                } else {
                    Text("None")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Login Prompt

struct LoginPrompt: View {
    @EnvironmentObject var capivv: Capivv
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    @State private var userId = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign in to continue")
                .font(.headline)

            TextField("User ID", text: $userId)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disabled(isLoading)

            Button {
                login()
            } label: {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Sign In")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(userId.isEmpty || isLoading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func login() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await capivv.login(userId: userId)
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Premium Views

struct PremiumLockedView: View {
    @Binding var showPaywall: Bool

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                FeatureRow(icon: "wand.and.stars", title: "AI Features", isLocked: true)
                FeatureRow(icon: "cloud.fill", title: "Cloud Sync", isLocked: true)
            }

            HStack(spacing: 16) {
                FeatureRow(icon: "paintbrush.fill", title: "Themes", isLocked: true)
                FeatureRow(icon: "bell.badge.fill", title: "Alerts", isLocked: true)
            }

            Button {
                showPaywall = true
            } label: {
                Label("Unlock Premium", systemImage: "lock.open.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

struct PremiumUnlockedView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                FeatureRow(icon: "wand.and.stars", title: "AI Features", isLocked: false)
                FeatureRow(icon: "cloud.fill", title: "Cloud Sync", isLocked: false)
            }

            HStack(spacing: 16) {
                FeatureRow(icon: "paintbrush.fill", title: "Themes", isLocked: false)
                FeatureRow(icon: "bell.badge.fill", title: "Alerts", isLocked: false)
            }

            Label("Premium Active", systemImage: "checkmark.seal.fill")
                .foregroundColor(.green)
                .font(.headline)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let isLocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isLocked ? Color(.systemGray5) : Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isLocked ? .gray : .blue)
            }

            Text(title)
                .font(.caption)
                .foregroundColor(isLocked ? .secondary : .primary)

            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
        .environmentObject(Capivv.shared)
}
