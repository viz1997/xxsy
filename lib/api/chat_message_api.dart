import '../config/app_config.dart';
import '../utils/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessageApi {
  /// 获取未读消息个数
  Future<int> getUnreadMsgNum() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/chat-msg/getUnreadMsgNum');
    final dio = DioClient().dio;
    // 获取token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    final response = await dio.getUri(url);
    print('未读消息数返回: statusCode: [200~[0m${response.statusCode}, data: ${response.data}');
    if (response.statusCode == 200 && response.data is Map && response.data['code'] == 200) {
      // 假设未读数在 data 字段下
      final data = response.data['data'];
      if (data is Map && data['unreadNum'] != null) {
        return data['unreadNum'] as int;
      }
      // 兼容直接返回数字
      if (data is int) return data;
      return 0;
    } else {
      throw Exception('获取未读消息数失败');
    }
  }

  /// 获取用户IM签名
  Future<String?> getSig() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/chat-msg/getSig');
    final response = await DioClient().dio.getUri(url);
    if (response.statusCode == 200 && response.data is Map && response.data['code'] == 200) {
      final data = response.data['data'];
      if (data is Map && data['sig'] != null) {
        return data['sig'] as String;
      }
      // 兼容直接返回字符串
      if (data is String) return data;
      return null;
    } else {
      throw Exception('获取IM签名失败');
    }
  }

  /// 用户发送聊天消息回调
  Future<bool> chatMessageSentCallback(Map<String, dynamic> body, {
    required int sdkAppid,
    required String callbackCommand,
    required String contentType,
    required String clientIp,
    required String optPlatform,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/callback/chatMessageSentCallback'
      '?SdkAppid=$sdkAppid&CallbackCommand=$callbackCommand&contenttype=$contentType&ClientIP=$clientIp&OptPlatform=$optPlatform');
    final response = await DioClient().dio.postUri(url, data: body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
} 