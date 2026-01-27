import SwiftUI
import Capivv

@main
struct CapivvDemoApp: App {
    init() {
        // Configure Capivv SDK based on environment
        let apiBaseURL: String
        let apiKey: String

        if ProcessInfo.processInfo.arguments.contains("-UITesting") {
            // UI Testing configuration
            apiBaseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "http://localhost:3001/v1"
            apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? "capivv_pk_test_gtua3fc6yx4vat6mfbasyfez"
        } else {
            // Default development configuration
            apiBaseURL = "http://localhost:3001/v1"
            apiKey = "capivv_pk_test_gtua3fc6yx4vat6mfbasyfez"
        }

        Capivv.shared.configure(
            apiKey: apiKey,
            baseURL: URL(string: apiBaseURL)!
        )

        // Clear session if running UI tests (to ensure test isolation)
        if ProcessInfo.processInfo.arguments.contains("-ClearSession") {
            Task {
                await Capivv.shared.logout()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Capivv.shared)
                .task {
                    await Capivv.shared.start()
                }
        }
    }
}
