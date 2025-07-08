import 'dart:io';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileApi {
  /// 上传图片，返回图片url
  Future<String?> uploadPicture(File file) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/commonUtils/file/uploadPicture');
    final dio = Dio();
    // 获取token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
    });
    try {
      final response = await dio.post(url.toString(), data: formData);
      print('上传返回: \nstatusCode: \${response.statusCode}\ndata: \${response.data}');
      if (response.statusCode == 200 && response.data['code'] == 200) {
        return response.data['data']['url'] as String?;
      } else {
        print('上传失败: \nstatusCode: \${response.statusCode}\ndata: \${response.data}');
      }
    } catch (e) {
      print('上传异常: $e');
    }
    return null;
  }

  /// 获取临时凭证
  Future<Map<String, dynamic>?> getTempCertificate() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/commonUtils/file/tempCertificate');
    final dio = Dio();
    try {
      final response = await dio.get(url.toString());
      if (response.statusCode == 200 && response.data['code'] == 200) {
        return response.data['data'] as Map<String, dynamic>;
      }
    } catch (e) {
      // ignore
    }
    return null;
  }
} 