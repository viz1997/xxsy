import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_tencent_faceid/config/app_config.dart';

final faceVerificationServiceProvider = Provider<FaceVerificationService>((ref) {
  return FaceVerificationService();
});

// face_verification_service.dart
class FaceVerificationService {
  String? _secretId;
  String? _secretKey;

  Future<void> init({
    required String secretId,
    required String secretKey,
  }) async {
    _secretId = secretId;
    _secretKey = secretKey;
  }

  /// 获取活体检测视频
  Future<String> getLivenessVideo({
    required String idCard,
    required String name,
  }) async {
    if (_secretId == null || _secretKey == null) {
      throw Exception('FaceVerificationService not initialized');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final nonce = DateTime.now().millisecondsSinceEpoch.toString();
    
    final response = await http.post(
      Uri.parse('https://faceid.tencentcloudapi.com'),
      headers: {
        'Authorization': _generateSignature('LivenessRecognition', timestamp, nonce),
        'Content-Type': 'application/json',
        'X-TC-Action': 'LivenessRecognition',
        'X-TC-Version': '2018-03-01',
        'X-TC-Timestamp': timestamp.toString(),
        'X-TC-Region': '',
      },
      body: jsonEncode({
        'IdCard': idCard,
        'Name': name,
        'LivenessType': 'SILENT',  // 使用静默活体检测
        'Optional': jsonEncode({
          'BestFrameNum': 1  // 只需要返回一张最佳截图
        }),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get liveness video: ${response.body}');
    }

    final data = jsonDecode(response.body);
    if (data['Response'] == null) {
      throw Exception('Invalid response format: ${response.body}');
    }

    final responseData = data['Response'];
    if (responseData['Error'] != null) {
      throw Exception('API Error: ${responseData['Error']['Message']}');
    }

    // 返回视频的 URL 或 Base64 数据
    return responseData['VideoUrl'] ?? responseData['VideoBase64'];
  }

  /// 验证活体检测结果
  Future<FaceVerificationResult> verifyLiveness({
    required String idCard,
    required String name,
    required String videoBase64,
  }) async {
    if (_secretId == null || _secretKey == null) {
      throw Exception('FaceVerificationService not initialized');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final nonce = DateTime.now().millisecondsSinceEpoch.toString();

    final response = await http.post(
      Uri.parse('https://faceid.tencentcloudapi.com'),
      headers: {
        'Authorization': _generateSignature('LivenessRecognition', timestamp, nonce),
        'Content-Type': 'application/json',
        'X-TC-Action': 'LivenessRecognition',
        'X-TC-Version': '2018-03-01',
        'X-TC-Timestamp': timestamp.toString(),
        'X-TC-Region': '',
      },
      body: jsonEncode({
        'IdCard': idCard,
        'Name': name,
        'LivenessType': 'SILENT',
        'VideoBase64': videoBase64,
        'Optional': jsonEncode({
          'BestFrameNum': 1
        }),
      }),
    );

    if (response.statusCode != 200) {
      return FaceVerificationResult(
        isSuccess: false,
        errorMessage: 'Failed to verify liveness: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    final responseData = data['Response'];
    
    return FaceVerificationResult(
      isSuccess: responseData['Result'] == 'Success',
      errorMessage: responseData['Description'],
      data: {
        'sim': responseData['Sim'],
        'bestFrame': responseData['BestFrameBase64'],
      },
    );
  }

  /// 获取 faceId
  Future<String> getFaceId({
    required String name,
    required String idCard,
  }) async {
    if (_secretId == null || _secretKey == null) {
      throw Exception('FaceVerificationService not initialized');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final nonce = DateTime.now().millisecondsSinceEpoch.toString();
    final orderNo = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

    final response = await http.post(
      Uri.parse('https://kyc1.qcloud.com/api/server/getPlusFaceId'),
      headers: {
        'Authorization': _generateSignature('getPlusFaceId', timestamp, nonce),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'appId': AppConfig.tencentCloudAppId,
        'orderNo': orderNo,
        'name': name,
        'idNo': idCard,
        'userId': idCard,
        'version': '1.0.0',
        'sign': _generateSignature('getPlusFaceId', timestamp, nonce),
        'nonce': nonce,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get faceId: ${response.body}');
    }

    final data = jsonDecode(response.body);
    if (data['code'] != '0') {
      throw Exception('API Error: ${data['msg']}');
    }

    return data['result']['faceId'];
  }

  String _generateSignature(String action, int timestamp, String nonce) {
    // 1. 拼接规范请求串
    final canonicalRequest = '''
POST
/

content-type:application/json
host:faceid.tencentcloudapi.com
x-tc-action:${action.toLowerCase()}
x-tc-timestamp:$timestamp
x-tc-version:2018-03-01

content-type;host;x-tc-action;x-tc-timestamp;x-tc-version
${sha256.convert(utf8.encode(jsonEncode({
      'IdCard': 'placeholder',
      'Name': 'placeholder',
      'LivenessType': 'SILENT',
      'Optional': jsonEncode({'BestFrameNum': 1}),
    }))).toString()}''';

    // 2. 拼接待签名字符串
    final credentialScope = '2018-03-01/faceid/tc3_request';
    final stringToSign = '''
TC3-HMAC-SHA256
$timestamp
$credentialScope
${sha256.convert(utf8.encode(canonicalRequest)).toString()}''';

    // 3. 计算签名
    List<int> hmacSha256(List<int> key, String data) {
      return Hmac(sha256, key).convert(utf8.encode(data)).bytes;
    }

    final secretKey = utf8.encode('TC3$_secretKey');
    final secretDate = hmacSha256(secretKey, '2018-03-01');
    final secretService = hmacSha256(secretDate, 'faceid');
    final secretSigning = hmacSha256(secretService, 'tc3_request');
    final signature = Hmac(sha256, secretSigning)
        .convert(utf8.encode(stringToSign))
        .toString();

    // 4. 拼接 Authorization
    return 'TC3-HMAC-SHA256 Credential=$_secretId/$credentialScope, '
        'SignedHeaders=content-type;host;x-tc-action;x-tc-timestamp;x-tc-version, '
        'Signature=$signature';
  }
}

// 人脸核身结果模型
class FaceVerificationResult {
  final bool isSuccess;
  final String? errorMessage;
  final Map<String, dynamic>? data;

  FaceVerificationResult({
    required this.isSuccess,
    this.errorMessage,
    this.data,
  });

  double? get similarity => data?['sim'] as double?;
  String? get bestFrame => data?['bestFrame'] as String?;
} 