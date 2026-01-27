import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A banner view for displaying an active promotion
public struct PromotionBannerView: View {
    let promotion: Promotion
    let onTap: (() -> Void)?

    public init(
        promotion: Promotion,
        onTap: (() -> Void)? = nil
    ) {
        self.promotion = promotion
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconBackgroundColor)
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(promotion.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if let timeRemaining = promotion.timeRemaining {
                        Text(formatTimeRemaining(timeRemaining))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Discount badge
                discountBadge

                // Arrow
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Campaign Type Specific

    private var iconBackgroundColor: Color {
        switch promotion.campaignType {
        case .flashSale:
            return .orange
        case .bundle:
            return .purple
        case .referral:
            return .blue
        case .segment:
            return .green
        }
    }

    private var iconName: String {
        switch promotion.campaignType {
        case .flashSale:
            return "bolt.fill"
        case .bundle:
            return "cube.fill"
        case .referral:
            return "person.2.fill"
        case .segment:
            return "star.fill"
        }
    }

    private var backgroundColor: Color {
        iconBackgroundColor.opacity(0.05)
    }

    private var borderColor: Color {
        iconBackgroundColor.opacity(0.2)
    }

    @ViewBuilder
    private var discountBadge: some View {
        let percent = promotion.discountPercent
        if percent > 0 {
            Text("\(Int(truncating: percent as NSDecimalNumber))% OFF")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(iconBackgroundColor)
                .cornerRadius(4)
        } else if let fixed = promotion.discountFixedFormatted {
            Text(fixed)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(iconBackgroundColor)
                .cornerRadius(4)
        }
    }

    private func formatTimeRemaining(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 24 {
            let days = hours / 24
            return "Ends in \(days) day\(days > 1 ? "s" : "")"
        } else if hours > 0 {
            return "Ends in \(hours)h \(minutes)m"
        } else {
            return "Ends in \(minutes) minutes"
        }
    }
}

// MARK: - Promotions List View

/// A list view showing all active promotions
public struct PromotionsListView: View {
    @State private var promotions: [Promotion] = []
    @State private var isLoading = true
    @State private var selectedPromotion: Promotion?

    let onSelectPromotion: ((Promotion) -> Void)?

    public init(onSelectPromotion: ((Promotion) -> Void)? = nil) {
        self.onSelectPromotion = onSelectPromotion
    }

    public var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if promotions.isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    ForEach(promotions) { promotion in
                        PromotionBannerView(promotion: promotion) {
                            selectedPromotion = promotion
                            onSelectPromotion?(promotion)
                        }
                    }
                }
            }
        }
        .task {
            await loadPromotions()
        }
        .sheet(item: $selectedPromotion) { promotion in
            PromotionDetailSheet(promotion: promotion)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tag.slash")
                .font(.title)
                .foregroundColor(.secondary)

            Text("No active promotions")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private func loadPromotions() async {
        isLoading = true
        do {
            promotions = try await Capivv.shared.getActivePromotions()
        } catch {
            Logger.error("Failed to load promotions: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Promotion Detail Sheet

/// Detail sheet for a promotion
struct PromotionDetailSheet: View {
    let promotion: Promotion
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        // Campaign type badge
                        Text(campaignTypeLabel)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(campaignColor)
                            .cornerRadius(4)

                        // Discount highlight
                        discountHighlight

                        // Title
                        Text(promotion.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        if let description = promotion.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()

                    // Time remaining
                    if let timeRemaining = promotion.timeRemaining {
                        CountdownView(timeRemaining: timeRemaining)
                            .padding(.horizontal)
                    }

                    // Code (if applicable)
                    if let code = promotion.code {
                        PromoCodeView(code: code)
                            .padding(.horizontal)
                    }

                    Spacer(minLength: 50)
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                #else
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                #endif
            }
        }
    }

    private var campaignTypeLabel: String {
        switch promotion.campaignType {
        case .flashSale: return "FLASH SALE"
        case .bundle: return "BUNDLE"
        case .referral: return "REFERRAL"
        case .segment: return "SPECIAL OFFER"
        }
    }

    private var campaignColor: Color {
        switch promotion.campaignType {
        case .flashSale: return .orange
        case .bundle: return .purple
        case .referral: return .blue
        case .segment: return .green
        }
    }

    @ViewBuilder
    private var discountHighlight: some View {
        let percent = promotion.discountPercent
        if percent > 0 {
            Text("\(Int(truncating: percent as NSDecimalNumber))%")
                .font(.system(size: 64, weight: .bold))
                .foregroundColor(campaignColor)
            Text("OFF")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(campaignColor)
        } else if let fixed = promotion.discountFixedFormatted {
            Text(fixed)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(campaignColor)
            Text("OFF")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(campaignColor)
        }
    }
}

// MARK: - Countdown View

struct CountdownView: View {
    let timeRemaining: TimeInterval
    @State private var remaining: TimeInterval
    @State private var timer: Timer?

    init(timeRemaining: TimeInterval) {
        self.timeRemaining = timeRemaining
        self._remaining = State(initialValue: timeRemaining)
    }

    var body: some View {
        HStack(spacing: 16) {
            CountdownUnit(value: days, label: "DAYS")
            Text(":")
                .font(.title)
                .foregroundColor(.secondary)
            CountdownUnit(value: hours, label: "HRS")
            Text(":")
                .font(.title)
                .foregroundColor(.secondary)
            CountdownUnit(value: minutes, label: "MIN")
            Text(":")
                .font(.title)
                .foregroundColor(.secondary)
            CountdownUnit(value: seconds, label: "SEC")
        }
        .padding()
        .background(Color.platformSecondaryBackground)
        .cornerRadius(12)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    private var days: Int { Int(remaining) / 86400 }
    private var hours: Int { (Int(remaining) % 86400) / 3600 }
    private var minutes: Int { (Int(remaining) % 3600) / 60 }
    private var seconds: Int { Int(remaining) % 60 }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remaining > 0 {
                remaining -= 1
            } else {
                stopTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct CountdownUnit: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%02d", value))
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Promo Code View

struct PromoCodeView: View {
    let code: String
    @State private var copied = false

    var body: some View {
        VStack(spacing: 8) {
            Text("Your code:")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text(code)
                    .font(.title3)
                    .fontWeight(.bold)
                    .monospacedDigit()

                Spacer()

                Button {
                    #if canImport(UIKit)
                    UIPasteboard.general.string = code
                    #endif
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        copied = false
                    }
                } label: {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .foregroundColor(copied ? .green : .blue)
                }
            }
            .padding()
            .background(Color.platformSecondaryBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundColor(.secondary.opacity(0.5))
            )
        }
    }
}
