import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../utils/dio_client.dart';

class LoginApi {
  /// Handles user login.
  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
    required String code,
    required String uuid,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/account/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'code': code,
        'uuid': uuid,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      // Optionally handle error details
      return null;
    }
  }

  /// Handles user registration.
  Future<Map<String, dynamic>?> register({
    required String username,
    required String password,
    required String phoneNumber,
    required String smsCode,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/account/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'phoneNumber': phoneNumber,
        'smsCode': smsCode,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// Gets user routers/permissions.
  Future<List<Map<String, dynamic>>> getRouters() async {
    final response = await DioClient().dio.get('${AppConfig.apiBaseUrl}/getRouters');
    if (response.statusCode == 200) {
      return (response.data as List).cast<Map<String, dynamic>>();
    } else {
      throw Exception('获取路由失败: \\${response.data}');
    }
  }

  /// Gets user info after login (multiple endpoints with similar name, using the first one).
  Future<Map<String, dynamic>?> getUserInfo() async {
    // TODO: Implement actual API call using http.get for /getInfo
    await Future.delayed(const Duration(milliseconds: 500));
    return {'userData': 'Mock Logged In User Info'};
  }

  /// 获取短信验证码
  Future<Map<String, dynamic>?> getSmsCaptcha({
    required String phoneNumber,
    required String uuid,
    required String code,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/commonUtils/captcha/getSmsCaptcha?phoneNumber=$phoneNumber&uuid=$uuid&code=$code');
    final response = await DioClient().dio.getUri(url);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 获取字符图形验证码
  Future<Map<String, dynamic>?> getCharCaptcha() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/commonUtils/captcha/getCharCaptcha');
    final response = await DioClient().dio.getUri(url);
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      // 兼容 img 字段和 base64 字段
      if (data.containsKey('img')) {
        data['base64'] = data['img'];
      }
      return data;
    } else {
      return null;
    }
  }

  /// 修改用户手机号
  Future<Map<String, dynamic>> updatePhoneNumber({
    required String phoneNumber,
    required String smsCode,
  }) async {
    try {
      final response = await DioClient().dio.post(
        '/users/account/updatePhoneNumber',
        data: {
          'phoneNumber': phoneNumber,
          'smsCode': smsCode,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 修改用户密码
  Future<Map<String, dynamic>> updatePassword({
    required String captchaCode,
    required String uuid,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await DioClient().dio.post(
        '/users/account/updatePassword',
        data: {
          'captchaCode': captchaCode,
          'uuid': uuid,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 刷新访问令牌
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await DioClient().dio.post(
        '/users/account/refresh',
        queryParameters: {
          'refreshToken': refreshToken,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
} 