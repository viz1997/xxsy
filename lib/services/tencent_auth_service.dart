import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TencentAuthService {
  static const String _baseUrl = 'https://kyc1.qcloud.com/api/oauth2';
  static String? _accessToken;
  static String? _signTicket;
  static DateTime? _accessTokenExpireTime;
  static DateTime? _signTicketExpireTime;
  static Timer? _refreshTimer;

  // 配置参数（实际应用中应该从环境变量或配置文件读取）
  static const String _appId = 'your_wb_app_id_here';
  static const String _secret = 'your_secret_here';

  /// 初始化服务，开始定时刷新 token 和 ticket
  static void init() {
    _startRefreshTimer();
  }

  /// 获取 Access Token
  static Future<String> getAccessToken() async {
    if (_accessToken != null && _accessTokenExpireTime != null && 
        DateTime.now().isBefore(_accessTokenExpireTime!)) {
      return _accessToken!;
    }

    final response = await http.get(Uri.parse(
      '$_baseUrl/access_token'
      '?appId=$_appId'
      '&secret=$_secret'
      '&grant_type=client_credential'
      '&version=1.0.0'
    ));

    if (response.statusCode != 200) {
      throw Exception('Failed to get access token: ${response.body}');
    }

    final data = jsonDecode(response.body);
    if (data['code'] != '0') {
      throw Exception('Failed to get access token: ${data['msg']}');
    }

    _accessToken = data['access_token'];
    _accessTokenExpireTime = DateTime.now().add(
      Duration(seconds: int.parse(data['expire_in']) - 60) // 提前1分钟过期
    );

    return _accessToken!;
  }

  /// 获取 SIGN Ticket
  static Future<String> getSignTicket() async {
    if (_signTicket != null && _signTicketExpireTime != null && 
        DateTime.now().isBefore(_signTicketExpireTime!)) {
      return _signTicket!;
    }

    final accessToken = await getAccessToken();
    
    final response = await http.get(Uri.parse(
      '$_baseUrl/api_ticket'
      '?appId=$_appId'
      '&access_token=$accessToken'
      '&type=SIGN'
      '&version=1.0.0'
    ));

    if (response.statusCode != 200) {
      throw Exception('Failed to get SIGN ticket: ${response.body}');
    }

    final data = jsonDecode(response.body);
    if (data['code'] != '0') {
      throw Exception('Failed to get SIGN ticket: ${data['msg']}');
    }

    final ticket = data['tickets'][0];
    _signTicket = ticket['value'];
    _signTicketExpireTime = DateTime.now().add(
      Duration(seconds: int.parse(ticket['expire_in']) - 60) // 提前1分钟过期
    );

    return _signTicket!;
  }

  /// 获取 NONCE Ticket
  static Future<String> getNonceTicket(String userId) async {
    final accessToken = await getAccessToken();
    
    final response = await http.get(Uri.parse(
      '$_baseUrl/api_ticket'
      '?appId=$_appId'
      '&access_token=$accessToken'
      '&type=NONCE'
      '&version=1.0.0'
      '&user_id=$userId'
    ));

    if (response.statusCode != 200) {
      throw Exception('Failed to get NONCE ticket: ${response.body}');
    }

    final data = jsonDecode(response.body);
    if (data['code'] != '0') {
      throw Exception('Failed to get NONCE ticket: ${data['msg']}');
    }

    return data['tickets'][0]['value'];
  }

  /// 开始定时刷新 token 和 ticket
  static void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 20), (_) async {
      try {
        await getAccessToken();
        await getSignTicket();
      } catch (e) {
        print('Failed to refresh token/ticket: $e');
      }
    });
  }

  /// 停止定时刷新
  static void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
} 