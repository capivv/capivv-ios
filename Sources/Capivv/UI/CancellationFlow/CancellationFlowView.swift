import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Main cancellation flow view that guides users through the cancellation process
public struct CancellationFlowView: View {
    /// Subscription ID to cancel
    let subscriptionId: String

    /// Dismiss callback
    let onDismiss: (() -> Void)?

    /// Cancellation completed callback (rescued: Bool)
    let onComplete: ((Bool) -> Void)?

    @StateObject private var viewModel: CancellationFlowViewModel
    @Environment(\.dismiss) private var dismiss

    public init(
        subscriptionId: String,
        onDismiss: (() -> Void)? = nil,
        onComplete: ((Bool) -> Void)? = nil
    ) {
        self.subscriptionId = subscriptionId
        self.onDismiss = onDismiss
        self.onComplete = onComplete
        self._viewModel = StateObject(wrappedValue: CancellationFlowViewModel(subscriptionId: subscriptionId))
    }

    public var body: some View {
        NavigationView {
            ZStack {
                Color.platformBackground
                    .ignoresSafeArea()

                Group {
                    switch viewModel.state {
                    case .loading:
                        loadingView

                    case .loaded(let flow):
                        flowContent(flow)

                    case .error(let error):
                        errorView(error)
                    }
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    if canGoBack {
                        Button {
                            viewModel.goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isCompleted {
                        Button {
                            handleDismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    if canGoBack {
                        Button {
                            viewModel.goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if !isCompleted {
                        Button {
                            handleDismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                #endif

                ToolbarItem(placement: .principal) {
                    if case .loaded = viewModel.state, !isCompleted {
                        ProgressView(value: viewModel.progress)
                            .progressViewStyle(.linear)
                            .frame(width: 100)
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
        .onChange(of: viewModel.currentStep) { newStep in
            if case .completed(let rescued) = newStep {
                onComplete?(rescued)
            }
        }
        .interactiveDismissDisabled(!isCompleted)
    }

    // MARK: - State Views

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            VStack(spacing: 8) {
                Text("Unable to Load")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                Task {
                    await viewModel.load()
                }
            } label: {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 160, height: 44)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
    }

    // MARK: - Flow Content

    @ViewBuilder
    private func flowContent(_ flow: CancellationFlow) -> some View {
        switch viewModel.currentStep {
        case .reason:
            ReasonStepView(viewModel: viewModel, flow: flow)

        case .rescueOffer(let offer):
            RescueOfferView(offer: offer, viewModel: viewModel)

        case .confirmation:
            ConfirmationStepView(viewModel: viewModel, onDismiss: { handleDismiss() })

        case .completed(let rescued):
            CompletedStepView(rescued: rescued, onDismiss: { handleDismiss() })
        }
    }

    // MARK: - Helpers

    private var canGoBack: Bool {
        switch viewModel.currentStep {
        case .reason, .completed:
            return false
        case .rescueOffer, .confirmation:
            return true
        }
    }

    private var isCompleted: Bool {
        if case .completed = viewModel.currentStep {
            return true
        }
        return false
    }

    private func handleDismiss() {
        onDismiss?()
        dismiss()
    }
}

// MARK: - Static Factory Methods

#if canImport(UIKit)
extension CancellationFlowView {
    /// Present the cancellation flow modally
    public static func present(
        subscriptionId: String,
        from presenter: UIViewController? = nil,
        onDismiss: (() -> Void)? = nil,
        onComplete: ((Bool) -> Void)? = nil
    ) {
        let flowView = CancellationFlowView(
            subscriptionId: subscriptionId,
            onDismiss: {
                presenter?.dismiss(animated: true)
                onDismiss?()
            },
            onComplete: onComplete
        )

        let hostingController = UIHostingController(rootView: flowView)
        hostingController.modalPresentationStyle = .pageSheet

        if let sheet = hostingController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        if let presenter = presenter {
            presenter.present(hostingController, animated: true)
        } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(hostingController, animated: true)
        }
    }
}
#endif

// MARK: - Preview Support

#if DEBUG
struct CancellationFlowView_Previews: PreviewProvider {
    static var previews: some View {
        CancellationFlowView(subscriptionId: "sub_123")
    }
}
#endif
