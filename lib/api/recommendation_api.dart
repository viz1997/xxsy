import 'package:dio/dio.dart';
import '../utils/dio_client.dart';

class RecommendationApi {
  final DioClient _dioClient;

  RecommendationApi(this._dioClient);

  /// 获取推荐列表
  Future<Map<String, dynamic>> getRecommendationList({
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/users/recommendation/list',
        queryParameters: {
          'pageNum': pageNum,
          'pageSize': pageSize,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 标记为已查看
  Future<Map<String, dynamic>> markAsViewed(int resultId) async {
    try {
      final response = await _dioClient.dio.put(
        '/users/recommendation/view/$resultId',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 标记为喜欢
  Future<Map<String, dynamic>> markAsLiked(int resultId) async {
    try {
      final response = await _dioClient.dio.put(
        '/users/recommendation/like/$resultId',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 标记为不喜欢
  Future<Map<String, dynamic>> markAsDisliked(int resultId) async {
    try {
      final response = await _dioClient.dio.put(
        '/users/recommendation/dislike/$resultId',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 刷新推荐列表
  Future<Map<String, dynamic>> refreshRecommendations() async {
    try {
      final response = await _dioClient.dio.post(
        '/users/recommendation/refresh',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 获取用户详情
  Future<Map<String, dynamic>> getUserDetail(int userId) async {
    try {
      final response = await _dioClient.dio.get(
        '/users/info/detail/$userId',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
} 