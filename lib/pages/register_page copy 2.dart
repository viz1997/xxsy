import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tencent_faceid/services/auth_service.dart';
import 'package:flutter_tencent_faceid/pages/face_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _idCardController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _agreementChecked = false;
  bool _showVerificationButton = true;
  int _verificationCountdown = 60;
  String? _idCardError;

  @override
  void dispose() {
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _nameController.dispose();
    _idCardController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length != 11) {
      _showErrorSnackBar('请输入有效的手机号');
      return;
    }

    setState(() {
      _showVerificationButton = false;
      _isLoading = true;
    });

    try {
      await AuthService.sendSmsCode(_phoneController.text);
      _showSuccessSnackBar('验证码已发送');
      _startCountdown();
    } catch (e) {
      _showErrorSnackBar('发送失败: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _verificationCountdown--);
      return _verificationCountdown > 0;
    }).then((_) {
      if (mounted) {
        setState(() {
          _showVerificationButton = true;
          _verificationCountdown = 60;
        });
      }
    });
  }

  Future<void> _verifyIdentity() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreementChecked) {
      _showErrorSnackBar('请先阅读并同意用户协议');
      return;
    }

    // 提前验证身份证格式
    if (!isChineseIDCard(_idCardController.text)) {
      setState(() => _idCardError = '身份证格式不正确');
      return;
    }

    setState(() {
      _isLoading = true;
      _idCardError = null;
    });

    try {
      // 1. 验证短信验证码
      final smsValid = await AuthService.verifySmsCode(
        _phoneController.text,
        _verificationCodeController.text,
      );
      if (!smsValid) throw Exception('验证码错误');

      // 2. 手机号三要素核验
      final threeFactors = await AuthService.verifyPhoneThreeFactors(
        name: _nameController.text,
        idCard: _idCardController.text,
        phone: _phoneController.text,
      );

      if (!threeFactors.isPass) {
        throw Exception(_parseThreeFactorsError(threeFactors));
      }

      // 3. 跳转人脸核身
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FaceVerificationPage(
            name: _nameController.text,
            idCard: _idCardController.text,
            phone: _phoneController.text,
            isp: threeFactors.isp,
            password: _passwordController.text,
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseThreeFactorsError(VerifyResponse response) {
    switch (response.detail) {
      case 'PhoneIdCardMismatch':
        return '手机号与身份证信息不匹配';
      case 'PhoneNameMismatch':
        return '手机号与姓名不匹配';
      case 'PhoneNameIdCardMismatch':
        return '手机号、姓名与身份证均不匹配';
      default:
        return response.errorMessage ?? '身份核验失败';
    }
  }

  void _showAgreementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('用户协议及隐私政策'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('我们将收集以下信息用于实名认证：'),
              const SizedBox(height: 8),
              Text('• 手机号：用于接收验证码', style: _hintStyle),
              Text('• 身份证：与公安系统核验', style: _hintStyle),
              Text('• 人脸信息：活体验证', style: _hintStyle),
              const SizedBox(height: 16),
              const Text('认证完成后将立即删除人脸数据'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('同意并继续'),
          ),
        ],
      ),
    );
  }

  bool isChineseIDCard(String id) {
    final reg = RegExp(
      r'^[1-9]\d{5}(19|20)\d{2}(0[1-9]|1[0-2])'
      r'(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$'
    );
    return reg.hasMatch(id);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceAll(RegExp(r'\d{4}'), '****')),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  TextStyle? get _hintStyle => Theme.of(context)
      .textTheme
      .bodySmall
      ?.copyWith(color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('实名注册'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // 手机号+验证码
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: '手机号',
                            prefixIcon: const Icon(Icons.phone),
                            hintText: '11位手机号码',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return '请输入手机号';
                            if (value!.length != 11) return '手机号格式不正确';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 120,
                        child: _showVerificationButton
                            ? ElevatedButton(
                                onPressed: _isLoading ? null : _sendVerificationCode,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('获取验证码'),
                              )
                            : OutlinedButton(
                                onPressed: null,
                                child: Text('$_verificationCountdown秒'),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 验证码
                  TextFormField(
                    controller: _verificationCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: '验证码',
                      prefixIcon: const Icon(Icons.sms),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return '请输入验证码';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // 姓名
                  TextFormField(
                    controller: _nameController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\u4e00-\u9fa5]')),
                    ],
                    decoration: InputDecoration(
                      labelText: '真实姓名',
                      prefixIcon: const Icon(Icons.person),
                      hintText: '需与身份证一致',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return '请输入姓名';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // 身份证
                  TextFormField(
                    controller: _idCardController,
                    onChanged: (value) {
                      if (value.length == 18 && !isChineseIDCard(value)) {
                        setState(() => _idCardError = '身份证格式不正确');
                      } else if (_idCardError != null) {
                        setState(() => _idCardError = null);
                      }
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9Xx]')),
                      LengthLimitingTextInputFormatter(18),
                    ],
                    decoration: InputDecoration(
                      labelText: '身份证号',
                      prefixIcon: const Icon(Icons.credit_card),
                      hintText: '18位身份证号码',
                      errorText: _idCardError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return '请输入身份证号';
                      if (!isChineseIDCard(value!)) return '身份证格式不正确';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // 密码
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscure,
                    decoration: InputDecoration(
                      labelText: '设置密码',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                            () => _isPasswordObscure = !_isPasswordObscure),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return '请输入密码';
                      if (value!.length < 8) return '密码至少8位';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // 确认密码
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _isConfirmPasswordObscure,
                    decoration: InputDecoration(
                      labelText: '确认密码',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordObscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                            () => _isConfirmPasswordObscure = !_isConfirmPasswordObscure),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return '两次密码不一致';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // 协议勾选
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreementChecked,
                        onChanged: (value) => setState(
                            () => _agreementChecked = value ?? false),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _showAgreementDialog,
                              child: const Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(text: '我已阅读并同意'),
                                    TextSpan(
                                      text: '《用户协议》',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: '和'),
                                    TextSpan(
                                      text: '《隐私政策》',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!_agreementChecked)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '请先同意协议',
                                  style: TextStyle(
                                    color: Colors.red[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 提交按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyIdentity,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '安全验证',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 已有账号
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('已有账号？立即登录'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const ModalBarrier(
              color: Colors.black26,
              dismissible: false,
            ),
        ],
      ),
    );
  }
}