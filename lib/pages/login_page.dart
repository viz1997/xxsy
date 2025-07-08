import 'package:flutter/material.dart';
import 'dart:async';
import '../api/login_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database/shared_preferences_db.dart';
import 'dart:convert';

const String kRecentLoginPhonesKey = 'recent_login_phones';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  late AnimationController _controller;
  String _welcomeText = '我们不确定什么样的人适合您，但是我们能确定什么样的人不适合您。没有套路，没有费用，旨在做我们认为对的事情，有价值的事情。希望您能很快在我们平台找到适合您的另一半。';
  String _displayText = '';
  int _currentIndex = 0;
  Timer? _timer;
  String? _charCaptchaBase64;
  String? _charCaptchaUuid;
  late TextEditingController _charCaptchaController;
  DateTime? _lastCaptchaRefreshTime;
  bool _isRefreshingCaptcha = false;

  List<String> _recentPhones = [];
  bool _showRecentPhones = false;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
    _loadRecentPhones();
    _phoneController.addListener(_onPhoneChanged);
  }

  Future<void> _loadRecentPhones() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(kRecentLoginPhonesKey) ?? [];
    setState(() {
      _recentPhones = list;
      if (list.isNotEmpty) {
        _phoneController.text = list.first;
      }
    });
  }

  void _onPhoneChanged() {
    if (_phoneController.text.isEmpty && _recentPhones.isNotEmpty) {
      setState(() {
        _showRecentPhones = true;
      });
    } else if (_showRecentPhones) {
      setState(() {
        _showRecentPhones = false;
      });
    }
  }

  void _startTypewriter() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_currentIndex < _welcomeText.length) {
        setState(() {
          _displayText = _welcomeText.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _refreshCaptcha() async {
    // 检查刷新频率限制 (2秒)
    if (_lastCaptchaRefreshTime != null && 
        DateTime.now().difference(_lastCaptchaRefreshTime!) < const Duration(seconds: 2)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请勿频繁刷新验证码'), backgroundColor: Colors.orange),
      );
      return;
    }

    // 防止重复请求
    if (_isRefreshingCaptcha) return;

    setState(() {
      _isRefreshingCaptcha = true;
    });

    try {
      final api = LoginApi();
      final result = await api.getCharCaptcha();
      if (result == null || result['img'] == null || result['uuid'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('获取图形验证码失败'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() {
        _charCaptchaBase64 = result['img'];
        _charCaptchaUuid = result['uuid'];
        _lastCaptchaRefreshTime = DateTime.now();
      });
    } finally {
      setState(() {
        _isRefreshingCaptcha = false;
      });
    }
  }

  Future<bool> _showCharCaptchaDialog() async {
    final api = LoginApi();
    final result = await api.getCharCaptcha();
    if (result == null || result['img'] == null || result['uuid'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('获取图形验证码失败'), backgroundColor: Colors.red),
      );
      return false;
    }
    _charCaptchaBase64 = result['img'];
    _charCaptchaUuid = result['uuid'];
    _lastCaptchaRefreshTime = DateTime.now();
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('请输入图形验证码'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.memory(base64Decode(_charCaptchaBase64!), height: 48),
                            if (_isRefreshingCaptcha)
                              Container(
                                height: 48,
                                color: Colors.black12,
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _isRefreshingCaptcha ? null : () async {
                          await _refreshCaptcha();
                          setState(() {}); // 刷新对话框状态
                        },
                        icon: const Icon(Icons.refresh),
                        color: Colors.grey[600],
                        tooltip: '刷新验证码',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: '图形验证码',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // 实时去除空格
                      final newValue = value.trim();
                      if (newValue != value) {
                        controller.text = newValue;
                        controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: newValue.length),
                        );
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) return;
                    Navigator.pop(context, true);
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
    if (ok == true) {
      _charCaptchaController = controller;
      return true;
    }
    return false;
  }

  void _login() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    
    // 验证输入不能为空
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入手机号'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入密码'), backgroundColor: Colors.red),
      );
      return;
    }

    final api = LoginApi();
    // 弹窗获取图形验证码
    final ok = await _showCharCaptchaDialog();
    if (!ok) return;
    final code = _charCaptchaController.text.trim();
    
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入图形验证码'), backgroundColor: Colors.red),
      );
      return;
    }

    final uuid = _charCaptchaUuid;
    // 2. 用uuid和code请求一次短信验证码接口
    await api.getSmsCaptcha(phoneNumber: phone, uuid: uuid!, code: code);
    // 3. 用uuid、code、password去登录
    final result = await api.login(
      username: phone,
      password: password,
      uuid: uuid!,
      code: code,
    );
    if (result != null && (result['success'] == true || result['code'] == 200)) {
      // 保存token
      final prefs = await SharedPreferences.getInstance();
      if (result['token'] != null) {
        await prefs.setString(SharedPreferencesKey.jwtToken, result['token']);
      }
      // 保存最近登录账号
      final phones = prefs.getStringList(kRecentLoginPhonesKey) ?? [];
      final newPhones = [phone, ...phones.where((p) => p != phone)].take(3).toList();
      await prefs.setStringList(kRecentLoginPhonesKey, newPhones);
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?['msg'] ?? '手机号或密码错误'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '致用户：',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _displayText,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: '手机号',
                              prefixIcon: const Icon(Icons.phone_android),
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
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Theme.of(context).primaryColor),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
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
                          ),
                          if (_showRecentPhones)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 60,
                              child: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(8),
                                child: ListView(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  children: _recentPhones.take(3).map((phone) => ListTile(
                                    title: Text(phone),
                                    onTap: () {
                                      setState(() {
                                        _phoneController.text = phone.trim();
                                        _showRecentPhones = false;
                                      });
                                    },
                                  )).toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          labelText: '密码',
                          prefixIcon: const Icon(Icons.lock_outline),
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
                                  _isObscure ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                              ),
                            ],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    '登录',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        // TODO: 实现忘记密码功能
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                      child: const Text('忘记密码？'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text('新用户注册'),
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