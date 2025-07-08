import 'package:flutter/material.dart';

class ChangePhonePage extends StatefulWidget {
  const ChangePhonePage({super.key});

  @override
  State<ChangePhonePage> createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isSending = false;
  int _seconds = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _sendCode() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入正确的手机号')));
      return;
    }
    setState(() {
      _isSending = true;
      _seconds = 60;
    });
    // TODO: 调用发送验证码接口
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isSending = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('验证码已发送')));
    _startCountdown();
  }

  void _startCountdown() {
    if (_seconds == 0) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _seconds--;
      });
      if (_seconds > 0) {
        _startCountdown();
      }
    });
  }

  void _changePhone() async {
    if (!_formKey.currentState!.validate()) return;
    // TODO: 调用更换手机号接口
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('更换手机号成功')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('更换手机号')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: '新手机号'),
                validator: (v) => v == null || v.isEmpty || v.length != 11 ? '请输入11位手机号' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '验证码'),
                      validator: (v) => v == null || v.isEmpty ? '请输入验证码' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSending || _seconds > 0 ? null : _sendCode,
                    child: Text(_seconds > 0 ? '$_seconds s' : '获取验证码'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _changePhone,
                  child: const Text('确认更换'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 