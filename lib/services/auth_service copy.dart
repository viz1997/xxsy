import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AuthService {
  // 配置参数（应从安全存储中读取）
  static const String _secretId = 'YOUR_SECRET_ID';
  static const String _secretKey = 'YOUR_SECRET_KEY';
  static const String _service = 'faceid';
  static const String _host = 'faceid.tencentcloudapi.com';
  static const String _version = '2018-03-01';

  /// 手机号三要素核验（完整实现）
  static Future<VerifyResponse> verifyPhoneThreeFactors({
    required String name,
    required String idCard,
    required String phone,
    String verifyMode = '0', // 0-简版 1-详版
  }) async {
    try {
      // 1. 准备请求参数
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final date = DateFormat('yyyy-MM-dd')
          .format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true));

      // 2. 构建请求体
      final payload = jsonEncode({
        'Name': name,
        'IdCard': idCard,
        'Phone': phone,
        'VerifyMode': verifyMode,
      });

      // 3. 生成签名
      final signature = _generateSignature(
        action: 'PhoneVerification',
        timestamp: timestamp,
        date: date,
        payload: payload,
      );

      // 4. 发送请求
      final response = await http.post(
        Uri.https(_host, '/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': signature['authorization'] ?? '',
          'X-TC-Action': 'PhoneVerification',
          'X-TC-Version': _version,
          'X-TC-Timestamp': timestamp.toString(),
          'X-TC-Region': '',
        },
        body: payload,
      );

      // 5. 处理响应
      final result = jsonDecode(response.body)['Response'];
      return VerifyResponse(
        result['Result'] == '0',
        errorMessage: _parseErrorCode(result['Result']),
        detail: result['ResultDetail'],
        isp: result['Isp'],
      );
    } catch (e) {
      debugPrint('三要素核验异常: $e');
      return VerifyResponse(false, errorMessage: '服务请求失败');
    }
  }

  /// 生成TC3-HMAC-SHA256签名
  static Map<String, String> _generateSignature({
    required String action,
    required int timestamp,
    required String date,
    required String payload,
  }) {
    // ************* 步骤1：拼接规范请求串 *************
    final canonicalRequest = '''
POST
/

content-type:application/json; charset=utf-8
host:$_host
x-tc-action:${action.toLowerCase()}

content-type;host;x-tc-action
${sha256.convert(utf8.encode(payload))}''';

    // ************* 步骤2：拼接待签名字符串 *************
    final credentialScope = '$date/$_service/tc3_request';
    final stringToSign = '''
TC3-HMAC-SHA256
$timestamp
$credentialScope
${sha256.convert(utf8.encode(canonicalRequest))}''';

    // ************* 步骤3：计算签名 *************
    List<int> hmacSha256(List<int> key, String data) {
      return Hmac(sha256, key).convert(utf8.encode(data)).bytes;
    }

    final secretKey = utf8.encode('TC3$_secretKey');
    final secretDate = hmacSha256(secretKey, date);
    final secretService = hmacSha256(secretDate, _service);
    final secretSigning = hmacSha256(secretService, 'tc3_request');
    final signature = Hmac(sha256, secretSigning)
        .convert(utf8.encode(stringToSign))
        .toString();

    // ************* 步骤4：拼接Authorization *************
    final authorization =
        'TC3-HMAC-SHA256 Credential=$_secretId/$credentialScope, '
        'SignedHeaders=content-type;host;x-tc-action, Signature=$signature';

    return {
      'authorization': authorization,
      'canonicalRequest': canonicalRequest, // 调试用
    };
  }

  /// 错误码解析
  static String _parseErrorCode(String code) {
    const errors = {
      '0': '验证通过',
      '-4': '姓名、身份证号或手机号不一致',
      '-6': '手机号格式错误',
      '-7': '身份证号格式错误',
      '-8': '姓名格式错误',
      '-9': '无此记录',
      '-11': '系统繁忙',
      '-12': '超过当日验证限制',
    };
    return errors[code] ?? '未知错误($code)';
  }

  /// 发送短信验证码
  static Future<void> sendSmsCode(String phone) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final date = DateFormat('yyyy-MM-dd')
          .format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true));

      final payload = jsonEncode({
        'Phone': phone,
      });

      final signature = _generateSignature(
        action: 'SendSmsCode',
        timestamp: timestamp,
        date: date,
        payload: payload,
      );

      final response = await http.post(
        Uri.https(_host, '/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': signature['authorization'] ?? '',
          'X-TC-Action': 'SendSmsCode',
          'X-TC-Version': _version,
          'X-TC-Timestamp': timestamp.toString(),
          'X-TC-Region': '',
        },
        body: payload,
      );

      if (response.statusCode != 200) {
        throw Exception('发送验证码失败: ${response.body}');
      }

      final result = jsonDecode(response.body)['Response'];
      if (result['Result'] != '0') {
        throw Exception(_parseErrorCode(result['Result']));
      }
    } catch (e) {
      debugPrint('发送验证码异常: $e');
      rethrow;
    }
  }

  /// 验证短信验证码
  static Future<bool> verifySmsCode(String phone, String code) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final date = DateFormat('yyyy-MM-dd')
          .format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true));

      final payload = jsonEncode({
        'Phone': phone,
        'Code': code,
      });

      final signature = _generateSignature(
        action: 'VerifySmsCode',
        timestamp: timestamp,
        date: date,
        payload: payload,
      );

      final response = await http.post(
        Uri.https(_host, '/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': signature['authorization'] ?? '',
          'X-TC-Action': 'VerifySmsCode',
          'X-TC-Version': _version,
          'X-TC-Timestamp': timestamp.toString(),
          'X-TC-Region': '',
        },
        body: payload,
      );

      if (response.statusCode != 200) {
        return false;
      }

      final result = jsonDecode(response.body)['Response'];
      return result['Result'] == '0';
    } catch (e) {
      debugPrint('验证短信验证码异常: $e');
      return false;
    }
  }
}

/// 响应数据模型
class VerifyResponse {
  final bool isPass;
  final String? errorMessage;
  final String? detail; // 详细错误信息（当VerifyMode=1时返回）
  final String? isp; // 运营商名称

  VerifyResponse(
    this.isPass, {
    this.errorMessage,
    this.detail,
    this.isp,
  });

  @override
  String toString() {
    return 'VerifyResponse{isPass: $isPass, error: $errorMessage, detail: $detail, isp: $isp}';
  }
}