import '../config/app_config.dart';
import '../utils/dio_client.dart';

// Define your API base URL for profile
const String _profileBaseUrl = '/system/profile'; // Adjust if needed

class ProfileApi {
  // Constructor or dependency injection for http client if needed
  // final http.Client _httpClient;
  // ProfileApi(this._httpClient);

  /// 获取用户个人资料
  Future<Map<String, dynamic>?> getProfile() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/profile');
    final response = await DioClient().dio.getUri(url);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 更新用户个人资料
  Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/profile');
    final response = await DioClient().dio.putUri(url, data: data);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 保存用户个人资料
  Future<Map<String, dynamic>?> saveProfile(Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/profile');
    final response = await DioClient().dio.postUri(url, data: data);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 删除用户个人资料
  Future<Map<String, dynamic>?> deleteProfile() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/profile');
    final response = await DioClient().dio.deleteUri(url);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// Updates user password.
  Future<bool> updatePassword(Map<String, dynamic> passwordData) async {
    // TODO: Implement actual API call using http.put
    print('Updating password via PUT $_profileBaseUrl/updatePwd with data: $passwordData');
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  /// Updates user avatar.
  Future<bool> updateAvatar(dynamic imageData) async {
    // TODO: Implement actual API call using http.post (assuming file upload)
    print('Updating avatar via POST $_profileBaseUrl/avatar with data: $imageData');
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  /// 获取用户家庭信息
  Future<Map<String, dynamic>?> getFamily() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/family');
    final response = await DioClient().dio.getUri(url);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 更新用户家庭信息
  Future<Map<String, dynamic>?> updateFamily(Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/family');
    final response = await DioClient().dio.putUri(url, data: data);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 保存用户家庭信息
  Future<Map<String, dynamic>?> saveFamily(Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/family');
    final response = await DioClient().dio.postUri(url, data: data);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 删除用户家庭信息
  Future<Map<String, dynamic>?> deleteFamily() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/family');
    final response = await DioClient().dio.deleteUri(url);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 获取用户偏好设置
  Future<Map<String, dynamic>?> getPreference() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/preference');
    final response = await DioClient().dio.getUri(url);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 更新用户偏好设置
  Future<Map<String, dynamic>?> updatePreference(Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/preference');
    final response = await DioClient().dio.putUri(url, data: data);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 保存用户偏好设置
  Future<Map<String, dynamic>?> savePreference(Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/preference');
    final response = await DioClient().dio.postUri(url, data: data);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 删除用户偏好设置
  Future<Map<String, dynamic>?> deletePreference() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/preference');
    final response = await DioClient().dio.deleteUri(url);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 设置主照片
  Future<Map<String, dynamic>?> setPrimaryPhoto(int photoId) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/photos/$photoId/primary');
    final response = await DioClient().dio.putUri(url);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 更新照片顺序
  Future<Map<String, dynamic>?> updatePhotoOrder(Map<String, int> photoOrders) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/photos/order');
    final response = await DioClient().dio.putUri(url, data: {'photoOrders': photoOrders});
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 获取用户照片列表
  Future<Map<String, dynamic>?> getPhotos() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/photos');
    final response = await DioClient().dio.getUri(url);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 保存用户照片
  Future<Map<String, dynamic>?> savePhoto(Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/photos');
    final response = await DioClient().dio.postUri(url, data: data);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 获取照片详情
  Future<Map<String, dynamic>?> getPhotoDetail(int photoId) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/photos/$photoId');
    final response = await DioClient().dio.getUri(url);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// 删除照片
  Future<Map<String, dynamic>?> deletePhoto(int photoId) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/users/info/photos/$photoId');
    final response = await DioClient().dio.deleteUri(url);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return null;
    }
  }
} 