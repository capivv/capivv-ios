import SwiftUI

/// View for entering and redeeming promo codes
public struct PromoCodeEntryView: View {
    @State private var code: String = ""
    @State private var isRedeeming = false
    @State private var result: RedemptionResult?
    @State private var error: Error?

    let onSuccess: ((RedemptionResult) -> Void)?
    let onDismiss: (() -> Void)?

    public init(
        onSuccess: ((RedemptionResult) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.onSuccess = onSuccess
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "ticket.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)

                    Text("Enter Promo Code")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Have a promotional code? Enter it below to redeem your offer.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)

                // Code input
                VStack(spacing: 8) {
                    TextField("Enter code", text: $code)
                        .textFieldStyle(.plain)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        #if os(iOS)
                        .textInputAutocapitalization(.characters)
                        #endif
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color.platformSecondaryBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(inputBorderColor, lineWidth: 2)
                        )

                    if let error = error {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)

                // Result view
                if let result = result {
                    resultView(result)
                        .padding(.horizontal)
                }

                Spacer()

                // Redeem button
                Button {
                    Task {
                        await redeemCode()
                    }
                } label: {
                    HStack {
                        if isRedeeming {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Redeem Code")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(code.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(12)
                }
                .disabled(code.isEmpty || isRedeeming)
                .padding(.horizontal)
            }
            .padding(.vertical)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onDismiss?()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                #else
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onDismiss?()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                #endif
            }
        }
    }

    // MARK: - Helpers

    private var inputBorderColor: Color {
        if error != nil {
            return .red
        } else if result?.success == true {
            return .green
        }
        return Color.clear
    }

    @ViewBuilder
    private func resultView(_ result: RedemptionResult) -> some View {
        HStack(spacing: 12) {
            Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(result.success ? .green : .red)

            VStack(alignment: .leading, spacing: 4) {
                Text(result.success ? "Code Redeemed!" : "Invalid Code")
                    .font(.headline)
                    .foregroundColor(result.success ? .green : .red)

                Text(result.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let discount = result.discountAppliedFormatted {
                    Text("Discount: \(discount)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(result.success ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        )
    }

    private func redeemCode() async {
        isRedeeming = true
        error = nil
        result = nil

        do {
            let redemptionResult = try await Capivv.shared.redeemPromotion(code: code.uppercased())
            result = redemptionResult

            if redemptionResult.success {
                onSuccess?(redemptionResult)
            }
        } catch {
            self.error = error
            Logger.error("Failed to redeem code: \(error)")
        }

        isRedeeming = false
    }
}

// MARK: - Inline Promo Code Field

/// A compact inline promo code field for embedding in other views
public struct InlinePromoCodeField: View {
    @State private var code: String = ""
    @State private var isRedeeming = false
    @State private var showSuccess = false

    let onSuccess: ((RedemptionResult) -> Void)?

    public init(onSuccess: ((RedemptionResult) -> Void)? = nil) {
        self.onSuccess = onSuccess
    }

    public var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "ticket")
                    .foregroundColor(.secondary)

                TextField("Promo code", text: $code)
                    #if os(iOS)
                    .textInputAutocapitalization(.characters)
                    #endif
                    .autocorrectionDisabled()
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.platformSecondaryBackground)
            .cornerRadius(8)

            Button {
                Task {
                    await applyCode()
                }
            } label: {
                Group {
                    if isRedeeming {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else if showSuccess {
                        Image(systemName: "checkmark")
                    } else {
                        Text("Apply")
                    }
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
                .frame(width: 70, height: 36)
                .background(showSuccess ? Color.green : (code.isEmpty ? Color.gray : Color.blue))
                .cornerRadius(8)
            }
            .disabled(code.isEmpty || isRedeeming || showSuccess)
        }
    }

    private func applyCode() async {
        isRedeeming = true

        do {
            let result = try await Capivv.shared.redeemPromotion(code: code.uppercased())
            if result.success {
                showSuccess = true
                onSuccess?(result)

                // Reset after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSuccess = false
                    code = ""
                }
            }
        } catch {
            Logger.error("Failed to apply code: \(error)")
        }

        isRedeeming = false
    }
}

// MARK: - Preview Support

#if DEBUG
struct PromoCodeEntryView_Previews: PreviewProvider {
    static var previews: some View {
        PromoCodeEntryView()
    }
}
#endif
