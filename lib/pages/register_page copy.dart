import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _inviteCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _agreementChecked = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _nameController.dispose();
    _idCardController.dispose();
    _inviteCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendVerificationCode() {
    // TODO: 实现发送验证码逻辑
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('验证码已发送')));
  }

  void _goToFaceVerification() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreementChecked) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请先阅读并同意用户协议')));
        return;
      }

      // TODO: 跳转到人脸识别页面
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FaceVerificationPage()),
      );
    }
  }

  void _showAgreement() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('用户协议'),
            content: SingleChildScrollView(
              child: Text(
                '用户协议内容...',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册账号'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  '创建账号',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '请填写以下信息完成注册',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                // 手机号输入框
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  decoration: InputDecoration(
                    labelText: '手机号',
                    prefixIcon: const Icon(Icons.phone_android),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入手机号';
                    }
                    if (value.length != 11) {
                      return '请输入11位手机号';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // 验证码输入框
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _verificationCodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: '验证码',
                          prefixIcon: const Icon(Icons.security),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入验证码';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _sendVerificationCode,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('获取验证码'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 姓名输入框
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '姓名',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入姓名';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // 身份证号输入框
                TextFormField(
                  controller: _idCardController,
                  keyboardType: TextInputType.number,
                  maxLength: 18,
                  decoration: InputDecoration(
                    labelText: '身份证号',
                    prefixIcon: const Icon(Icons.credit_card),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入身份证号';
                    }
                    if (value.length != 18) {
                      return '请输入18位身份证号';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // 邀请码输入框
                TextFormField(
                  controller: _inviteCodeController,
                  decoration: InputDecoration(
                    labelText: '邀请码',
                    prefixIcon: const Icon(Icons.card_giftcard),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入邀请码';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // 密码输入框
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscure,
                  decoration: InputDecoration(
                    labelText: '密码',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscure = !_isPasswordObscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    if (value.length < 6) {
                      return '密码长度不能少于6位';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // 确认密码输入框
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
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordObscure =
                              !_isConfirmPasswordObscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请确认密码';
                    }
                    if (value != _passwordController.text) {
                      return '两次输入的密码不一致';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // 用户协议勾选
                Row(
                  children: [
                    Checkbox(
                      value: _agreementChecked,
                      onChanged: (value) {
                        setState(() {
                          _agreementChecked = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _showAgreement,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey[600]),
                            children: [
                              const TextSpan(text: '我已阅读并同意'),
                              TextSpan(
                                text: '《用户协议》',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 下一步按钮
                ElevatedButton(
                  onPressed: _goToFaceVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '下一步',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                // 登录链接
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('已有账号？', style: TextStyle(color: Colors.grey[600])),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('立即登录'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
