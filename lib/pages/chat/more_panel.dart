import 'package:flutter/material.dart';

typedef VoidCallback = void Function();

class MorePanel extends StatelessWidget {
  final VoidCallback onSendImage;
  const MorePanel({Key? key, required this.onSendImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('发送图片'),
            onTap: () {
              Navigator.pop(context);
              onSendImage();
            },
          ),
          // 可继续添加更多功能项
        ],
      ),
    );
  }
} 