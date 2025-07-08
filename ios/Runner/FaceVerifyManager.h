#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface FaceVerifyManager : NSObject

+ (instancetype)sharedInstance;

- (void)startFaceVerifyWithParams:(NSDictionary *)params result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END 