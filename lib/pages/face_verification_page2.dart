import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FaceVerificationPage extends StatefulWidget {
  final String appId;
  final String userId;
  final String orderNo;
  final String nonce;
  final String sign;
  final String faceId;
  final String licence;
  final String name;
  final String idCard;
  final String phone;
  final String password;

  const FaceVerificationPage({
    super.key,
    required this.appId,
    required this.userId,
    required this.orderNo,
    required this.nonce,
    required this.sign,
    required this.faceId,
    required this.licence,
    required this.name,
    required this.idCard,
    required this.phone,
    required this.password,
  });

  @override
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  bool _isLoading = true;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startFaceVerification();
  }

  Future<void> _startFaceVerification() async {
    try {
      final channel = MethodChannel('tencent_face_verify');
      
      final result = await channel.invokeMethod('startFaceVerify', {
        'appId': widget.appId,
        'userId': widget.userId,
        'orderNo': widget.orderNo,
        'nonce': widget.nonce,
        'sign': widget.sign,
        'faceId': widget.faceId,
        'licence': widget.licence,
      });

      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
      
      // 人脸核身成功后，完成注册流程
      await _completeRegistration();
      
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? '人脸核身失败';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _completeRegistration() async {
    // 调用注册API完成注册
    try {
      await AuthService.register(
        name: widget.name,
        idCard: widget.idCard,
        phone: widget.phone,
        password: widget.password,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('注册成功')),
        );
        Navigator.pop(context, true); // 返回注册成功结果
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('注册失败: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('人脸核身'),
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('正在准备人脸核身...'),
                ],
              )
            : _isSuccess
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 60),
                      SizedBox(height: 20),
                      Text('人脸核身成功', style: TextStyle(fontSize: 18)),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 60),
                      const SizedBox(height: 20),
                      Text(_errorMessage ?? '核身失败', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _startFaceVerification,
                        child: const Text('重试'),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('返回'),
                      ),
                    ],
                  ),
      ),
    );
  }
}