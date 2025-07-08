import 'package:dio/dio.dart';
import '../utils/dio_client.dart';

class UserInfoApi {
  final DioClient _dioClient;

  UserInfoApi(this._dioClient);

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