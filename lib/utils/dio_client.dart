import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database/shared_preferences_db.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../api/login_api.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  late Dio dio;

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl, // 可全局配置baseUrl，也可每次传绝对路径
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(SharedPreferencesKey.jwtToken);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioError e, handler) async {
        if (e.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          final refreshToken = prefs.getString(SharedPreferencesKey.refreshToken);
          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              final result = await LoginApi().refreshToken(refreshToken: refreshToken);
              if (result['success'] == true && result['token'] != null) {
                // 保存新 token
                await prefs.setString(SharedPreferencesKey.jwtToken, result['token']);
                // 更新请求头并重试原请求
                final newOptions = e.requestOptions;
                newOptions.headers['Authorization'] = 'Bearer ${result['token']}';
                final cloneReq = await dio.fetch(newOptions);
                return handler.resolve(cloneReq);
              }
            } catch (_) {}
          }
          // 刷新失败，清除 token 并跳转登录
          await prefs.remove(SharedPreferencesKey.jwtToken);
          await prefs.remove(SharedPreferencesKey.refreshToken);
          navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        }
        return handler.next(e);
      },
    ));
  }
}

/// 全局导航key，main.dart需配置MaterialApp(navigatorKey: navigatorKey)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); 