import 'package:flutter/services.dart'; // 必须添加这行导入

class TencentFaceId {
  static const _channel = MethodChannel('tencent_faceid');

  /// 初始化SDK（纯测试版）
  static Future<bool> initSDK({
    required String userId,
    required String name,
    required String idNo,
  }) async {
    try {
      return await _channel.invokeMethod('initSDK', {
        'userId': userId,
        'name': name.trim(),
        'idNo': idNo.trim(),
      }) ?? false;
    } on PlatformException catch (e) {
      throw Exception('初始化失败: ${e.message}');
    }
  }

  /// 启动核身
  static Future<FaceIdResult> startVerification() async {
    try {
      final result = await _channel.invokeMethod<Map>('startVerification');
      return FaceIdResult.fromMap(result ?? {});
    } on PlatformException catch (e) {
      throw Exception('核身失败: ${e.message}');
    }
  }
}

/// 核身结果封装
class FaceIdResult {
  final bool isSuccess;
  final String? liveRate;
  final String? similarity;
  final String? errorCode;
  final String? errorMsg;

  FaceIdResult({
    required this.isSuccess,
    this.liveRate,
    this.similarity,
    this.errorCode,
    this.errorMsg,
  });

  factory FaceIdResult.fromMap(Map<dynamic, dynamic> map) {
    // 解析 error map
    String? errorCode;
    String? errorMsg;
    if (map['error'] is Map) {
      errorCode = map['error']['code']?.toString();
      errorMsg = map['error']['message']?.toString();
    }
    // 兼容旧字段
    errorCode ??= map['errorCode']?.toString();
    errorMsg ??= map['errorMsg']?.toString();

    return FaceIdResult(
      isSuccess: map['isSuccess'] == true,
      liveRate: map['liveRate']?.toString(),
      similarity: map['similarity']?.toString(),
      errorCode: errorCode,
      errorMsg: errorMsg,
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return '核身成功（活体分数: ${liveRate ?? "无"}, 相似度: ${similarity ?? "无"}）';
    }
    return '核身失败（${errorCode ?? "未知错误"}: ${errorMsg ?? "无详细信息"}）';
  }
}

/// 自定义异常类
class FaceIdException implements Exception {
  final String message;
  final String? code;

  FaceIdException(this.message, [this.code]);

  @override
  String toString() => 'FaceIdException: $message ${code != null ? '($code)' : ''}';
}