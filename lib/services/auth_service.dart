import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class AuthService {
  static final Dio _dio = Dio();
  static const String _baseUrl = 'https://kyci.qcloud.com/api';

  // 获取Access Token
  static Future<String> getAccessToken() async {
    final response = await _dio.get(
      '$_baseUrl/oauth2/access_token',
      queryParameters: {
        'appId': 'your_wb_app_id', // 替换为你的WBappid
        'secret': 'your_secret',   // 替换为你的Secret
        'grant_type': 'client_credential',
        'version': '1.0.0',
      },
    );
    
    if (response.data['code'] == '0') {
      return response.data['access_token'];
    } else {
      throw Exception('Failed to get access token: ${response.data['msg']}');
    }
  }

  // 获取SIGN ticket
  static Future<String> getSignTicket(String accessToken) async {
    final response = await _dio.get(
      '$_baseUrl/oauth2/api_ticket',
      queryParameters: {
        'appId': 'your_wb_app_id', // 替换为你的WBappid
        'access_token': accessToken,
        'type': 'SIGN',
        'version': '1.0.0',
      },
    );
    
    if (response.data['code'] == '0') {
      return response.data['tickets'][0]['value'];
    } else {
      throw Exception('Failed to get sign ticket: ${response.data['msg']}');
    }
  }

  // 获取faceId (简化版，实际需要调用腾讯云API)
  static Future<String> getFaceId({
    required String name,
    required String idCard,
  }) async {
    // 这里应该是调用腾讯云后台上传身份信息接口
    // 实际实现需要对接腾讯云API
    return 'generated_face_id_${DateTime.now().millisecondsSinceEpoch}';
  }

  // 发送短信验证码
  static Future<void> sendSmsCode(String phone) async {
    // 模拟发送验证码
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('发送验证码到: $phone');
  }

  // 注册用户
  static Future<void> register({
    required String name,
    required String idCard,
    required String phone,
    required String password,
  }) async {
    // 模拟注册API调用
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('注册用户: $name, $phone');
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