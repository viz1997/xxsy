#import "FaceVerifyManager.h"
#import <WBCloudReflectionFaceVerify/WBFaceVerifyCustomerService.h>

@interface FaceVerifyManager () <WBFaceVerifyCustomerServiceDelegate>

@property (nonatomic, copy) FlutterResult flutterResult;

@end

@implementation FaceVerifyManager

+ (instancetype)sharedInstance {
    static FaceVerifyManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FaceVerifyManager alloc] init];
    });
    return instance;
}

- (void)startFaceVerifyWithParams:(NSDictionary *)params result:(FlutterResult)result {
    self.flutterResult = result;
    
    // 配置SDK
    WBFaceVerifySDKConfig *config = [WBFaceVerifySDKConfig sdkConfig];
    config.language = WBFaceVerifyLanguage_ZH_CN;  // 设置语言
    config.mute = NO;  // 是否静音
    config.recordVideo = YES;  // 是否录制视频
    config.theme = WBFaceVerifyThemeLightness;  // 设置主题
    
    // 从params中获取必要参数
    NSString *userId = params[@"userId"];
    NSString *nonce = params[@"nonce"];
    NSString *sign = params[@"sign"];
    NSString *appId = params[@"appId"];
    NSString *orderNo = params[@"orderNo"];
    NSString *faceId = params[@"faceId"];
    NSString *licence = params[@"licence"];
    
    // 初始化SDK
    [[WBFaceVerifyCustomerService sharedInstance] initSDKWithUserId:userId
                                                             nonce:nonce
                                                              sign:sign
                                                             appid:appId
                                                           orderNo:orderNo
                                                        apiVersion:@"1.0.0"
                                                           licence:licence
                                                            faceId:faceId
                                                         sdkConfig:config
                                                           success:^{
        // SDK初始化成功，启动人脸识别
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL success = [[WBFaceVerifyCustomerService sharedInstance] startWbFaceVerifySdk];
            if (!success) {
                if (self.flutterResult) {
                    self.flutterResult(@{
                        @"success": @NO,
                        @"message": @"启动人脸识别失败"
                    });
                }
            }
        });
    } failure:^(WBFaceError * _Nonnull error) {
        // SDK初始化失败
        if (self.flutterResult) {
            self.flutterResult(@{
                @"success": @NO,
                @"message": error.desc,
                @"errorCode": @(error.code),
                @"domain": error.domain
            });
        }
    }];
    
    // 设置代理
    [WBFaceVerifyCustomerService sharedInstance].delegate = self;
}

#pragma mark - WBFaceVerifyCustomerServiceDelegate

- (void)wbfaceVerifyCustomerServiceDidFinishedWithResult:(WBFaceVerifyResult *)result {
    if (self.flutterResult) {
        if (result.isSuccess) {
            self.flutterResult(@{
                @"success": @YES,
                @"sign": result.sign ?: @"",
                @"orderNo": result.orderNo ?: @"",
                @"liveRate": result.liveRate ?: @"",
                @"similarity": result.similarity ?: @"",
                @"userImageString": result.userImageString ?: @""
            });
        } else {
            self.flutterResult(@{
                @"success": @NO,
                @"message": result.error.desc ?: @"验证失败",
                @"errorCode": @(result.error.code),
                @"domain": result.error.domain ?: @""
            });
        }
    }
}

@end 