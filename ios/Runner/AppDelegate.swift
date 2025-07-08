import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let faceVerifyChannel = FlutterMethodChannel(name: "com.tencent.cloud/face_verify",
                                               binaryMessenger: controller.binaryMessenger)
    
    faceVerifyChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "startFaceVerify":
        guard let args = call.arguments as? [String: Any] else {
          result(FlutterError(code: "INVALID_ARGUMENTS",
                            message: "Arguments must be a dictionary",
                            details: nil))
          return
        }
        
        FaceVerifyManager.sharedInstance().startFaceVerify(withParams: args, result: result)
        
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
