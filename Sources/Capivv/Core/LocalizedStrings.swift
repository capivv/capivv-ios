import Foundation

/// Provides localized strings for the Capivv SDK.
/// Uses the SDK's bundle for localization, allowing host apps to override strings.
public enum L10n {
    // MARK: - Common

    public static var commonContinue: String {
        localized("capivv.common.continue", defaultValue: "Continue")
    }

    public static var commonCancel: String {
        localized("capivv.common.cancel", defaultValue: "Cancel")
    }

    public static var commonClose: String {
        localized("capivv.common.close", defaultValue: "Close")
    }

    public static var commonDone: String {
        localized("capivv.common.done", defaultValue: "Done")
    }

    public static var commonLoading: String {
        localized("capivv.common.loading", defaultValue: "Loading...")
    }

    public static var commonProcessing: String {
        localized("capivv.common.processing", defaultValue: "Processing...")
    }

    public static var commonError: String {
        localized("capivv.common.error", defaultValue: "Error")
    }

    public static var commonSuccess: String {
        localized("capivv.common.success", defaultValue: "Success")
    }

    public static var commonTryAgain: String {
        localized("capivv.common.tryAgain", defaultValue: "Try Again")
    }

    // MARK: - Paywall

    public static var paywallRestore: String {
        localized("capivv.paywall.restore", defaultValue: "Restore Purchases")
    }

    public static var paywallRestoring: String {
        localized("capivv.paywall.restoring", defaultValue: "Restoring...")
    }

    public static var paywallPurchasing: String {
        localized("capivv.paywall.purchasing", defaultValue: "Purchasing...")
    }

    public static func paywallStartTrial(days: Int) -> String {
        String(format: localized("capivv.paywall.startTrial", defaultValue: "Start %d-day free trial"), days)
    }

    public static func paywallThen(price: String) -> String {
        String(format: localized("capivv.paywall.then", defaultValue: "Then %@"), price)
    }

    public static var paywallPerMonth: String {
        localized("capivv.paywall.perMonth", defaultValue: "/month")
    }

    public static var paywallPerYear: String {
        localized("capivv.paywall.perYear", defaultValue: "/year")
    }

    public static var paywallPerWeek: String {
        localized("capivv.paywall.perWeek", defaultValue: "/week")
    }

    public static var paywallBestValue: String {
        localized("capivv.paywall.bestValue", defaultValue: "Best Value")
    }

    public static var paywallMostPopular: String {
        localized("capivv.paywall.mostPopular", defaultValue: "Most Popular")
    }

    public static func paywallSave(percent: Int) -> String {
        String(format: localized("capivv.paywall.save", defaultValue: "Save %@%%"), "\(percent)")
    }

    public static var paywallFreeTrialIncluded: String {
        localized("capivv.paywall.freeTrialIncluded", defaultValue: "Free trial included")
    }

    public static var paywallTermsAndPrivacy: String {
        localized("capivv.paywall.termsAndPrivacy", defaultValue: "Terms of Service & Privacy Policy")
    }

    public static var paywallLegalDisclaimer: String {
        localized("capivv.paywall.legalDisclaimer", defaultValue: "Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period.")
    }

    // MARK: - Errors

    public static var errorUnableToLoad: String {
        localized("capivv.error.unableToLoad", defaultValue: "Unable to Load")
    }

    public static var errorPurchaseFailed: String {
        localized("capivv.error.purchaseFailed", defaultValue: "Purchase Failed")
    }

    public static var errorRestoreFailed: String {
        localized("capivv.error.restoreFailed", defaultValue: "Restore Failed")
    }

    public static var errorNetworkError: String {
        localized("capivv.error.networkError", defaultValue: "Network Error")
    }

    public static var errorSomethingWentWrong: String {
        localized("capivv.error.somethingWentWrong", defaultValue: "Something went wrong")
    }

    public static var errorDismiss: String {
        localized("capivv.error.dismiss", defaultValue: "Dismiss")
    }

    // MARK: - Cancellation

    public static var cancellationTitle: String {
        localized("capivv.cancellation.title", defaultValue: "Before you go...")
    }

    public static var cancellationWhyLeaving: String {
        localized("capivv.cancellation.whyLeaving", defaultValue: "Why are you thinking of leaving?")
    }

    public static var cancellationWeHearYou: String {
        localized("capivv.cancellation.weHearYou", defaultValue: "We hear you")
    }

    public static var cancellationSpecialOffer: String {
        localized("capivv.cancellation.specialOffer", defaultValue: "Here's a special offer for you")
    }

    public static var cancellationAcceptOffer: String {
        localized("capivv.cancellation.acceptOffer", defaultValue: "Accept Offer")
    }

    public static var cancellationNoThanks: String {
        localized("capivv.cancellation.noThanks", defaultValue: "No thanks")
    }

    public static var cancellationConfirmCancel: String {
        localized("capivv.cancellation.confirmCancel", defaultValue: "Confirm Cancellation")
    }

    public static var cancellationKeepSubscription: String {
        localized("capivv.cancellation.keepSubscription", defaultValue: "Keep My Subscription")
    }

    // MARK: - Cancellation Reasons

    public static var reasonTooExpensive: String {
        localized("capivv.cancellation.reason.tooExpensive", defaultValue: "Too expensive")
    }

    public static var reasonNotUsing: String {
        localized("capivv.cancellation.reason.notUsing", defaultValue: "Not using enough")
    }

    public static var reasonMissingFeatures: String {
        localized("capivv.cancellation.reason.missingFeatures", defaultValue: "Missing features")
    }

    public static var reasonSwitchingToCompetitor: String {
        localized("capivv.cancellation.reason.switchingToCompetitor", defaultValue: "Switching to competitor")
    }

    public static var reasonTechnicalIssues: String {
        localized("capivv.cancellation.reason.technicalIssues", defaultValue: "Technical issues")
    }

    public static var reasonOther: String {
        localized("capivv.cancellation.reason.other", defaultValue: "Other")
    }

    // MARK: - Promotions

    public static var promotionLimitedTime: String {
        localized("capivv.promotion.limitedTime", defaultValue: "Limited Time Offer")
    }

    public static func promotionExpiresIn(time: String) -> String {
        String(format: localized("capivv.promotion.expiresIn", defaultValue: "Expires in %@"), time)
    }

    public static var promotionClaim: String {
        localized("capivv.promotion.claim", defaultValue: "Claim Offer")
    }

    public static var promotionCodeEntry: String {
        localized("capivv.promotion.codeEntry", defaultValue: "Enter promo code")
    }

    public static var promotionApply: String {
        localized("capivv.promotion.apply", defaultValue: "Apply")
    }

    public static var promotionInvalidCode: String {
        localized("capivv.promotion.invalidCode", defaultValue: "Invalid promo code")
    }

    public static var promotionCodeApplied: String {
        localized("capivv.promotion.codeApplied", defaultValue: "Promo code applied!")
    }

    // MARK: - Time Periods

    public static func period(_ value: Int, unit: PeriodUnit) -> String {
        let key: String
        let defaultValue: String

        switch unit {
        case .day:
            key = value == 1 ? "capivv.time.day" : "capivv.time.days"
            defaultValue = value == 1 ? "day" : "days"
        case .week:
            key = value == 1 ? "capivv.time.week" : "capivv.time.weeks"
            defaultValue = value == 1 ? "week" : "weeks"
        case .month:
            key = value == 1 ? "capivv.time.month" : "capivv.time.months"
            defaultValue = value == 1 ? "month" : "months"
        case .year:
            key = value == 1 ? "capivv.time.year" : "capivv.time.years"
            defaultValue = value == 1 ? "year" : "years"
        }

        return "\(value) \(localized(key, defaultValue: defaultValue))"
    }

    public enum PeriodUnit {
        case day, week, month, year
    }

    // MARK: - Private

    private static func localized(_ key: String, defaultValue: String) -> String {
        // Use the auto-generated Bundle.module from SPM
        let localizedString = Bundle.module.localizedString(forKey: key, value: nil, table: nil)

        // If we got the key back (not found), return the default
        if localizedString == key {
            return defaultValue
        }

        return localizedString
    }
}
