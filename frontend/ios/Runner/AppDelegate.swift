import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    guard let googleMapApiKey = Bundle.main.infoDictionary?["GOOGLE_MAP_API_KEY"] as? String else {
      fatalError("GoogleMapsApiKey is not set in Info.plist")
    }
    GMSServices.provideAPIKey(googleMapApiKey)

    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
