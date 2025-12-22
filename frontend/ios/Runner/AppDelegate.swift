import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let googleMapApiKey = Bundle.main.infoDictionary?["GoogleMapsApiKey"] as? String else {
      fatalError("GoogleMapsApiKey is not set in Info.plist")
    }
    GMSServices.provideAPIKey(googleMapApiKey)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
