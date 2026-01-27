# Capivv iOS SDK

The official iOS SDK for Capivv - Revenue as Code platform.

## Requirements

- iOS 15.0+
- macOS 12.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/capivv/capivv-ios", from: "1.0.0")
]
```

Or add it in Xcode:
1. File > Add Package Dependencies...
2. Enter the repository URL
3. Select "Up to Next Major Version" with "1.0.0"

## Quick Start

### 1. Configure the SDK

```swift
import Capivv

// In your App init or AppDelegate
Capivv.shared.configure(apiKey: "YOUR_PUBLIC_API_KEY")
```

### 2. Identify Users

```swift
// After user authentication
try await Capivv.shared.login(userId: "user_123")
```

### 3. Display Offerings

```swift
let offerings = try await Capivv.shared.getOfferings()

for offering in offerings {
    print("Offering: \(offering.displayName)")
    for package in offering.packages {
        print("  - \(package.displayName): \(package.localizedPriceString ?? "N/A")")
    }
}
```

### 4. Make Purchases

```swift
let result = try await Capivv.shared.purchase(package: selectedPackage)

switch result {
case .success(let transaction):
    print("Purchase successful!")
case .userCancelled:
    print("User cancelled")
case .pending:
    print("Purchase pending approval")
case .failed(let error):
    print("Purchase failed: \(error)")
}
```

### 5. Check Entitlements

```swift
// Check a specific entitlement
if Capivv.shared.hasEntitlement("premium") {
    // Show premium features
}

// Get all entitlements
for entitlement in Capivv.shared.entitlements {
    print("\(entitlement.identifier): \(entitlement.isActive)")
}
```

## SwiftUI Integration

The SDK is designed for SwiftUI with `@Published` properties:

```swift
struct ContentView: View {
    @EnvironmentObject var capivv: Capivv

    var body: some View {
        if capivv.hasEntitlement("premium") {
            PremiumContent()
        } else {
            PaywallView()
        }
    }
}

// In your App
@main
struct MyApp: App {
    init() {
        Capivv.shared.configure(apiKey: "YOUR_API_KEY")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Capivv.shared)
        }
    }
}
```

## API Reference

### Capivv

| Method | Description |
|--------|-------------|
| `configure(apiKey:baseURL:)` | Initialize the SDK |
| `login(userId:)` | Identify a user |
| `logout()` | Clear user session |
| `getOfferings()` | Fetch available offerings |
| `purchase(package:)` | Purchase a package |
| `restorePurchases()` | Restore previous purchases |
| `refreshEntitlements()` | Refresh entitlements |
| `hasEntitlement(_:)` | Check if user has entitlement |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `isConfigured` | `Bool` | SDK configuration status |
| `isLoggedIn` | `Bool` | User login status |
| `userId` | `String?` | Current user ID |
| `entitlements` | `[Entitlement]` | User's entitlements |

## Models

### Offering

```swift
struct Offering {
    let identifier: String
    let displayName: String
    var packages: [Package]

    // Convenience accessors
    var monthly: Package?
    var annual: Package?
    var lifetime: Package?
}
```

### Package

```swift
struct Package {
    let identifier: String
    let packageType: PackageType
    let storeProductId: String
    var storeProduct: Product?

    var localizedPriceString: String?
    var price: Decimal?
}
```

### Entitlement

```swift
struct Entitlement {
    let identifier: String
    let displayName: String
    let isActive: Bool
    let expiresAt: Date?
    let source: EntitlementSource
}
```

## Error Handling

```swift
do {
    try await Capivv.shared.login(userId: "user_123")
} catch CapivvError.notConfigured {
    print("SDK not configured")
} catch CapivvError.networkError(let error) {
    print("Network error: \(error)")
} catch CapivvError.apiError(let code, let message) {
    print("API error [\(code)]: \(message)")
} catch {
    print("Unknown error: \(error)")
}
```

## Testing

For testing with StoreKit Configuration files:

1. Create a StoreKit Configuration file in Xcode
2. Add your test products
3. Enable the configuration in your scheme

## License

MIT License - see LICENSE file for details.
