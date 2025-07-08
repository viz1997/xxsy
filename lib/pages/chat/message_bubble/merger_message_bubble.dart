import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class MergerMessageBubble extends StatelessWidget {
  final V2TimMessage message;
  const MergerMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final title = message.mergerElem?.title ?? '聊天记录';
    final abstractList = message.mergerElem?.abstractList ?? [];
    return Container(
      color: Colors.orange[50],
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ...abstractList.map((e) => Text(e, style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
        ],
      ),
    );
  }
} 