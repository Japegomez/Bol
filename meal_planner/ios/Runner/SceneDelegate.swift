import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    // Set up method channels once the Flutter engine (and its binary messenger)
    // is available via the scene's FlutterViewController.
    guard
      let windowScene = scene as? UIWindowScene,
      let window = windowScene.windows.first,
      let controller = window.rootViewController as? FlutterViewController
    else { return }

    // ── App Group channel (pending cooking actions) ───────────────────────────
    let appGroupChannel = FlutterMethodChannel(
      name: "com.japegomez.mealPlanner/cooking_app_group",
      binaryMessenger: controller.binaryMessenger
    )
    let appGroupId = "group.com.japegomez.mealPlanner.cooking"
    let pendingKey = "cooking_pending_action_v1"

    appGroupChannel.setMethodCallHandler { call, result in
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

    // ── Live Activity channel ─────────────────────────────────────────────────
    // Requires iOS 16.1+. On older versions the channel is registered but every
    // call returns nil so Flutter's try-catch handles it gracefully.
    if #available(iOS 16.1, *) {
      let laChannel = FlutterMethodChannel(
        name: "com.japegomez.mealPlanner/live_activity",
        binaryMessenger: controller.binaryMessenger
      )
      let manager = CookingActivityManager.shared

      laChannel.setMethodCallHandler { call, result in
        Task {
          do {
            switch call.method {
            case "update":
              guard let data = call.arguments as? [String: Any] else {
                result(FlutterError(code: "bad_args", message: "Expected [String:Any]", details: nil))
                return
              }
              try await manager.update(data: data)
              result(nil)
            case "end":
              await manager.end()
              result(nil)
            default:
              result(FlutterMethodNotImplemented)
            }
          } catch {
            result(FlutterError(
              code: "live_activity_error",
              message: error.localizedDescription,
              details: nil
            ))
          }
        }
      }
    }
  }
}
