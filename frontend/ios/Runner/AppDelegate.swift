import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Info.plistから読み取る（環境変数が展開されている場合）
    var googleMapApiKey = Bundle.main.infoDictionary?["GoogleMapsApiKey"] as? String

    // Info.plistで環境変数が展開されていない場合、環境変数から直接読み取る
    if googleMapApiKey == nil || googleMapApiKey?.isEmpty == true {
      googleMapApiKey = ProcessInfo.processInfo.environment["GOOGLE_MAP_API_KEY"]
    }

    guard let apiKey = googleMapApiKey, !apiKey.isEmpty else {
      fatalError("GoogleMapsApiKey is not set. Please set GOOGLE_MAP_API_KEY in your .env file and build with --dart-define-from-file=.env")
    }
    GMSServices.provideAPIKey(apiKey)

    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
