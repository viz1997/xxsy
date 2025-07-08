import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tencent_faceid.dart';
import '../../services/auth_service.dart';

class FaceVerificationPage extends StatefulWidget {
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
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  bool _isLoading = true;
  bool _isSuccess = false;
  String? _errorMessage;
  String _currentStep = '正在准备人脸核身...';

  @override
  void initState() {
    super.initState();
    _startFaceVerification();
  }

  Future<void> _startFaceVerification() async {
    try {
      setState(() {
        _currentStep = '正在初始化SDK...';
      });

      // 1. 初始化SDK
      final userId = "user_${DateTime.now().millisecondsSinceEpoch}";
      final initialized = await TencentFaceId.initSDK(
        userId: userId,
        name: widget.name,
        idNo: widget.idCard,
      );

      if (!initialized) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'SDK初始化失败';
        });
        return;
      }

      setState(() {
        _currentStep = '正在启动人脸核身...';
      });

      // 2. 启动核身
      final result = await TencentFaceId.startVerification();

      if (result.isSuccess) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
          _currentStep = '人脸核身成功';
        });

        // 核身成功，完成注册
        await _completeRegistration();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '人脸核身失败: ${result.errorMsg ?? "未知错误"}';
        });
      }

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
    try {
      await AuthService.register(
        name: widget.name,
        idCard: widget.idCard,
        phone: widget.phone,
        password: widget.password,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('注册成功！'),
            backgroundColor: Colors.green,
          ),
        );
        // 延迟一下让用户看到成功消息
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/register_success');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('注册失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInstructions() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '人脸核身注意事项',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionItem('• 请确保光线充足，避免逆光'),
            _buildInstructionItem('• 保持面部在屏幕中央，距离适中'),
            _buildInstructionItem('• 按照提示完成眨眼、张嘴等动作'),
            _buildInstructionItem('• 核身过程中请勿遮挡面部'),
            _buildInstructionItem('• 请保持网络连接稳定'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.orange.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '核身过程中请勿退出或切换应用',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade700,
          height: 1.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('人脸核身'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_isLoading) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        _currentStep,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              _buildInstructions(),
            ] else if (_isSuccess) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '人脸核身成功！',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '正在完成注册...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage ?? '核身失败',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _startFaceVerification();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
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
              ),
            ],
          ],
        ),
      ),
    );
  }
} 