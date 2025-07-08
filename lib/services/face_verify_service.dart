import 'package:flutter/services.dart';

class FaceVerifyService {
  static const MethodChannel _channel = MethodChannel('tencent_face_verify');

  static Future<FaceVerifyResult> startFaceVerify({
    required String appId,
    required String userId,
    required String orderNo,
    required String nonce,
    required String sign,
    required String faceId,
    required String licence,
  }) async {
    try {
      final result = await _channel.invokeMethod('startFaceVerify', {
        'appId': appId,
        'userId': userId,
        'orderNo': orderNo,
        'nonce': nonce,
        'sign': sign,
        'faceId': faceId,
        'licence': licence,
      });
      
      return FaceVerifyResult.fromMap(result);
    } on PlatformException catch (e) {
      return FaceVerifyResult.failure(
        code: e.code,
        message: e.message ?? 'Unknown error',
        details: e.details,
      );
    }
  }
}