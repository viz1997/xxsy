import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tencent_faceid/services/face_verification_service.dart';
import 'package:flutter_tencent_faceid/services/tencent_face_verify.dart';
import 'package:flutter_tencent_faceid/config/app_config.dart';

class FaceVerificationPage extends ConsumerStatefulWidget {
  final String name;
  final String idCard;
  final String phone;
  final String password;

  const FaceVerificationPage({
    super.key,
    required this.name,
    required this.idCard,
    required this.phone,
    required this.password,
  });

  @override
  ConsumerState<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends ConsumerState<FaceVerificationPage> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startFaceVerification();
  }

  Future<void> _startFaceVerification() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. 获取 faceId
      final faceService = ref.read(faceVerificationServiceProvider);
      await faceService.init(
        secretId: AppConfig.tencentCloudSecretId,
        secretKey: AppConfig.tencentCloudSecretKey,
      );

      final faceId = await faceService.getFaceId(
        name: widget.name,
        idCard: widget.idCard,
      );

      // 2. 生成签名所需参数
      final nonce = DateTime.now().millisecondsSinceEpoch.toString();
      const version = '1.0.0';
      final userId = widget.phone; // 使用手机号作为用户唯一标识
      final agreementNo = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

      // 3. 生成签名
      final sign = TencentFaceVerify.generateSign(
        appId: AppConfig.tencentCloudAppId,
        userId: userId,
        version: version,
        ticket: AppConfig.tencentCloudTicket,
        nonce: nonce,
      );

      // 4. 启动人脸核身
      final result = await TencentFaceVerify.startVerification(
        appId: AppConfig.tencentCloudAppId,
        userId: userId,
        nonce: nonce,
        sign: sign,
        faceId: faceId,
        agreementNo: agreementNo,
      );

      if (!mounted) return;

      // 5. 处理结果
      if (result['code'] == 0) {
        // 验证成功，返回上一页
        Navigator.pop(context, true);
      } else {
        setState(() => _errorMessage = result['msg'] ?? '人脸核身失败');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('人脸核身')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('人脸核身'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('正在启动人脸核身...'),
          ],
        ),
      ),
    );
  }
} 