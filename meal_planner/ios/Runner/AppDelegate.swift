import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.pluginRegistry
      .registrar(forPlugin: "CookingAppGroupChannel")!
      .messenger()
    let channel = FlutterMethodChannel(
      name: "com.japegomez.mealPlanner/cooking_app_group",
      binaryMessenger: messenger
    )
    let appGroupId = "group.com.japegomez.mealPlanner.cooking"
    let pendingKey = "cooking_pending_action_v1"

    channel.setMethodCallHandler { call, result in
      let defaults = UserDefaults(suiteName: appGroupId)
      switch call.method {
      case "getPendingAction":
        result(defaults?.string(forKey: pendingKey))
      case "setPendingAction":
        guard let action = call.arguments as? String else {
          result(FlutterError(code: "bad_args", message: "Expected String", details: nil))
          return
        }
        defaults?.set(action, forKey: pendingKey)
        result(nil)
      case "clearPendingAction":
        defaults?.removeObject(forKey: pendingKey)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
