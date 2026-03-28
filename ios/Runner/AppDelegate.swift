import UIKit
import Flutter
import GoogleMaps   // 👈 ADD THIS

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GMSServices.provideAPIKey("AQ.Ab8RN6IYwrppqt0i4Q7jUYTcruJFu_925hFXXVsh-E3otgIBlA")  // 👈 ADD HERE

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

