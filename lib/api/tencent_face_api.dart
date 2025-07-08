class TencentFaceApi {
  static const String _baseUrl = 'https://kyci.qcloud.com/api';
  final Dio _dio;

  TencentFaceApi(this._dio);

  Future<String> getAccessToken(String appId, String secret) async {
    final response = await _dio.get(
      '$_baseUrl/oauth2/access_token',
      queryParameters: {
        'appId': appId,
        'secret': secret,
        'grant_type': 'client_credential',
        'version': '1.0.0',
      },
    );
    
    if (response.data['code'] == '0') {
      return response.data['access_token'];
    } else {
      throw Exception('Failed to get access token: ${response.data['msg']}');
    }
  }

  Future<String> getSignTicket(String appId, String accessToken) async {
    final response = await _dio.get(
      '$_baseUrl/oauth2/api_ticket',
      queryParameters: {
        'appId': appId,
        'access_token': accessToken,
        'type': 'SIGN',
        'version': '1.0.0',
      },
    );
    
    if (response.data['code'] == '0') {
      return response.data['tickets'][0]['value'];
    } else {
      throw Exception('Failed to get sign ticket: ${response.data['msg']}');
    }
  }
}