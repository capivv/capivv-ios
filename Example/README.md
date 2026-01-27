# Capivv iOS Demo App

A complete example iOS application demonstrating how to integrate the Capivv SDK for in-app subscriptions, entitlements, and paywall management.

## Features Demonstrated

- **SDK Configuration** - Proper initialization in SwiftUI App lifecycle
- **User Authentication** - Login/logout flow with session persistence
- **Entitlements** - Checking and displaying user entitlements
- **Paywall** - Custom paywall with offerings and package selection
- **Purchases** - StoreKit 2 integration for subscription purchases
- **Restore Purchases** - Restoring previous purchases
- **Settings** - Displaying subscription status and debug tools

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+
- Active Capivv account with API key

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/capivv/capivv.git
cd capivv/examples/ios/CapivvDemo
```

### 2. Open in Xcode

```bash
open CapivvDemo.xcodeproj
```

### 3. Configure Your API Key

In `CapivvDemoApp.swift`, replace the API key with your own:

```swift
Capivv.shared.configure(
    apiKey: "YOUR_API_KEY",
    baseURL: URL(string: "https://api.capivv.com/v1")!
)
```

For local development, use your test API key:

```swift
Capivv.shared.configure(
    apiKey: "capivv_pk_test_YOUR_KEY",
    baseURL: URL(string: "http://localhost:3001/v1")!
)
```

### 4. Run the App

Select a simulator or device and press `Cmd + R` to build and run.

## Project Structure

```
CapivvDemo/
├── CapivvDemoApp.swift     # App entry point with SDK configuration
├── ContentView.swift        # Main view with login and feature showcase
├── PaywallView.swift        # Custom paywall implementation
├── SettingsView.swift       # Settings and subscription management
└── Assets.xcassets/         # App icons and colors
```

## Code Examples

### SDK Initialization

```swift
@main
struct CapivvDemoApp: App {
    init() {
        Capivv.shared.configure(apiKey: "YOUR_API_KEY")
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
```

### User Login

```swift
@EnvironmentObject var capivv: Capivv

func login() {
    Task {
        do {
            try await capivv.login(userId: userId)
            // User is now logged in, entitlements are loaded
        } catch {
            print("Login failed: \(error)")
        }
    }
}
```

### Checking Entitlements

```swift
if capivv.hasEntitlement("premium") {
    // Show premium features
} else {
    // Show upgrade prompt
}
```

### Loading Offerings

```swift
func loadOfferings() async {
    do {
        let offerings = try await capivv.getOfferings()
        // offerings contain packages with StoreKit product info
    } catch {
        print("Failed to load offerings: \(error)")
    }
}
```

### Making a Purchase

```swift
func purchase(package: Package) {
    Task {
        do {
            let result = try await capivv.purchase(package: package)
            switch result {
            case .success:
                // Purchase successful, entitlements updated
            case .userCancelled:
                // User cancelled the purchase
            case .pending:
                // Purchase requires approval (e.g., parental controls)
            case .failed(let error):
                print("Purchase failed: \(error)")
            }
        } catch {
            print("Purchase error: \(error)")
        }
    }
}
```

### Using Remote Paywalls

For even simpler integration, use the SDK's built-in PaywallView:

```swift
import Capivv

struct ContentView: View {
    @State private var showPaywall = false

    var body: some View {
        Button("Upgrade") {
            showPaywall = true
        }
        .sheet(isPresented: $showPaywall) {
            // Uses remote configuration from dashboard
            Capivv.PaywallView(
                identifier: "premium",
                onDismiss: { showPaywall = false },
                onPurchaseSuccess: { package in
                    print("Purchased: \(package.displayName)")
                }
            )
        }
    }
}
```

## Testing

### Running Unit Tests

```bash
xcodebuild test -scheme CapivvDemo -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Running UI Tests

```bash
xcodebuild test -scheme CapivvDemoUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### StoreKit Testing

1. Open the StoreKit Configuration file in Xcode
2. Enable `StoreKit Testing in Xcode` scheme option
3. Use the sandbox testing environment

## Configuration

### Environment Variables (for UI Tests)

- `API_BASE_URL` - Backend API URL
- `API_KEY` - Capivv API key

### Launch Arguments

- `-UITesting` - Enable UI testing mode
- `-ClearSession` - Clear stored user session

## Customization

### Paywall Theming

Customize the paywall appearance in `PaywallView.swift`:

```swift
.background(
    LinearGradient(
        colors: [.purple, .blue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
)
```

### Feature Rows

Add or modify features displayed in the paywall:

```swift
FeatureCheckRow(text: "Your Feature")
```

## Troubleshooting

### Common Issues

**SDK not configured**
- Ensure `Capivv.shared.configure()` is called before any SDK methods
- Check that the API key is valid

**Login fails**
- Verify the backend is running and accessible
- Check network connectivity
- Ensure the user ID is not empty

**No offerings displayed**
- Confirm products are configured in the dashboard
- Check that the app is associated with products
- Verify StoreKit products are set up in App Store Connect

**Purchases fail**
- Ensure StoreKit testing is enabled for development
- Check sandbox account configuration
- Verify the product identifiers match

### Debug Mode

Enable debug logging by running with the `-verbose` launch argument or checking the Xcode console for SDK logs prefixed with `[Capivv]`.

## Support

- [Documentation](https://docs.capivv.com)
- [API Reference](https://docs.capivv.com/api)
- [Discord Community](https://discord.gg/capivv)
- [GitHub Issues](https://github.com/capivv/capivv-ios/issues)

## License

This example app is provided under the MIT License. See LICENSE for details.
