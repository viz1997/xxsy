import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tencent_faceid/api/activity_api.dart';
import 'package:flutter_tencent_faceid/models/activity.dart';

// API Providers
final activityApiProvider = Provider<ActivityApi>((ref) => ActivityApi());

// State Providers
final activitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final activityApi = ref.watch(activityApiProvider);
  return activityApi.getLast10Activities();
});

// 用户认证状态
final authStateProvider = StateProvider<bool>((ref) => false);

// 用户信息
final userProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// 主题状态
final themeProvider = StateProvider<bool>((ref) => false); // false = light, true = dark

// 语言状态
final languageProvider = StateProvider<String>((ref) => 'zh_CN'); 