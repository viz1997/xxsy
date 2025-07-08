import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import 'face_verification_page.dart';
import '../../tencent_faceid.dart';
import 'dart:math';
import '../api/login_api.dart';
import 'dart:convert';
import 'dart:typed_data';

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
  String? _charCaptchaBase64;
  String? _charCaptchaUuid;
  final _charCaptchaController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _agreementChecked = false;
  bool _showVerificationButton = true;
  int _verificationCountdown = 60;
  String? _idCardError;
  String? _result;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = '13538694755';
    _verificationCodeController.text = '666666';
    _nameController.text = '李白';
    _idCardController.text = '440386199402121156';
    _passwordController.text = '12345678';
    _confirmPasswordController.text = '12345678';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _nameController.dispose();
    _idCardController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _charCaptchaController.dispose();
    super.dispose();
  }

  Uint8List _base64ToBytes(String base64Str) {
    final regex = RegExp(r'data:image/\\w+;base64,');
    base64Str = base64Str.replaceAll(regex, '');
    return base64Decode(base64Str);
  }

  // Future<bool> _showCharCaptchaDialog() async {
  //   await _refreshCharCaptcha();
  //   _charCaptchaController.clear();
  //   final result = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('请输入图形验证码'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             if (_charCaptchaBase64 != null)
  //               GestureDetector(
  //                 onTap: _refreshCharCaptcha,
  //                 child: Image.memory(
  //                   _base64ToBytes(_charCaptchaBase64!),
  //                   height: 48,
  //                 ),
  //               ),
  //             const SizedBox(height: 8),
  //             TextField(
  //               controller: _charCaptchaController,
  //               decoration: const InputDecoration(
  //                 labelText: '图形验证码',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context, false),
  //             child: const Text('取消'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               if (_charCaptchaController.text.isEmpty) return;
  //               Navigator.pop(context, true);
  //             },
  //             child: const Text('确定'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //   return result == true;
  // }

  Future<void> _refreshCharCaptcha() async {
    final api = LoginApi();
    final result = await api.getCharCaptcha();
    if (result != null && result['success'] == true) {
      // 假设后端返回base64和uuid字段
      setState(() {
        _charCaptchaBase64 = result['base64'];
        _charCaptchaUuid = result['uuid'];
      });
    }
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
      // 跳过图形验证码，测试阶段直接传任意uuid和code
      // final api = LoginApi();
      // // 1. 获取图形验证码
      // final captchaResult = await api.getCharCaptcha();
      // if (captchaResult == null || captchaResult['uuid'] == null || captchaResult['base64'] == null) {
      //   _showErrorSnackBar('获取图形验证码失败');
      //   setState(() => _showVerificationButton = true);
      //   return;
      // }
      // final uuid = captchaResult['uuid'];
      // final base64 = captchaResult['base64'];
      // // 2. 弹窗让用户输入图形验证码内容
      // final code = await showDialog<String>(...)
      // if (code == null || code.isEmpty) {
      //   setState(() => _showVerificationButton = true);
      //   return;
      // }
      final api = LoginApi();
      final smsResult = await api.getSmsCaptcha(
        phoneNumber: _phoneController.text.trim(),
        uuid: 'test-uuid',
        code: 'test',
      );
      if (smsResult != null && (smsResult['success'] == true || smsResult['code'] == 200)) {
        _showSuccessSnackBar('验证码已发送');
        _startCountdown();
      } else {
        _showErrorSnackBar('发送失败: \\${smsResult?['msg'] ?? '未知错误'}');
        setState(() => _showVerificationButton = true);
      }
    } catch (e) {
      _showErrorSnackBar('发送失败: \\${e.toString()}');
      setState(() => _showVerificationButton = true);
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _verifyIdentity() async {
    final form = _formKey.currentState;
    if (!(form?.validate() ?? false)) {
      // 自动滚动到第一个错误
      if (_formKey.currentContext != null) {
        Scrollable.ensureVisible(
          _formKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
      return;
    }
    if (!_agreementChecked) {
      _showErrorSnackBar('请先阅读并同意用户协议');
      return;
    }
    // 弹窗显示人脸核身说明
    final goFace = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = MediaQuery.of(context).size.width > 500
                ? 500
                : MediaQuery.of(context).size.width * 0.95;
            return Container(
              width: maxWidth,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('人脸核身说明', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Text(
                      '点击确定后将进入人脸核身流程：',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionItem('1. 请确保光线充足，避免逆光'),
                    _buildInstructionItem('2. 保持面部在屏幕中央，距离适中'),
                    _buildInstructionItem('3. 按照提示完成眨眼、张嘴等动作'),
                    _buildInstructionItem('4. 核身过程中请勿遮挡面部'),
                    _buildInstructionItem('5. 请使用真实的姓名和身份证号'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '核身过程中请保持网络连接稳定',
                              style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('取消'),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    if (goFace != true) return;
    // 跳转到人脸核身页面，核身成功后再注册
    final faceResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FaceVerificationPage(
          name: _nameController.text.trim(),
          idCard: _idCardController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      ),
    );
    if (faceResult == true) {
      setState(() => _isLoading = true);
      try {
        final api = LoginApi();
        final result = await api.register(
          username: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          smsCode: '666666',
        );
        if (result != null && (result['success'] == true || result['code'] == 200)) {
          if (mounted) {
            // 先跳转回登录页，再toast提示注册成功
            Navigator.pushReplacementNamed(context, '/login');
            Future.delayed(const Duration(milliseconds: 300), () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('注册成功，请登录')),
              );
            });
          }
        } else {
          if (mounted) {
            _showErrorSnackBar('注册失败: \\${result?['msg'] ?? '未知错误'}');
          }
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('注册异常: \\${e.toString()}');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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

  TextStyle? get _hintStyle => Theme.of(context)
      .textTheme
      .bodySmall
      ?.copyWith(color: Colors.grey);

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            controller: _scrollController,
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
                            suffixIcon: _phoneController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _phoneController.clear();
                                      });
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            counterText: '',
                          ),
                          onChanged: (value) {
                            // 实时去除空格
                            final newValue = value.trim();
                            if (newValue != value) {
                              _phoneController.text = newValue;
                              _phoneController.selection = TextSelection.fromPosition(
                                TextPosition(offset: newValue.length),
                              );
                            }
                          },
                          validator: (value) {
                            if (value?.isEmpty ?? true) return '请输入手机号';
                            if (value!.length != 11) return '手机号格式不正确';
                            return null;
                          },
                          enabled: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _showVerificationButton
                          ? ElevatedButton(
                              onPressed: _isLoading ? null : _sendVerificationCode,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              ),
                              child: const Text('获取验证码'),
                            )
                          : OutlinedButton(
                              onPressed: null,
                              child: Text('$_verificationCountdown秒'),
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
                      suffixIcon: _verificationCodeController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _verificationCodeController.clear();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      counterText: '',
                    ),
                    onChanged: (value) {
                      // 实时去除空格
                      final newValue = value.trim();
                      if (newValue != value) {
                        _verificationCodeController.text = newValue;
                        _verificationCodeController.selection = TextSelection.fromPosition(
                          TextPosition(offset: newValue.length),
                        );
                      }
                    },
                    enabled: true,
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
                      suffixIcon: _nameController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _nameController.clear();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      // 实时去除空格
                      final newValue = value.trim();
                      if (newValue != value) {
                        _nameController.text = newValue;
                        _nameController.selection = TextSelection.fromPosition(
                          TextPosition(offset: newValue.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value?.isEmpty ?? true) return '请输入姓名';
                      return null;
                    },
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  // 身份证
                  TextFormField(
                    controller: _idCardController,
                    onChanged: (value) {
                      // 实时去除空格
                      final newValue = value.trim();
                      if (newValue != value) {
                        _idCardController.text = newValue;
                        _idCardController.selection = TextSelection.fromPosition(
                          TextPosition(offset: newValue.length),
                        );
                      }
                      if (newValue.length == 18 && !isChineseIDCard(newValue)) {
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
                      suffixIcon: _idCardController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _idCardController.clear();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return '请输入身份证号';
                      if (!isChineseIDCard(value!)) return '身份证格式不正确';
                      return null;
                    },
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  // 密码
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscure,
                    decoration: InputDecoration(
                      labelText: '设置密码',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_passwordController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _passwordController.clear();
                                });
                              },
                            ),
                          IconButton(
                            icon: Icon(
                              _isPasswordObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                                () => _isPasswordObscure = !_isPasswordObscure),
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      // 实时去除空格
                      final newValue = value.trim();
                      if (newValue != value) {
                        _passwordController.text = newValue;
                        _passwordController.selection = TextSelection.fromPosition(
                          TextPosition(offset: newValue.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value?.isEmpty ?? true) return '请输入密码';
                      if (value!.length < 8) return '密码至少8位';
                      return null;
                    },
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  // 确认密码
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _isConfirmPasswordObscure,
                    decoration: InputDecoration(
                      labelText: '确认密码',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_confirmPasswordController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _confirmPasswordController.clear();
                                });
                              },
                            ),
                          IconButton(
                            icon: Icon(
                              _isConfirmPasswordObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                                () => _isConfirmPasswordObscure = !_isConfirmPasswordObscure),
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      // 实时去除空格
                      final newValue = value.trim();
                      if (newValue != value) {
                        _confirmPasswordController.text = newValue;
                        _confirmPasswordController.selection = TextSelection.fromPosition(
                          TextPosition(offset: newValue.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return '两次密码不一致';
                      }
                      return null;
                    },
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  // 协议勾选
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _agreementChecked,
                          onChanged: (value) => setState(() => _agreementChecked = value ?? false),
                          shape: const CircleBorder(),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          splashRadius: 12,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: _showAgreementDialog,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(text: '我已阅读并同意'),
                                  const TextSpan(
                                    text: '《用户协议》',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(text: '和'),
                                  const TextSpan(
                                    text: '《隐私政策》',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                              softWrap: true,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
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
                              '下一步',
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