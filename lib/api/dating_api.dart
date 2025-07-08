import '../config/app_config.dart';
import '../utils/dio_client.dart';

class DatingApi {
  /// 分页获取约会记录
  Future<Map<String, dynamic>?> pageDatingRecords({required int pageNum, required int pageSize}) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/dating/pageDatingRecords');
    final response = await DioClient().dio.postUri(url, data: {
      'pageNum': pageNum,
      'pageSize': pageSize,
    });
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 新增约会记录
  Future<Map<String, dynamic>?> addDating(Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/dating/add');
    final response = await DioClient().dio.postUri(url, data: data);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 取消约会
  Future<Map<String, dynamic>?> cancelDating(int datingId) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/dating/cancelDating?datingId=$datingId');
    final response = await DioClient().dio.getUri(url);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 是否接受邀请
  Future<Map<String, dynamic>?> acceptDating({
    required int datingId,
    required bool accept,
    String? reason,
  }) async {
    final params = {
      '约会记录id': datingId,
      '是否接受邀请': accept,
    };
    if (reason != null) {
      params['拒绝原因'] = reason;
    }
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/dating/acceptDating').replace(queryParameters: params.map((k, v) => MapEntry(k, v.toString())));
    final response = await DioClient().dio.getUri(uri);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }
} 