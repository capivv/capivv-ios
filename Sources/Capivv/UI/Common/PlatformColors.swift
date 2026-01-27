import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Cross-platform color extensions for SwiftUI
extension Color {
    /// Platform-appropriate background color
    static var platformBackground: Color {
        #if canImport(UIKit)
        return Color(.systemBackground)
        #elseif canImport(AppKit)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color.white
        #endif
    }

    /// Platform-appropriate secondary background color (like systemGray6)
    static var platformSecondaryBackground: Color {
        #if canImport(UIKit)
        return Color(.systemGray6)
        #elseif canImport(AppKit)
        return Color(nsColor: .controlBackgroundColor)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }

    /// Platform-appropriate grouped background color
    static var platformGroupedBackground: Color {
        #if canImport(UIKit)
        return Color(.systemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(nsColor: .controlBackgroundColor)
        #else
        return Color.gray.opacity(0.05)
        #endif
    }
}
