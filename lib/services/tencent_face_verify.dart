import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

class TencentFaceVerify {
  static const _channel = MethodChannel('site.xxsy.match/face_verify');
  
  static Future<Map<String, dynamic>> startVerification({
    required String appId,
    required String userId,
    required String nonce,
    required String sign,
    required String faceId,
    required String agreementNo,
  }) async {
    try {
      final result = await _channel.invokeMethod('startFaceVerify', {
        'appId': appId,
        'userId': userId,
        'nonce': nonce,
        'sign': sign,
        'faceId': faceId,
        'agreementNo': agreementNo,
      });
      
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Face verification failed: ${e.message}');
    }
  }

  /// 生成签名
  static String generateSign({
    required String appId,
    required String userId,
    required String version,
    required String ticket,
    required String nonce,
  }) {
    // 1. 字典序排序
    final params = [
      version,
      appId,
      ticket,
      nonce,
      userId,
    ]..sort();

    // 2. 拼接字符串
    final signStr = params.join('');

    // 3. SHA1 加密
    final signBytes = utf8.encode(signStr);
    final digest = sha1.convert(signBytes);

    return digest.toString();
  }
} 