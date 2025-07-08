import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mop/mop.dart';

class MopService {
  static final MopService _instance = MopService._internal();
  factory MopService() => _instance;
  MopService._internal();

  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      if (Platform.isIOS) {
        final res = await Mop.instance.initialize(
          'YOUR_IOS_APPKEY', // 替换为您的iOS AppKey
          'YOUR_IOS_SECRET', // 替换为您的iOS Secret
          apiServer: 'https://api.finclip.com',
          apiPrefix: '/api/v1/mop',
        );
        _isInitialized = res['code'] == 0;
      } else if (Platform.isAndroid) {
        final res = await Mop.instance.initialize(
          'LLZnJwA1IXfku2e8ISWk4jnDKAM+dAg8gvosx2te/ROgA4x+JWh7hhNS5aO52BFs', // 替换为您的Android AppKey
          'd2c84e1cd9c9d16a', // 替换为您的Android Secret
          apiServer: 'https://api.finclip.com',
          apiPrefix: '/api/v1/mop',
        );
        _isInitialized = res['code'] == 0;
      }
      
      if (_isInitialized) {
        _registerHandlers();
      }
      
      return _isInitialized;
    } catch (e) {
      debugPrint('MOP初始化失败: $e');
      return false;
    }
  }

  void _registerHandlers() {
    Mop.instance.registerAppletHandler(_AppletHandlerImpl());
  }

  Future<void> openMiniProgram(String appId, {String? path, String? query}) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('MOP未初始化');
      }
    }

    try {
      await Mop.instance.openApplet(
        appId,
        path: path,
        query: query,
      );
    } catch (e) {
      debugPrint('打开小程序失败: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCurrentMiniProgram() async {
    if (!_isInitialized) return {};
    return await Mop.instance.currentApplet();
  }

  Future<void> closeAllMiniPrograms() async {
    if (!_isInitialized) return;
    await Mop.instance.closeAllApplets();
  }

  Future<void> clearMiniProgramCache() async {
    if (!_isInitialized) return;
    await Mop.instance.clearApplets();
  }
}

class _AppletHandlerImpl extends AppletHandler {
  @override
  void forwardApplet(Map<String, dynamic> appletInfo) {
    // 实现小程序转发逻辑
    debugPrint('小程序转发: $appletInfo');
  }

  @override
  Future<Map<String, dynamic>> getUserInfo() async {
    // 返回用户信息
    return {
      'userId': 'user_id',
      'nickName': 'nickname',
      'avatarUrl': 'avatar_url',
      'jwt': 'jwt_token',
      'accessToken': 'access_token',
    };
  }

  @override
  Future<List<CustomMenu>> getCustomMenus(String appId) async {
    // 返回自定义菜单列表
    return [];
  }

  @override
  Future onCustomMenuClick(String appId, int menuId) async {
    // 处理自定义菜单点击事件
    debugPrint('小程序 $appId 的菜单 $menuId 被点击');
  }
} 