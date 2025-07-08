import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tencent_faceid/models/activity.dart';
import '../config/app_config.dart';
import '../utils/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

// Define your API base URL for activities
const String _activityBaseUrl = '/activities'; // Replace with your actual base URL if needed

class ActivityApi {
  // Constructor or dependency injection for http client if needed
  // final http.Client _httpClient;
  // ActivityApi(this._httpClient);

  /// Fetches the latest 10 activities.
  Future<List<Activity>> getLast10Activities() async {
    // TODO: Implement actual API call using http.get
    print('Fetching latest 10 activities from $_activityBaseUrl/last10');
    // Example placeholder implementation:
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    final List<Map<String, dynamic>> mockData = [
      {
        'activityId': 101,
        'title': '周末户外徒步 (Mock)',
        'time': '2023-11-04T09:00:00Z',
        'location': '佘山国家森林公园 (Mock)',
        'participants': '35/50',
        'price': '88',
        'imageUrl': 'https://picsum.photos/400/300?random=101',
      },
      {
        'activityId': 102,
        'title': '室内攀岩体验 (Mock)',
        'time': '2023-11-05T14:00:00Z',
        'location': '上海攀岩馆 (Mock)',
        'participants': '12/20',
        'price': '168',
        'imageUrl': 'https://picsum.photos/400/300?random=102',
      },
    ];
    
    return mockData.map((json) => Activity.fromJson(json)).toList();
  }

  /// User joins an activity.
  Future<bool> joinActivity(String activityId) async {
    // TODO: Implement actual API call using http.post
    // Note: The API doc shows activityId in both path and query. Confirm with backend which is correct or if both are needed.
    print('Joining activity $activityId via POST $_activityBaseUrl/joinIn/$activityId');
    // Example placeholder implementation:
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    // Simulate success or failure
    return true; // Or false on failure
  }

  /// User confirms joining an activity.
  Future<bool> confirmJoinInActivity(String activityId) async {
    // TODO: Implement actual API call using http.put
     // Note: The API doc shows activityId in both path and query. Confirm with backend which is correct or if both are needed.
    print('Confirming join in activity $activityId via PUT $_activityBaseUrl/confirmJoinIn/$activityId');
    // Example placeholder implementation:
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    // Simulate success or failure
    return true; // Or false on failure
  }

  /// User checks into an activity.
  Future<bool> checkInActivity(String activityId) async {
     // TODO: Implement actual API call using http.put
     // Note: The API doc shows activityId in both path and query. Confirm with backend which is correct or if both are needed.
    print('Checking into activity $activityId via PUT $_activityBaseUrl/checkIn/$activityId');
     // Example placeholder implementation:
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    // Simulate success or failure
    return true; // Or false on failure
  }

  /// 活动签到
  Future<bool> checkIn({required int activityId}) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/activity/checkIn?activityId=$activityId');
    final response = await DioClient().dio.putUri(url);
    return response.statusCode == 200;
  }

  /// 查询活动列表（分页）
  Future<Map<String, dynamic>?> list({required int pageNum, required int pageSize}) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/activity/list');
    final dio = DioClient().dio;
    // 获取token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    final response = await dio.postUri(url, data: {
      'pageNum': pageNum,
      'pageSize': pageSize,
    });
    print('活动列表返回: statusCode: ${response.statusCode}, data: ${response.data}');
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 创建活动
  Future<bool> addActivity(Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/activity/addActivity');
    final response = await DioClient().dio.postUri(url, data: data);
    return response.statusCode == 200;
  }

  /// 发布活动
  Future<bool> release({required int activityId, required bool released}) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/activity/release?activityId=$activityId&released=$released');
    final response = await DioClient().dio.getUri(url);
    return response.statusCode == 200;
  }

  /// 报名活动
  Future<bool> registry({required int activityId}) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/activity/registry?activityId=$activityId');
    final response = await DioClient().dio.getUri(url);
    return response.statusCode == 200;
  }

  /// 取消报名
  Future<bool> cancelRegistry({required int activityId}) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/activity/cancelRegistry?activityId=$activityId');
    final response = await DioClient().dio.getUri(url);
    return response.statusCode == 200;
  }

  /// 删除活动
  Future<bool> deleteActivity({required int activityId}) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/activity/deleteActivity?activityId=$activityId');
    final response = await DioClient().dio.deleteUri(url);
    return response.statusCode == 200;
  }

  /// 获取业务列表（数据字典service_category）
  static Future<List<Map<String, dynamic>>> getServiceCategoryList() async {
    final response = await DioClient().dio.get(
      '${AppConfig.apiBaseUrl}/system/dict/data/listDictData',
      queryParameters: {'dictType': 'service_category'},
    );
    print('业务列表接口返回: statusCode: \\${response.statusCode}, data: \\${response.data}');
    if (response.statusCode == 200 &&
        response.data is Map &&
        response.data['data'] is List) {
      return List<Map<String, dynamic>>.from(response.data['data']);
    }
    return [];
  }
} 