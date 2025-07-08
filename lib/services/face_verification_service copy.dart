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
  String? _bizToken;

  Future<void> init({
    required String secretId,
    required String secretKey,
  }) async {
    _secretId = secretId;
    _secretKey = secretKey;
  }

  Future<String> getFaceVerificationUrl({
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
        'Authorization': _generateSignature('GetFaceVerificationUrl', timestamp, nonce),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'IdCard': idCard,
        'Name': name,
        'RedirectUrl': AppConfig.faceVerificationRedirectUrl,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get verification URL: ${response.body}');
    }

    final data = jsonDecode(response.body);
    _bizToken = data['BizToken'];
    return data['Url'];
  }

  Future<FaceVerificationResult> getVerificationResult(String bizToken) async {
    if (_secretId == null || _secretKey == null) {
      throw Exception('FaceVerificationService not initialized');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final nonce = DateTime.now().millisecondsSinceEpoch.toString();

    final response = await http.post(
      Uri.parse('https://faceid.tencentcloudapi.com'),
      headers: {
        'Authorization': _generateSignature('GetFaceVerificationResult', timestamp, nonce),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'BizToken': bizToken,
      }),
    );

    if (response.statusCode != 200) {
      return FaceVerificationResult(
        isSuccess: false,
        errorMessage: 'Failed to get verification result: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    return FaceVerificationResult.fromJson(data);
  }

  Future<bool> verifyFace(String idCard, String name, File image) async {
    if (_secretId == null || _secretKey == null) {
      throw Exception('FaceVerificationService not initialized');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final nonce = DateTime.now().millisecondsSinceEpoch.toString();

    final response = await http.post(
      Uri.parse('https://faceid.tencentcloudapi.com'),
      headers: {
        'Authorization': _generateSignature('VerifyFace', timestamp, nonce),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'IdCard': idCard,
        'Name': name,
        'ImageBase64': base64Encode(image.readAsBytesSync()),
      }),
    );

    if (response.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(response.body);
    return data['Result'] == '0';
  }

  String _generateSignature(String action, int timestamp, String nonce) {
    final payload = {
      'Action': action,
      'Timestamp': timestamp,
      'Nonce': nonce,
      'SecretId': _secretId,
    };

    final sortedPayload = Map.fromEntries(
      payload.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );

    final stringToSign = sortedPayload.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final hmacSha1 = Hmac(sha1, utf8.encode(_secretKey!));
    final signature = base64Encode(hmacSha1.convert(utf8.encode(stringToSign)).bytes);

    return 'TC3-HMAC-SHA256 Credential=$_secretId/$timestamp, SignedHeaders=content-type;host, Signature=$signature';
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

  factory FaceVerificationResult.fromJson(Map<String, dynamic> json) {
    return FaceVerificationResult(
      isSuccess: json['isSuccess'] ?? false,
      errorMessage: json['errorMessage'],
      data: json['data'],
    );
  }
} 