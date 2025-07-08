import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String faceVerificationRedirectUrl = 'wenze://face-verification-callback';
  
  // Tencent Cloud configuration
  static const String tencentCloudSecretId = 'YOUR_SECRET_ID';
  static const String tencentCloudSecretKey = 'YOUR_SECRET_KEY';
  
  // Tencent Cloud Face Verification
  static const String tencentCloudAppId = 'YOUR_WBAPPID'; // 腾讯云人脸核身 AppId
  static const String tencentCloudTicket = 'YOUR_TICKET'; // 腾讯云人脸核身 SIGN ticket
  
  // Add other app configuration constants here
  static const String apiBaseUrl = 'http://113.45.155.58:8080';
  static const String appName = 'Wenze';
} 