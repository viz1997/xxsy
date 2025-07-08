import 'package:flutter/material.dart';

class RegisterSuccessPage extends StatelessWidget {
  const RegisterSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册成功')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 24),
            Text('恭喜你，注册成功！', style: TextStyle(fontSize: 22)),
          ],
        ),
      ),
    );
  }
} 