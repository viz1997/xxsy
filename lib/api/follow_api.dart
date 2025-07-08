import 'package:http/http.dart' as http;
import 'dart:convert';

const String _baseUrl = '/users';

class FollowApi {
  /// 关注用户
  static Future<bool> followUser(int targetUserId) async {
    final response = await http.post(Uri.parse('$_baseUrl/follows/$targetUserId'));
    return response.statusCode == 200;
  }

  /// 取消关注
  static Future<bool> unfollowUser(int targetUserId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/follows/$targetUserId'));
    return response.statusCode == 200;
  }

  /// 获取关注列表
  static Future<List<dynamic>> getFollowList({int limit = 20}) async {
    final response = await http.get(Uri.parse('$_baseUrl/follows?limit=$limit'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'] ?? [];
    }
    return [];
  }

  /// 查询是否关注
  static Future<bool> isFollowing(int targetUserId) async {
    final response = await http.get(Uri.parse('$_baseUrl/follows/status/$targetUserId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  /// 获取粉丝列表
  static Future<List<dynamic>> getFollowers({int limit = 20}) async {
    final response = await http.get(Uri.parse('$_baseUrl/followers?limit=$limit'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'] ?? [];
    }
    return [];
  }
} 