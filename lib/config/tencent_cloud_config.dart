import 'package:flutter_tencent_faceid/utils/generate_test_usersig.dart';

class TencentCloudConfig {
  // 腾讯云 IM 应用的 SDKAppID（请替换为你的实际 SDKAppID）
  static const int sdkAppID = 1600093463;
  // 腾讯云 IM 控制台获取的 secretKey（请替换为你的实际 secretKey，仅用于本地测试！）
  static const String secretKey = '26bb3d8d56ed7a7c231d043896089770adec444fc077172db4d1bf64c4211e4a';

  /// 本地测试动态生成 UserSig
  /// 生产环境严禁在客户端生成 UserSig，必须由服务端生成！
  static String getUserSig(String userID) {
    final generator = GenerateTestUserSig(sdkappid: sdkAppID, key: secretKey);
    // 过期时间建议 7 天（单位：秒）
    return generator.genSig(identifier: userID, expire: 7 * 24 * 60 * 60);
  }
} 