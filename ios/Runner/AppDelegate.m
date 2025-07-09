 #import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "FaceVerifyManager.h"
#import <Flutter/Flutter.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];

  FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
  FlutterMethodChannel* faceVerifyChannel = [FlutterMethodChannel
      methodChannelWithName:@"com.tencent.cloud/face_verify"
            binaryMessenger:controller.binaryMessenger];

  [faceVerifyChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([call.method isEqualToString:@"startFaceVerify"]) {
      NSDictionary* args = call.arguments;
      [[FaceVerifyManager sharedInstance] startFaceVerifyWithParams:args result:result];
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end