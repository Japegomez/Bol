import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    // Set up the cooking App Group method channel once the Flutter engine
    // (and its binary messenger) is available via the scene's FlutterViewController.
    guard
      let windowScene = scene as? UIWindowScene,
      let window = windowScene.windows.first,
      let controller = window.rootViewController as? FlutterViewController
    else { return }

    let channel = FlutterMethodChannel(
      name: "com.japegomez.mealPlanner/cooking_app_group",
      binaryMessenger: controller.binaryMessenger
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
