import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPwdController = TextEditingController();
  final TextEditingController _newPwdController = TextEditingController();
  final TextEditingController _confirmPwdController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPwdController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    // TODO: 调用更换密码接口
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('密码修改成功')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('更换密码')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _oldPwdController,
                obscureText: _obscureOld,
                decoration: InputDecoration(
                  labelText: '原密码',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? '请输入原密码' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _newPwdController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: '新密码',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) => v == null || v.length < 6 ? '新密码至少6位' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPwdController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: '确认新密码',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) => v != _newPwdController.text ? '两次输入不一致' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text('确认修改'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 