import '../config/app_config.dart';
import '../utils/dio_client.dart';

class ComplaintApi {
  /// 分页获取我的投诉
  Future<Map<String, dynamic>?> pageMyComplaint({required int pageNum, required int pageSize}) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/complain/page');
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

  /// 投诉用户
  Future<bool> addComplaint({required int accusedId, required String complaintContent, List<String>? images}) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/complain/add');
    final response = await DioClient().dio.postUri(url, data: {
      'accusedId': accusedId,
      'complaintContent': complaintContent,
      'images': images ?? [],
    });
    return response.statusCode == 200;
  }
} 