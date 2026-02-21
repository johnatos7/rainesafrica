import UIKit
import Flutter
import AppTrackingTransparency
import AdSupport

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Called when the app becomes active (good time to show ATT prompt)
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    requestTrackingAuthorizationIfNeeded()
  }

  private func requestTrackingAuthorizationIfNeeded() {
    if #available(iOS 14, *) {
      let status = ATTrackingManager.trackingAuthorizationStatus

      // Only show the prompt if it hasn't been shown before
      guard status == .notDetermined else { return }

      ATTrackingManager.requestTrackingAuthorization { status in
        // You can initialize ad/analytics SDKs that require IDFA here,
        // but only after the user has made a choice.
        switch status {
        case .authorized:
          print("ATT: Tracking authorized")
        case .denied:
          print("ATT: Tracking denied")
        case .restricted:
          print("ATT: Tracking restricted")
        case .notDetermined:
          print("ATT: Not determined")
        @unknown default:
          print("ATT: Unknown status")
        }
      }
    }
  }
}
