import 'package:flutter/material.dart';

class FaceVerifyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const FaceVerifyButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading 
          ? const CircularProgressIndicator()
          : const Text('开始人脸核身'),
    );
  }
}